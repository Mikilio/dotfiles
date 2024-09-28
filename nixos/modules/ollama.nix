{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.ollama;
in
{
  options.modules.ollama = pkgs.lib.mkOptional "Ollama";

  config = lib.mkIf cfg {
    services = {
      nextjs-ollama-llm-ui.enable = true;
      ollama = {
        enable = true;
        loadModels = [
          "llama3.2:latest"
        ];
        environmentVariables = {
          OLLAMA_ORIGINS = "moz-extension://*";
        };
      };
    };
  };
}
