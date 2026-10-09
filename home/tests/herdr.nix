{
  inputs,
  lib,
  pkgs,
  self,
}: let
  inherit (import ./lib.nix {inherit inputs lib pkgs;}) mkHomeTest loginScript;
  herdr = lib.getExe pkgs.herdr;
  userCtl = cmd: "su - alice -c 'XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user ${cmd}'";
in
  mkHomeTest {
    name = "home-herdr";
    module = self.homeModules.herdr;
    modules = [
      ({...}: {
        # 32 GiB of installed memory, 50% of which is 16384M.
        hardware.facter.reportPath = ./fixtures/facter.json;
        hardware.facter.enable = lib.mkForce false;
      })
    ];
    homeModules = [
      ({config, ...}: {
        programs.herdr.enable = true;

        # Reads the option back out so the test can assert the real path.
        xdg.configFile."herdr-attach-path".text = config.programs.herdr.attachCommand;

        # graphical-session.target refuses a manual start, so the test pulls it
        # in as a dependency the way a real session does.
        systemd.user.services.herdr-test-session = {
          Unit.Wants = ["graphical-session.target"];
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils}/bin/true";
          };
          Install.WantedBy = ["default.target"];
        };
      })
    ];
    testScript =
      loginScript
      + ''
        # The socket path is a profile variable, not a user manager one.
        machine.fail("su - alice -c 'grep -q HERDR_SOCKET_PATH ~/.config/environment.d/10-home-manager.conf'")

        # 50% of 32 GiB, derived from the facter report rather than the board's
        # max_size of 64 GiB.
        machine.succeed("su - alice -c 'grep -q MemoryMax=16384M ~/.config/systemd/user/herdr.slice'")
        machine.succeed("su - alice -c 'grep -q MemoryLow=1G ~/.config/systemd/user/herdr.slice'")
        machine.succeed("su - alice -c 'grep -q ManagedOOMPreference=avoid ~/.config/systemd/user/herdr.slice'")
        machine.succeed("su - alice -c 'grep -q ManagedOOMMemoryPressure=kill ~/.config/systemd/user/herdr.slice'")

        # The server runs in the slice, and starts when the user session does.
        machine.succeed("su - alice -c 'grep -qF Slice=herdr.slice ~/.config/systemd/user/herdr.service'")
        machine.succeed("su - alice -c 'grep -q After=graphical-session.target ~/.config/systemd/user/herdr.service'")
        machine.succeed("su - alice -c 'test -L ~/.config/systemd/user/graphical-session.target.wants/herdr.service'")

        # ExecStart embeds hm-session-vars.sh, so an unrelated session-variable
        # change rewrites the unit and would otherwise make every rebuild
        # stop+start the server. keep-old stops sd-switch from doing that.
        machine.succeed("su - alice -c 'grep -qF X-SwitchMethod=keep-old ~/.config/systemd/user/herdr.service'")

        # The attach wrapper is a real, executable file.
        machine.succeed("su - alice -c 'test -x \"$(cat ~/.config/herdr-attach-path)\"'")

        # The unit is up, the user manager applied the slice ceiling, and the
        # server answers on the socket.
        # graphical-session.target refuses a manual start, so a helper unit
        # pulls it in the way a session does.
        machine.succeed("${userCtl "start herdr-test-session.service"}")
        machine.wait_for_unit("herdr.service", "alice")
        machine.succeed("${userCtl "is-enabled herdr.service"}")
        machine.succeed("${userCtl "show herdr.slice -p MemoryMax | grep -q MemoryMax=17179869184"}")
        machine.succeed("${userCtl "show herdr.service -p ControlGroup | grep -q herdr.slice"}")
        machine.succeed(
            "su - alice -c 'HERDR_SOCKET_PATH=$HOME/.config/herdr/herdr.sock ${herdr} api snapshot'"
        )

        # The serve wrapper sourced the profile, which the manager's own
        # environment does not have.
        machine.fail("${userCtl "show-environment | grep -q HERDR_SOCKET_PATH"}")
        main_pid = machine.succeed("${userCtl "show herdr.service -p MainPID --value"}").strip()
        server_env = machine.succeed(f"su - alice -c 'tr \"\\0\" \"\\n\" < /proc/{main_pid}/environ'")
        assert "__HM_SESS_VARS_SOURCED=1" in server_env
        assert "HERDR_SOCKET_PATH=/home/alice/.config/herdr/herdr.sock" in server_env
      '';
  }
