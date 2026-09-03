{ lib, osConfig, ... }:

{
  programs.nixvim.plugins.minuet = lib.mkIf osConfig.custom.ai.enable {
    enable = true;

    settings = {
      provider = "openai_fim_compatible";

      n_completions = 1;
      context_window = 512;

      virtualtext = {
        auto_trigger_ft = [ "*" ];

        keymap = {
          accept = "<C-CR>";
        };
      };

      provider_options = {
        openai_fim_compatible = {
          name = "Ollama";
          api_key = "TERM";
          end_point = "http://localhost:11434/v1/completions";

          model = "qwen2.5-coder:1.5b";

          optional = {
            max_tokens = 32;
            top_p = 0.9;
          };
        };
      };
    };
  };
}
