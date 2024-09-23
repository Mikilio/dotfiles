{
  pkgs,
  ezModules,
  modulesPath,
  ...
}@args:
{
  imports =
    [
      (modulesPath + "installation-cd-graphical-gnome.nix")
    ]
    ++ (with ezModules; [
      networking
    ]);

  networking.hostName = "nixos-installer";
  environment.systemPackages = with pkgs; [ neovim sbctl disko];
}
