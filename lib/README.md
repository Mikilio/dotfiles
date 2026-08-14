# Lib

Various functions I use throughout the config:

- `readModules` — read a directory of modules into an attrset of paths (with `default.nix` handling)
- `injectInputs` — import each module, injecting the flake `inputs` into its function args
