{ezConfigs, ...}: {
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = "${ezConfigs.root}/secrets/hosts/elitebook.yaml";
    secrets = {
      u2f_mappings.neededForUsers = true;
    };
  };
}
