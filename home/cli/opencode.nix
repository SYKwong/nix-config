{
  stylix.targets.opencode.enable = true;

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
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options.baseURL = "http://localhost:11434/v1";
          models = {
            "qwen3-coder:30b".name = "Qwen3 Coder 30B";
          };
        };

      };
    };
  };
}
