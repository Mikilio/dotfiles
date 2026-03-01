{
  inputs,
  ezConfigs,
  ...
}: {
  imports = [
    inputs.sops-nix.nixosModules.default
  ];
  config = {
    sops = {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = "${ezConfigs.root}/secrets/hosts/workstation.yaml";
      secrets = {
        usbguard-rules = { };
      };
    };
  };
}
