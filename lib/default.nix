{
  inputs,
  withSystem,
  ...
}:
# personal lib
let
  inherit (inputs.nixpkgs) lib;

  colorlib = import ./colors.nix lib;
  theme = import ./theme {inherit colorlib lib;};
in {
  imports = [
    {
      _module.args = {
        inherit theme;
      };
    }
  ];
}
