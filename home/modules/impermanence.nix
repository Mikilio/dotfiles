{
  config,
  lib,
  inputs,
  ...
}: {
  config = {
    home.persistence."/persistent/storage" = {
      directories = [
        {
          directory = ".local/state";
          mode = "0755";
        }
      ];
    };
    home.persistence."/persistent/cache" = {
      directories = [
        {
          directory = ".local/share/containers";
          mode = "0755";
        }
      ];
    };
  };
}
