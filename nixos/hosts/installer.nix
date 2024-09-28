{
  inputs,
  pkgs,
  ezModules,
  modulesPath,
  ...
}@args:
{
  imports =
    [
      (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ]
    ++ (with ezModules; [
      # networking
    ]);

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "nixos-installer";
  environment.systemPackages = with pkgs; [ neovim sbctl disko];
}
