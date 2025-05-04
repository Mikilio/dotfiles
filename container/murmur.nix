{
  config,
  ...
}:
{
  services = {
    murmur = {
      port = 2052;
      enable = true;
      openFirewall = true;
      bandwidth = 256000;
    };
  };
  networking.firewall.allowedFCPPorts = [ config.services.murmur.port ];
}
