{ config, lib, inputs, ...}:

{
    imports = [ ./modules];
    config.modules = {

        nvim.enable = true;
        brave.enable = true;
        packages.enable = true;

    };
}
