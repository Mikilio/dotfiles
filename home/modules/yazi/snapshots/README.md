# snapshots.yazi

A **BTRFS snapshot browser** for Yazi. Lists all snapshots of the current directory's subvolume and opens them in new tabs.

- **Works with any snapshot tool** — discovers snapshots using only BTRFS filesystem metadata and mount information. No assumptions about directory layout, naming conventions, or specific tools like Snapper or btrbk.
- **Linux only** — requires `btrfs-progs` and `util-linux`.
- **[Demo video placeholder]**

## Installation

```sh
ya pkg add YOUR_USERNAME/snapshots
```

## Usage

Add this to your `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on  = "S"
run = "plugin snapshots"
desc = "Browse BTRFS snapshots"
```

## Key bindings

| Key binding     | Alternate key  | Action           |
| --------------- | -------------- | ---------------- |
| <kbd>q</kbd>    | <kbd>Esc</kbd> | Quit the plugin  |
| <kbd>k</kbd>    | <kbd>↑</kbd>   | Move up          |
| <kbd>j</kbd>    | <kbd>↓</kbd>   | Move down        |
| <kbd>Enter</kbd>| -              | Open in new tab  |

## Requirements

```sh
# Debian/Ubuntu
sudo apt install btrfs-progs util-linux

# Fedora
sudo dnf install btrfs-progs util-linux

# Arch
sudo pacman -S btrfs-progs util-linux
```

## Security

This plugin **never uses `sudo` internally**. Yazi plugins can execute arbitrary commands, and elevating them would be unsafe. If `btrfs` requires elevated privileges on your system, it is **your responsibility** to decide how to grant them.

### Elevated access options

**Quick & unsafe (not recommended)**  
Run Yazi with `sudo`:

```sh
sudo yazi
```

**Recommended: polkit + restricted `btrfs` wrapper**

#### Polkit rule

Create `/etc/polkit-1/rules.d/50-btrfs-readonly.rules`:

```js
polkit.addRule(function(action, subject) {
  if (action.id == "org.freedesktop.policykit.exec" &&
      subject.isInGroup("disk")) {

    var program = action.lookup("program");
    var cmdline = action.lookup("command_line");
    var btrfsPath = "/usr/bin/btrfs";  // Adjust to your actual path

    if (program == btrfsPath) {
      var safeCommands = [
        " filesystem show",
        " filesystem df",
        " filesystem usage",
        " subvolume show",
        " subvolume list",
        " subvolume get-default",
        " device stats",
        " qgroup show",
        " quota rescan -s",
        " inspect-internal dump-tree",
        " inspect-internal dump-super",
        " inspect-internal inode-resolve",
        " inspect-internal logical-resolve",
        " inspect-internal subvolid-resolve",
        " inspect-internal rootid",
        " inspect-internal min-dev-size",
        " inspect-internal dump-csum",
        " inspect-internal map-swapfile",
        " property get",
        " property list",
        " scrub status",
        " balance status",
        " version"
      ];

      for (var i = 0; i < safeCommands.length; i++) {
        if (cmdline.indexOf(btrfsPath + safeCommands[i]) === 0) {
          return polkit.Result.YES;
        }
      }
    }
  }
});
```

#### Wrapper script

Create `~/.local/bin/btrfs` (per the XDG Base Directory Specification):

```sh
#!/bin/sh
exec pkexec /usr/bin/btrfs "$@"  # Adjust path to actual btrfs binary
```

```sh
chmod +x ~/.local/bin/btrfs
```

Ensure `~/.local/bin` is before system paths in your `$PATH`. If needed, add to your shell profile:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## Author's Note

A similar plugin exists: [time-travel.yazi](https://github.com/iynaix/time-travel.yazi). It didn't work on my system, so I built this one from scratch with different design goals:

- **No assumptions** — snapshots discovered purely from BTRFS metadata
- **Better UX** — menu-based UI, simple navigation, consistent state while exploring snapshots
- **Security first** — no automatic privilege escalation

The backend/UI interface is intentionally slim, making it easy to add other filesystems (ZFS, Bcachefs, LVM, etc.). **PRs welcome**!
## License

MIT licensed. See [LICENSE](LICENSE) file.
