{
  config,
  pkgs,
  ...
}: {
  #### AI tooling for ControlStackAI OS
  #
  # This module provides system-level tools needed by the unified AI CLI
  # workspace and the ControlStackAI Console web UI. It intentionally does
  # **not** contain any real secrets.

  environment.systemPackages = with pkgs; [
    # Base HTTP / JSON tooling used by all CLI agents
    curl
    jq
    git

    # Node.js runtime for the ai-web/ server (Express)
    nodejs

    # Python + Hugging Face helpers for local / scripted use
    python312
    python312Packages.transformers
    python312Packages.huggingface-hub

    # Local LLM backend
    ollama

    # ControlStackAI CLI Tools
    (pkgs.stdenv.mkDerivation {
      name = "controlstack-ai-cli";
      src = ../../ai-cli-workspace;
      installPhase = ''
        mkdir -p $out/bin
        cp ai ai-git ai-one-shot $out/bin/
        cp -r agents $out/bin/
        chmod +x $out/bin/*
        chmod +x $out/bin/agents/*
      '';
    })
  ];

  #### API key environment scaffold (example only — do NOT set real keys here)
  #
  # These names are what the ai-cli-workspace/ scripts expect. Set them via
  # your preferred secret mechanism (sops-nix, /etc/environment, direnv, etc.).
  #
  # Example (do NOT uncomment with real keys):
  # environment.sessionVariables = {
  #   OPENAI_API_KEY = "<set via secret manager or /etc/environment>";
  #   ANTHROPIC_API_KEY = "<set via secret manager>";
  #   GEMINI_API_KEY = "<set via secret manager>";
  #   HUGGINGFACE_API_TOKEN = "<set via secret manager>";
  #   # OLLAMA typically doesn’t need a key.
  # };

  #### Ollama service (local LLM backend)
  #
  # This is an example minimal configuration. Uncomment and adjust
  # acceleration based on your GPU stack.
  #
  # services.ollama = {
  #   enable = true;
  #   # acceleration = "cuda"; # or "rocm" or "none"
  #   # listenAddress = "127.0.0.1:11434";
  # };
}
