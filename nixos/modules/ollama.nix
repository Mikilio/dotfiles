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
          "codellama:latest"
          "qwen2.5-coder:latest"
        ];
        rocmOverrideGfx = "11.0.2";
        environmentVariables = {
          OLLAMA_ORIGINS = "moz-extension://*";
        };
      };
    };
  };
}
