{
  pkgs,
  lib,
  localLLM,
  ...
}:

{
  services.ollama = lib.mkIf localLLM {
    enable = true;
    package = pkgs.ollama-vulkan;
    environmentVariables = {
      OLLAMA_IGPU_ENABLE = "1";
    };
  };
}
