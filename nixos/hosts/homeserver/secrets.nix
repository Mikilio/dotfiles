{
  config,
  self,
  ...
}: {
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    defaultSopsFile = "${self.outPath}/secrets/groups/homeserver.yaml";
    secrets = {
      tailscale = {};
      nextcloud_adminpass = {
        key = "nextcloud/adminpass";
        owner = "nextcloud";
        mode = "0770";
      };
      nextcloud_dbpass = {
        key = "nextcloud/dbpass";
        owner = "nextcloud";
        mode = "0770";
      };
      nextcloud_ssl_crt = {
        key = "nextcloud/ssl/crt";
        owner = "nginx";
      };
      nextcloud_ssl_key = {
        key = "nextcloud/ssl/key";
        owner = "nginx";
      };
    };
  };
}
