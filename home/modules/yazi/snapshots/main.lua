--------------------------------------------------------------------------------
-- BTRFS Backend
--------------------------------------------------------------------------------

--- Parse timestamp for sorting
--- Format: "2025-12-30 23:00:07 +0100"
--- @param time_str string
--- @return number
local function parse_timestamp(time_str)
    if not time_str or time_str == "Unknown" then
        return 0
    end
    
    -- Extract: year, month, day, hour, minute, second
    local year, month, day, hour, min, sec = time_str:match("(%d+)-(%d+)-(%d+)%s+(%d+):(%d+):(%d+)")
    
    if not year then
        return 0
    end
    
    -- Create a comparable number (YYYYMMDDHHmmss)
    return tonumber(string.format("%04d%02d%02d%02d%02d%02d", 
        year, month, day, hour, min, sec))
end

--- Parse btrfs subvolume list output into a table
--- @param output string The output from 'btrfs subvolume list -puqt /'
--- @return table subvols Map of ID -> {id, gen, parent, top_level, parent_uuid, uuid, path}
local function parse_subvol_list(output)
    local subvols = {}
    local lines = {}
    
    -- Split into lines
    for line in output:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    -- Skip header line
    for i = 2, #lines do
        local line = lines[i]
        -- Parse: ID	gen	parent	top level	parent_uuid	uuid	path
        local id, gen, parent, top_level, parent_uuid, uuid, path = 
            line:match("^(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+([^%s]+)%s+([^%s]+)%s+(.+)$")
        
        if id then
            subvols[tonumber(id)] = {
                id = tonumber(id),
                gen = tonumber(gen),
                parent = tonumber(parent),
                top_level = tonumber(top_level),
                parent_uuid = parent_uuid,
                uuid = uuid,
                path = path,
            }
        end
    end
    
    return subvols
end

--- Parse findmnt output into a table
--- @param output string The output from 'findmnt -l -Q FSTYPE == "btrfs" -o SOURCE,TARGET'
--- @return table mounts Map of subvol_path -> target
local function parse_findmnt(output)
    local mounts = {}
    local lines = {}
    
    -- Split into lines
    for line in output:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    -- Skip header line and parse each mount
    for i = 2, #lines do
        local line = lines[i]
        
        -- Handle multi-line entries (continuation lines start with whitespace)
        if line:match("^%s") then
            -- This is a continuation of the previous line's TARGET
            local target = line:match("^%s+(.+)$")
            if target and #mounts > 0 then
                -- Update the last entry's target
                local last_key = nil
                for k, v in pairs(mounts) do
                    last_key = k
                end
                if last_key then
                    mounts[last_key] = target
                end
            end
        else
            -- New entry: SOURCE TARGET
            local source, target = line:match("^(%S+)%s+(.+)$")
            
            if source then
                -- Extract the subvol path from source (between brackets)
                local subvol_path = source:match("%[/(.+)%]")
                
                -- If no brackets, it's the root subvolume (empty string)
                if not subvol_path then
                    subvol_path = ""
                end
                
                -- Trim target if it exists
                if target then
                    target = target:match("^%s*(.-)%s*$")
                    mounts[subvol_path] = target
                else
                    -- TARGET is on the next line
                    mounts[subvol_path] = nil
                end
            end
        end
    end
    
    return mounts
end

--- Build the accessible path for a subvolume by walking up the parent chain
--- @param subvol_id number
--- @param subvols table Map of ID -> subvol info
--- @param mounts table Map of subvol_path -> target
--- @return string|nil path The accessible filesystem path or nil
local function build_subvolume_path(subvol_id, subvols, mounts)
    local path_components = {}
    local current_id = subvol_id
    
    -- Walk up the parent chain
    while current_id and current_id ~= 0 and current_id ~= 5 do
        local subvol = subvols[current_id]
        if not subvol then
            break
        end
        
        -- Check if this subvolume is mounted
        local mount_target = mounts[subvol.path]
        if mount_target then
            -- Found a mounted parent! Build the path
            local result_path = mount_target
            
            -- Prepend all collected components
            for i = #path_components, 1, -1 do
                result_path = result_path .. "/" .. path_components[i]
            end
            
            return result_path
        end
        
        -- Get the parent to calculate relative path
        local parent = subvols[subvol.parent]
        if not parent then
            break
        end
        
        -- Calculate relative path from parent to child
        local parent_path = parent.path
        local child_path = subvol.path
        
        if child_path:sub(1, #parent_path) == parent_path then
            local relative = child_path:sub(#parent_path + 1)
            -- Remove leading slash
            if relative:sub(1, 1) == "/" then
                relative = relative:sub(2)
            end
            
            if relative ~= "" then
                table.insert(path_components, relative)
            end
        end
        
        current_id = subvol.parent
    end
    
    return nil
end

--- Special error type to indicate we're in a snapshot
local SNAPSHOT_ERROR = "IN_SNAPSHOT"

--- Get all snapshots of the current directory's btrfs subvolume
--- @param current_dir string
--- @return table|nil snapshots Array of {subvol, dir_path, creation_time} or nil
--- @return string|nil error Error message or SNAPSHOT_ERROR
local function get_btrfs_snapshots(current_dir)
    current_dir = current_dir or "."
    
    -- Step 1: Get the subvolume ID of current directory
    local output = Command("btrfs")
        :arg("inspect-internal")
        :arg("rootid")
        :arg(current_dir)
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()
    
    if not output or not output.status.success then
        return nil, "Not a btrfs filesystem or no permission"
    end
    
    local subvol_id = tonumber(output.stdout:match("^%s*(.-)%s*$"))
    if not subvol_id then
        return nil, "Could not get subvolume ID"
    end
    
    -- Step 2: Run the two main commands in parallel
    local btrfs_cmd = Command("btrfs"):arg("subvolume"):arg("list"):arg("-puqt"):arg("/")
        :stdout(Command.PIPED):stderr(Command.PIPED)
    
    local findmnt_cmd = Command("findmnt"):arg("-l"):arg("-Q"):arg('FSTYPE == "btrfs"')
        :arg("-o"):arg("SOURCE,TARGET")
        :stdout(Command.PIPED):stderr(Command.PIPED)
    
    local btrfs_child = btrfs_cmd:spawn()
    local findmnt_child = findmnt_cmd:spawn()
    
    if not btrfs_child or not findmnt_child then
        return nil, "Could not spawn commands"
    end
    
    local btrfs_output = btrfs_child:wait_with_output()
    local findmnt_output = findmnt_child:wait_with_output()

    if not btrfs_output or not btrfs_output.status.success then
        if btrfs_output and (btrfs_output.stderr:match("Operation not permitted") or 
                             btrfs_output.stderr:match("Permission denied")) then
            return nil, "Finding snapshots requires elevated privileges. Please ensure your user has permission to run btrfs commands."
        end
        return nil, "Could not get subvolume list"
    end
    
    if not findmnt_output or not findmnt_output.status.success then
        return nil, "Could not get mount information"
    end
    
    -- Step 3: Parse the outputs
    local subvols = parse_subvol_list(btrfs_output.stdout)
    local mounts = parse_findmnt(findmnt_output.stdout)
    
    -- Step 4: Check if we're in a snapshot (has a parent_uuid)
    local current_subvol = subvols[subvol_id]
    if not current_subvol then
        return nil, "Could not find current subvolume info"
    end
    
    if current_subvol.parent_uuid and current_subvol.parent_uuid ~= "-" then
        return nil, SNAPSHOT_ERROR
    end
    
    -- Step 5: Find all snapshots of the current subvolume
    -- Snapshots have parent_uuid matching our uuid
    local current_uuid = current_subvol.uuid
    local snapshot_infos = {}
    
    for id, subvol in pairs(subvols) do
        if subvol.parent_uuid == current_uuid then
            local snapshot_base_path = build_subvolume_path(id, subvols, mounts)
            if snapshot_base_path then
                table.insert(snapshot_infos, {
                    id = id,
                    path = subvol.path,
                    base_path = snapshot_base_path,
                })
            end
        end
    end
    
    -- Step 6: Calculate current directory's path within the subvolume
    -- Use the mount info we already have
    local current_subvol_path = current_subvol.path
    local mount_point = mounts[current_subvol_path]
    
    if not mount_point then
        return nil, "Could not find mount point for current subvolume"
    end
    
    -- Get absolute path of current directory
    output = Command("realpath")
        :arg(current_dir)
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()
    
    if not output or not output.status.success then
        return nil, "Could not resolve absolute path"
    end
    
    local abs_path = output.stdout:match("^[^\n]*")
    
    -- Calculate relative path from mount point
    local path_in_subvol = ""
    if abs_path:sub(1, #mount_point) == mount_point then
        path_in_subvol = abs_path:sub(#mount_point + 1)
        if path_in_subvol:sub(1, 1) == "/" then
            path_in_subvol = path_in_subvol:sub(2)
        end
    end
    
    -- Step 7: Get creation times in parallel
    local snapshot_jobs = {}
    for _, info in ipairs(snapshot_infos) do
        -- Build full path to same location in snapshot
        local dir_path = info.base_path
        if path_in_subvol ~= "" then
            dir_path = dir_path .. "/" .. path_in_subvol
        end
        
        table.insert(snapshot_jobs, {
            subvol = "/" .. info.path,
            dir_path = dir_path,
            base_path = info.base_path,
        })
    end
    
    -- Spawn all creation time queries in parallel
    local creation_time_children = {}
    for _, job in ipairs(snapshot_jobs) do
        local cmd = Command("btrfs"):arg("subvolume"):arg("show"):arg(job.base_path)
            :stdout(Command.PIPED):stderr(Command.PIPED)
        local child = cmd:spawn()
        if child then
            table.insert(creation_time_children, {
                child = child,
                job = job,
            })
        end
    end
    
    -- Collect results
    local snapshots = {}
    for _, entry in ipairs(creation_time_children) do
        local output = entry.child:wait_with_output()
        local creation_time = "Unknown"
        
        if output and output.status.success then
            for line in output.stdout:gmatch("[^\n]+") do
                local time = line:match("^%s*Creation time:%s+(.+)$")
                if time then
                    creation_time = time
                    break
                end
            end
        elseif output and (output.stderr:match("Operation not permitted") or output.stderr:match("Permission denied")) then
            return nil, "Finding snapshots requires elevated privileges. Please ensure your user has permission to run btrfs commands."
        end
        
        table.insert(snapshots, {
            subvol = entry.job.subvol,
            dir_path = entry.job.dir_path,
            creation_time = creation_time,
            -- TODO: When unique tab IDs are available, add:
            -- opened_in = nil  -- Will store unique tab ID
        })
    end
    
    -- Sort by creation time (most recent first)
    table.sort(snapshots, function(a, b)
        return parse_timestamp(a.creation_time) > parse_timestamp(b.creation_time)
    end)
    
    return snapshots
end

--------------------------------------------------------------------------------
-- Plugin UI Logic
--------------------------------------------------------------------------------

--- Get current working directory synchronously
local get_cwd = ya.sync(function()
    return tostring(cx.active.current.cwd)
end)

--- Toggle the UI visibility
local toggle_ui = ya.sync(function(self)
	if self.children then
		Modal:children_remove(self.children)
		self.children = nil
	else
		self.children = Modal:children_add(self, 10)
	end
	ui.render()
end)

--- Subscribe to plugin refresh events
local subscribe = ya.sync(function(self)
	ps.unsub("snapshots")
	ps.sub("snapshots", function() ya.emit("plugin", { self._id, "refresh" }) end)
end)

--- Update the snapshots list and reset cursor position
local update_snaps = ya.sync(function(self, snaps)
    if snaps then
        self.snaps = snaps
        self.cursor = math.max(0, math.min(self.cursor or 0, #self.snaps - 1))
    end
    -- If snaps is nil, keep the old snaps (e.g., when in a snapshot tab)
	ui.render()
end)

--- Get the currently selected snapshot
local active_snap = ya.sync(function(self) 
    return self.snaps[self.cursor + 1] 
end)

--- Update cursor position with bounds checking
local update_cursor = ya.sync(function(self, cursor)
	if #self.snaps == 0 then
		self.cursor = 0
	else
		self.cursor = ya.clamp(0, self.cursor + cursor, #self.snaps - 1)
	end
	ui.render()
end)

--- Handle enter key press - open snapshot in new tab
local handle_enter = ya.sync(function(self)
    local active = self.snaps[self.cursor + 1]
    if not active or not active.dir_path then
        return
    end
    
    -- Open snapshot in new tab
    ya.emit("tab_create", { active.dir_path })
    
    -- TODO: When unique tab IDs are available, mark snapshot as opened:
    -- local tab_id = get_unique_tab_id()
    -- self.snaps[self.cursor + 1].opened_in = tab_id
    
    ui.render()
end)

--------------------------------------------------------------------------------
-- Plugin Definition
--------------------------------------------------------------------------------

local M = {
	keys = {
		{ on = "q", run = "quit" },
		{ on = "<Esc>", run = "quit" },
		{ on = "<Enter>", run = { "enter", "quit" } },

		{ on = "k", run = "up" },
		{ on = "j", run = "down" },

		{ on = "<Up>", run = "up" },
		{ on = "<Down>", run = "down" },
	},
}

function M:new(area)
	self:layout(area)
	return self
end

function M:layout(area)
	local chunks = ui.Layout()
		:constraints({
			ui.Constraint.Percentage(10),
			ui.Constraint.Percentage(80),
			ui.Constraint.Percentage(10),
		})
		:split(area)

	local chunks = ui.Layout()
		:direction(ui.Layout.HORIZONTAL)
		:constraints({
			ui.Constraint.Percentage(10),
			ui.Constraint.Percentage(80),
			ui.Constraint.Percentage(10),
		})
		:split(chunks[2])

	self._area = chunks[2]
end

-- Main entry point
function M:entry(job)
	if job.args[1] == "refresh" then
		return update_snaps(M.obtain())
	end

	toggle_ui()
	update_snaps(M.obtain())
	subscribe()

	local tx1, rx1 = ya.chan("mpsc")
	local tx2, rx2 = ya.chan("mpsc")
	function producer()
		while true do
			local cand = self.keys[ya.which { cands = self.keys, silent = true }] or { run = {} }
			for _, r in ipairs(type(cand.run) == "table" and cand.run or { cand.run }) do
				tx1:send(r)
				if r == "quit" then
					toggle_ui()
					return
				end
			end
		end
	end

	function consumer()
		repeat
			local run = rx1:recv()
			if run == "quit" then
				tx2:send(run)
				break
			elseif run == "up" then
				update_cursor(-1)
			elseif run == "down" then
				update_cursor(1)
			elseif run == "enter" then
				handle_enter()
			else
				tx2:send(run)
			end
		until not run
	end

	ya.join(producer, consumer)
end

function M:reflow() return { self } end

function M:redraw()
	local rows = {}
	for i, s in ipairs(self.snaps or {}) do
		-- Create a row for each snapshot showing snapshot number and creation time
		-- Extract snapshot number from subvol path (e.g., "11" from "/persistent/.snapshots/11/snapshot")
		local snap_num = s.subvol:match("/snapshots/(%d+)/")
        
        -- TODO: When unique tab IDs are available, check if snapshot is opened:
        -- local is_opened = s.opened_in ~= nil
        -- local style = is_opened and ui.Style():bg("green") or ui.Style()
        local style = ui.Style()
        
		rows[#rows + 1] = ui.Row({
			ui.Span(snap_num or tostring(i)):style(style),
			ui.Span(s.creation_time):style(style),
		})
	end

	return {
		ui.Clear(self._area),
		ui.Border(ui.Edge.ALL)
			:area(self._area)
			:type(ui.Border.ROUNDED)
			:style(ui.Style():fg("blue"))
			:title(ui.Line("Snapshots"):align(ui.Align.CENTER)),
		ui.Table(rows)
			:area(self._area:pad(ui.Pad(1, 2, 1, 2)))
			:header(ui.Row({ "Snapshot", "Creation Time" }):style(ui.Style():bold()))
			:row(self.cursor)
			:row_style(ui.Style():fg("blue"):underline())
			:widths {
				ui.Constraint.Length(10),
				ui.Constraint.Percentage(90),
			},
	}
end

--- Obtain snapshots for the current directory
--- Returns nil if we're in a snapshot (to preserve current snap list)
function M.obtain()
	local cwd = get_cwd()
	local snapshots, err = get_btrfs_snapshots(tostring(cwd))
	
	if not snapshots then
        -- If we're in a snapshot, return nil to keep the old snap list
        if err == SNAPSHOT_ERROR then
            return nil
        end
        -- For other errors, show notification
		M.fail("Failed to get snapshots: %s", err or "Unknown error")
		return {}
	end
	
	return snapshots
end

function M.fail(...) 
	ya.notify { 
		title = "Snapshots", 
		content = string.format(...), 
		timeout = 10, 
		level = "error" 
	} 
end

function M:click() end

function M:scroll() end

function M:touch() end

return M
