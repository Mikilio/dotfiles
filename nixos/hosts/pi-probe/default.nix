{
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.nixos-generators.nixosModules.sd-aarch64
    inputs.nixos-hardware.nixosModules.raspberry-pi-3
  ];

  nixpkgs = {
    system = "aarch64-linux";
    # hostPlatform = "aarch64-linux";
    # buildPlatform = "x86_64-linux";
  };

  sdImage.compressImage = false;

  networking.hostName = "raspberrypi";

  services = {
    kismet = {
      enable = true;
      settings = {
        source.wlu1u4 = {
          name = "wlu1u4_24ghz";
          channelhop = true;
          channels = [1 6 11];
        };
        source.wlu1u5 = {
          name = "wlu1u5_5ghz";
          channelhop = true;
          channels = [36 149];
        };
      };
    };
    openssh.enable = true;
  };
  systemd = {
    services.kismet-restart = {
      description = "Restarts Kismet";
      script = "/run/current-system/sw/bin/systemctl restart kismet.service";
      serviceConfig.Type = "oneshot";
    };

    timers.kismet-restart = {
      timerConfig = {
        OnBootSec = 0;
        OnUnitActiveSec = "10min";
        AccuracySec = "1us";
        Unit = "kismet-restart.service";
      };
      wantedBy = ["timers.target"];
    };
  };
  disabledModules = [
    "profiles/base.nix"
  ];

  users.users = {
    root = {
      password = "root";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYPjdpzOZCLJfSGaeMo7yYBmTTVSnjf04aB3K74qZN9zOBotyBmLqD+SzVBrvbmGH3byRZF1V5bWdckc9ttdeJnLGJBtBNpBoCEb7V9AufzUC6njka2pvw8yIrOJZmK7JHK/IY21Wjsagu10f4OdUWF+CRevLmECOK0CJQmzbpjksFqVB9vaCI6fTBm0ZD+/AezXideg4FDBnfzjvT/0WEJbYj9yV6UO7rNIx7mYIErCnTg3PUUMuNz1By3pUGBjXnhDogW9KgrDqGDYbkqalxiNOW35D0QyxiIBhqy96B1Irt+dIQPG2qj6uAsMqfAyycGyZ34QukxKbudE/j+F/JlmGAfB3wbS1zaIyASd3vV0nO8zp2fQcyyP2wkjYe/qB9QFnNDh6/OUANKtMdXwFL94ZYJd4ZVwxsVZPdFlCS34Jf10o4P0rXAEcsQplsHFo0bjxn5yySwjEl26HZKBKd7PYQ7hb/zMCVroqcmBLoqGLD5vDaeZ3EMvTIHw6Gumbg6TggLopCzdwNiUqYdqelXwVC/mdpdyOYP/aBzMuN7FzOkehC4p99Pn3tiS+saqmU6em5y4l+U722J9fuKppYIB1VvZY8sDLQlxXepUykNzj0wwJse9fcgZ8X2P48F4gg8OvjZJ/Efyygvi6xsFoSmsP5itC0PIUG95aLhE78vQ== cardno:23_674_753"
      ];
    };
  };

  system = {
    stateVersion = "25.11";
  };
}
