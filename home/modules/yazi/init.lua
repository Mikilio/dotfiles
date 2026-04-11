Status:children_add(function(self)
  local h = self._current.hovered
  if h and h.link_to then
    return " -> " .. tostring(h.link_to)
  else
    return ""
  end
end, 3300, Status.LEFT)

Header:children_add(function()
  if ya.target_family() ~= "unix" then
    return ""
  end
  return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ":"):fg("blue")
end, 500, Header.LEFT)

require("gvfs"):setup({
  which_keys = "tnseriaopldhfucgmbjvk",

  -- (Optional) Table of blacklisted devices. These devices will be ignored in any actions
  -- List of device properties to match, or a string to match the device name:
  -- https://github.com/boydaihungst/gvfs.yazi/blob/master/main.lua#L144
	-- blacklist_devices = { { name = "Wireless Device", scheme = "mtp" }, { scheme = "file" }, "Device Name"},

  save_path = os.getenv("HOME") .. "/.local/share/yazi/gvfs.private",

  save_path_automounts = os.getenv("HOME") .. "/.local/share/yazi/gvfs_automounts.private",

  password_vault = "keyring",

  save_password_autoconfirm = true,
})
