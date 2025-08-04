{inputs, ...}: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    #handled by ez-config
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
  };
}
