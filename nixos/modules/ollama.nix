{
  lib,
  config,
  ...
}: {
  config = {
    services = {
      ollama = {
        enable = true;
        loadModels = [
          "codellama:13b-instruct"
          "deepseek-coder:6.7b"
          "gemma3:12b-it-qat"
          "qwen3:14b"
        ];
        rocmOverrideGfx = "10.3.0";
        environmentVariables = {
          OLLAMA_ORIGINS = "moz-extension://*";
        };
      };
    };
  };
}
