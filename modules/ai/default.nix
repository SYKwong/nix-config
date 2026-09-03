{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.custom.ai;
in
{
  options.custom.ai = {
    enable = lib.mkEnableOption "local Ollama LLM service";
    iGPUOnly = lib.mkEnableOption "iGPU optimizations for Ollama" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      # Default to using vulkan as it works well enough for all GPU/iGPU
      package = pkgs.ollama-vulkan;
      environmentVariables = lib.mkIf cfg.iGPUOnly {
        OLLAMA_IGPU_ENABLE = "1";
      };
    };
  };
}
