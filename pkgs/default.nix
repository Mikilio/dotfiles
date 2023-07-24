let
  packageList = [
    ./repl
    ./gdb-frontend
    ./linux-enable-ir-emitter
    ./waveform
    ./mscore-ttf
  ];
in {
  systems = ["x86_64-linux"];

  perSystem = {pkgs, ...}: with builtins; {

    _module.args.packageList = packageList;

    packages = listToAttrs (
      map (p: {
        name = baseNameOf p;
        value = pkgs.callPackage p {};
        }
      ) packageList
    );
    legacyPackages = pkgs;
  };
}
