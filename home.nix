{ config, lib, inputs, ...}:

{
  imports = [ ./modules];
  config.modules = {

    nvim.enable = true;
    vivaldi.enable = true;
    zathura.enable = true;
    packages.enable = true;
    environment.profile = "gnome";
  };
}
