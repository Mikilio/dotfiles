{ moduleWithSystem
, flake-parts-lib
, inputs
, self
, lib
, config
, ...
}:
with lib;

let

  inherit (flake-parts-lib) importApply;
  modules = builtins.map (mod:
    importApply mod { inherit inputs moduleWithSystem;}
  ) [
    ./applications
    ./shells
    ./desktop
  ];


in {

  imports = [
    ./profiles
    ./bootstrap.nix
  ];

  flake.homeManagerModules = {
    preferences = hm_modules: {
      imports = modules;
    };
  };
}
