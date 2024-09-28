{ ezConfigs, ... }:
{
  sops = {
    age = {
      keyFile = "/root/.config/sops/age/keys.txt";
    };
    defaultSopsFile = "${ezConfigs.root}/secrets/hosts/elitebook.yaml";
    secrets = {
      usbguard-rules = { };
    };
  };
}
