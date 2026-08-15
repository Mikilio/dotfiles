# Home-Manager module tests

One NixOS-VM test per home module (`home/modules/*`), auto-discovered by
`./default.nix` and exposed as flat flake checks `checks.<system>.home-<name>`.

Each test boots a NixOS VM, logs `alice` in on a virtual console, waits for
her home-manager user session, then probes the module's binaries, config files
and user services.

Run the whole suite (evaluates only):

```sh
nix flake check --no-build
```

Run one test in the VM:

```sh
nix build .#checks.x86_64-linux.home-git
```

## Broken modules

`nix flake check` refuses to evaluate derivations marked `meta.broken`, so
broken-marked tests are excluded from the `checks` set (see `default.nix`)
but remain in the tree to document the failure. These modules fail to
evaluate on the pinned inputs and should be fixed or removed:

| Test            | Reason                                                              |
| --------------- | ------------------------------------------------------------------- |
| `home-brave`    | `programs.brave` does not exist in pinned home-manager              |
| `home-firefox`  | references removed NUR addon `omnivore`                             |
| `home-hyprpanel`| `hyprland/hyprpanel.nix` is not a module and is not imported        |
| `home-keepassxc`| fails to evaluate                                                    |
| `home-private`  | references deleted `assets/`                                        |
| `home-vivaldi`  | `programs.vivaldi` does not exist in pinned home-manager            |

## Accommodations

Modules are tested in isolation, so test-local config fills in what the real
profiles provide. See `./lib.nix`:

- `loginScript` — boot, log in as alice, wait for the user session.
- `hyprlandAccommodation` — hyprland asserts `i18n.inputMethod.fcitx5.imList`
  has at least two entries.
- `hyprlandPackageAccommodation` — the module sets the hyprland package to
  `null` (UWSM provides it); the config generator needs a real package.
- `nurAccommodation` — `nixpkgs.overlays = [inputs.nur.overlays.default]` for
  modules referencing `pkgs.nur`.
- Repo overlay — modules referencing repo-overlay packages (`herdr-nvim`,
  `beets-xtractor`) import `self.nixosModules.overlays` in the system `modules`
  (it also pulls in the NUR overlay).
- `allowUnfree` — for modules pulling unfree firefox addons.
- `xdgPortal*Accommodation` — `xdg.portal.enable` asserts HM- and
  NixOS-level portal implementations plus `environment.pathsToLink`.
