{
  self,
  inputs,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: {
    apps.hm = {
      type = "app";
      program = "${pkgs.writeShellScriptBin "hm" ''
        #unlock gnupg-agent
        echo "test" | gpg2 --sign --batch --no-tty --pinentry-mode ask -o /dev/null
        #do it
        export PATH=${pkgs.lib.makeBinPath [pkgs.git pkgs.coreutils pkgs.nix pkgs.jq pkgs.unixtools.hostname]}
        declare -A profiles=(["mikilio@homestation"]="desktop")
        profile="minimal"
        if [[ -n ''${profiles[$(whoami)@$(hostname)]:-} ]]; then
          profile=''${profiles[$(whoami)@$(hostname)]}
        fi
        if [[ "''${1:-}" == profile ]]; then
          echo $profile
          exit 0
        fi
        ${inputs.hm.packages.${pkgs.system}.home-manager}/bin/home-manager --flake "${self}#$profile" "$@"
      ''}/bin/hm";
    };

    apps.default = config.apps.hm;
  };
}
