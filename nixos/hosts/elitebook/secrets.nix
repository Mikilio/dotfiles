{
  ezConfigs,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.default
  ];
  config = {
    sops = {
      age = {
        keyFile = "/root/.config/sops/age/keys.txt";
      };
      defaultSopsFile = "${ezConfigs.root}/secrets/hosts/elitebook.yaml";
      secrets = {
        usbguard-rules = {};
        u2f-mappings = {
          neededForUsers = true;
          path = "/home/mikilio/.config/Yubico/u2f_keys";
          owner = config.users.users.mikilio.name;
        };
      };
    };
  };
}
