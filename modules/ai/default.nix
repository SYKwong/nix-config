{
  pkgs,
  lib,
  localLLM,
  iGPUOnly,
  ...
}:

{
  services.ollama = lib.mkIf localLLM {
    enable = true;
    # Default to using vulkan as it works well enough for all GPU/iGPU
    package = pkgs.ollama-vulkan;
    environmentVariables = lib.mkIf iGPUOnly {
      OLLAMA_IGPU_ENABLE = "1";
    };
  };
}
