/*
  Once in the Machine, you will also need to setup pacman's keyring, which you can do with the following:
  ```
  curl -Lo archlinux-keyring.tar.zst https://archlinux.org/packages/core/any/archlinux-keyring/download
  tar -xf archlinux-keyring.tar.zst
  sudo pacman-key --init
  sudo pacman-key --populate --populate-from usr/share/pacman/keyrings/
  ```
*/
{ pkgs, ... }:
let
  # Fetch Arch's PKGBUILD sources
  pacman-files = pkgs.fetchFromGitLab {
    domain = "gitlab.archlinux.org";
    group = "ArchLinux/Packaging";
    owner = "Packages";
    repo = "pacman";
    rev = "1a52f2e1d641587a1514c99b96d839368076288d";
    hash = "sha256-A/YwCZVNjmCR7yR1q7kYuLQwQDw661GWOIpxMfkhzOY=";
  };
in
{
  environment = {
    etc = {
      # And use the defaults from it
      "makepkg.conf".source = pacman-files + "/makepkg.conf";
      "pacman.conf".source = pacman-files + "/pacman.conf";

      # Put pacman's vendored files in the right place
      "makepkg.conf.d".source = pkgs.pacman + "/etc/makepkg.conf.d";

      # Setup the mirrorlist the default config expects (Arch's provided one is all commented out womp womp)
      "pacman.d/mirrorlist".text = ''
        Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
      '';
    };

    # Install pacman itself
    systemPackages = [ pkgs.pacman ];
  };

  # Create the database directory since pacman doesn't by itself???
  systemd.tmpfiles.rules = [
    "d /var/lib/pacman - - - -"
  ];
}
