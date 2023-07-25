{ stdenv
, lib
, fetchFromGitHub
, xterm
, coreutils
, makeWrapper
}:
  stdenv.mkDerivation {
    pname = "xdg-terminal-exec";
    version = "08049f6";
    src = fetchFromGitHub {
      owner = "Mikilio";
      repo = "xdg-terminal-exec";
      rev = "dde440874285f837ae55b433bd720642c5ad8fef";
      sha256 = "sha256-Hlw1dFGXFpj5qVozsI5dV9ZHhIp7MH9zENAqYCfpamk=";
    };
    nativeBuildInputs = [ makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      cp xdg-terminal-exec $out/bin/xdg-terminal-exec
      wrapProgram $out/bin/xdg-terminal-exec \
        --prefix PATH : ${lib.makeBinPath [ xterm coreutils]}
    '';
  }
