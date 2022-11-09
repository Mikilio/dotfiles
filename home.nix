{ config, lib, inputs, ...}:

{
    imports = [ ./modules/default.nix ];
    config.modules = {

        nvim.enable = true;
	packages.enable = true;

    };
}
