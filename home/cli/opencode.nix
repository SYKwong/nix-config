{
  programs.fish.interactiveShellInit = ''
    set -gx CLOUDFLARE_ACCOUNT_ID "4f09751ab0746bf06f0a01821fc0c3e9"
  '';

  programs.opencode = {
    enable = true;
    settings = {
      "permission" = {
        "read" = "allow";
        "list" = "allow";
        "glob" = "allow";
        "grep" = "allow";
        "edit" = "allow";
        "write" = "allow";
        "bash" = {
          "*" = "ask";
          "git status *" = "allow";
          "git diff *" = "allow";
          "docker *" = "ask";
          "curl *" = "ask";
          "wget *" = "ask";
          "ssh *" = "deny";
          "sudo *" = "deny";
          "rm *" = "ask";
          "git commit *" = "deny";
          "git push *" = "deny";
          "git reset --hard *" = "deny";
          "git clean *" = "deny";
        };
      };
      provider = {
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
  };
}
