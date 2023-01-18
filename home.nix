{ config, lib, inputs, ...}:

{
    imports = [ ./modules];
    config.modules = {

        nvim.enable = true;
        brave.enable = true;
        zathura.enable = true;
        packages.enable = true;

    };
}
