{
  programs.fish.interactiveShellInit = ''
    set -gx CLOUDFLARE_ACCOUNT_ID "4f09751ab0746bf06f0a01821fc0c3e9"
  '';

  programs.opencode = {
    enable = true;
    settings.provider = {
      cloudflare-workers-ai = {
        models = {
          "@cf/qwen/qwen2.5-coder-32b-instruct" = {
            limit = {
              context = 32768;
              output = 4096;
            };
          };
        };
        options = {
          apiKey = "{file:/run/agenix/cloudflare-workers-ai-apikey}";
        };
      };
    };
  };
}
