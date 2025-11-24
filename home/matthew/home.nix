{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/core/hyprland/appearance.nix
    ../../modules/core/hyprland/animations.nix
    ../../modules/core/hyprland/autostart.nix
    ../../modules/core/hyprland/hyprlock.nix
    ../../modules/core/hyprland/hyprpaper.nix
    ../../modules/core/hyprland/input.nix
    ../../modules/core/hyprland/keybindings.nix
    ../../modules/core/hyprland/monitors.nix
    ../../modules/core/hyprland/programs.nix
    ../../modules/core/hyprland/windowrules.nix
    ../../modules/home/git-repos.nix
  ];

  home.username = "matthew";
  home.homeDirectory = "/home/matthew";

  # Packages for enhanced shell experience
  home.packages = with pkgs; [
    # Modern replacements for common commands
    eza # Modern replacement for ls
    bat # Modern replacement for cat
    ripgrep # Modern replacement for grep (rg)
    fd # Modern replacement for find
    fzf # Fuzzy finder
    zoxide # Smart directory jumper (z command)

    # Additional useful tools
    htop # Process monitor
    tree # Directory tree viewer
    wget # File downloader
    curl # HTTP client
    jq # JSON processor

    # Notifications
    libnotify # provides notify-send
    swaynotificationcenter # swaync + swaync-client
    hyprlock
    hyprpaper
    
    # Overlay tools
    wofi

    # Development tools
    git # Version control
    gh # GitHub CLI
    delta # Git diff pager
    ghostty # Terminal emulator

    # Kubernetes/Helm tooling
    kubectl
    kubernetes-helm
    k9s
    kubectx
    kustomize
    stern

    # System utilities
    neofetch # System info
    zip # Archive tool
    unzip # Archive tool
  ];

  # Enable Hyprland config under Home Manager
  wayland.windowManager.hyprland.enable = true;

  # User-level tooling and shell configs
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Shell aliases for better experience
    shellAliases = {
      ll = "eza -la --icons";
      ls = "eza --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
      tree = "eza --tree --icons";
    };

    # Additional zsh configuration
    initContent = ''
      # Load completions early
      autoload -U compinit && compinit

      # Better history settings
      setopt EXTENDED_HISTORY
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt HIST_VERIFY

      # Better completion
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu select

      # Fuzzy finding keybindings
      bindkey '^R' fzf-history-widget
      bindkey '^T' fzf-file-widget
      bindkey '^[c' fzf-cd-widget

      # Warp Auto-Warpify hook (persist the snippet Warp suggests)
      # Paste the Warp-provided auto-warpify snippet here so it persists across rebuilds.
      # After you successfully Warpify this host from your client, copy the
      # snippet Warp shows and place it below. Example placeholder only:
      # [ -n "$WARP_IS_REMOTE" ] && true
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$all$character";
      add_newline = false;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold cyan";
      };

      git_branch = {
        symbol = "🌱 ";
        style = "bold purple";
      };

      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        deleted = "x";
        style = "bold red";
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold blue";
      };

      python = {
        symbol = "🐍 ";
        style = "bold yellow";
        detect_extensions = ["py" "pyc" "pyo" "pyd" "pyw" "pyi"];
        detect_files = ["requirements.txt" "setup.py" "pyproject.toml" "Pipfile" ".python-version" "tox.ini"];
        detect_folders = ["venv" ".venv" "env" ".env" "virtualenv"];
        format = "via [$symbol$pyenv_prefix($version) (\\($virtualenv\\)) ]($style)";
      };

      rust = {
        symbol = "🦀 ";
        style = "bold red";
      };

      nodejs = {
        symbol = "⬢ ";
        style = "bold green";
      };
    };
  };

  # Fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
    colors = {
      "bg+" = "#3c3836";
      "fg+" = "#ebdbb2";
      "hl" = "#83a598";
      "hl+" = "#83a598";
    };
  };

  # Better Git integration
  programs.git = {
    enable = true;

    # New-style configuration API
    settings = {
      user = {
        name = "Matthew Mangano";
        email = "matthew.mangano@gmail.com";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      color.ui = "auto";
      diff.colorMoved = "zebra";

      # SSH commit signing (recommended)
      gpg.format = "ssh";
      user.signingkey = "${config.home.homeDirectory}/.ssh/github_id.pub";
      commit.gpgsign = true;
      gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";

      includeIf."gitdir:${config.home.homeDirectory}/GithubProjects/ManganoConsulting/".path = "${config.xdg.configHome}/git/work.gitconfig";
    };

    # Global gitignore patterns
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      "node_modules"
      "dist"
      "target"
      ".venv"
      ".direnv"
      ".env"
      ".idea"
      ".vscode"
    ];
  };

  # Configure delta using the dedicated module
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  # Placeholder for work-specific Git config; edit to set your work email.
  xdg.configFile."git/work.gitconfig".text = ''
    [user]
      email = matthew@mangano-consulting.com
  '';

  # Generate allowed_signers from your SSH public key; used for local verification
  home.activation.sshAllowedSigners = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail
    conf_dir="$HOME/.config/git"
    pub="$HOME/.ssh/github_id.pub"
    file="$conf_dir/allowed_signers"
    mkdir -p "$conf_dir"

    if [ -f "$pub" ]; then
      key_type=$(cut -d' ' -f1 "$pub")
      key_data=$(cut -d' ' -f2 "$pub")
      key_comment=$(cut -d' ' -f3- "$pub" || true)
      {
        printf "matthew.mangano@gmail.com %s %s" "$key_type" "$key_data"
        [ -n "''${key_comment:-}" ] && printf " %s" "$key_comment"
        printf "\n"
        printf "matthew@mangano-consulting.com %s %s" "$key_type" "$key_data"
        [ -n "''${key_comment:-}" ] && printf " %s" "$key_comment"
        printf "\n"
      } > "$file"
      chmod 0644 "$file"
    else
      echo "[git-sign] Warning: $pub not found; skipping allowed_signers generation" >&2
    fi
  '';

  # SSH managed declaratively
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = ["~/.ssh/config.d/*.conf"];
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = ["${config.home.homeDirectory}/.ssh/github_id"];
      };
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = ["${config.home.homeDirectory}/.ssh/glab"];
      };
      "*" = {};
    };
    extraConfig = ''
      AddKeysToAgent yes
      ServerAliveInterval 60
      ServerAliveCountMax 3
      ControlMaster auto
      ControlPath ~/.ssh/cm-%r@%h:%p
      ControlPersist 10m
    '';
  };

  # Ensure ~/.ssh/config.d exists (without committing secrets)
  home.file.".ssh/config.d/.keep".text = "";

  # Start OpenSSH agent for key caching
  services.ssh-agent.enable = true;

  # Enhanced directory navigation and environment management
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Better file manager integration (if using a file manager)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Autostart swaync (Sway Notification Center) as a user service
  services.swaync.enable = true;

  # Manage Ghostty terminal config via Home Manager module
  programs.ghostty = {
    enable = true;
    settings = {
      "font-family" = "JetBrainsMono Nerd Font";
      "font-size" = 12;
      theme = "Gruvbox Dark Hard";
      "copy-on-select" = true;
    };
  };

  # k9s configuration (minimal)
  xdg.configFile."k9s/config.yml".text = ''
    k9s:
      liveViewAutoRefresh: true
      ui:
        skin: default
        enableMouse: true
      logger:
        tail: 200
        buffer: 10000
  '';

  # Ensure ~/.kube/configs exists without tracking secrets
  home.file.".kube/configs/.keep".text = "";

  # Default editor/user session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
    BROWSER = "vivaldi"; # ensure CLI tools use Vivaldi
  };

  # Set Vivaldi as the default browser/handler for web links and HTML
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = ["vivaldi-stable.desktop"];
      "x-scheme-handler/http" = ["vivaldi-stable.desktop"];
      "x-scheme-handler/https" = ["vivaldi-stable.desktop"];
      # optional but helpful
      "x-scheme-handler/about" = ["vivaldi-stable.desktop"];
      "x-scheme-handler/unknown" = ["vivaldi-stable.desktop"];
    };
  };

  # Standardize XDG user directories and ensure they exist
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
  };

  # Secrets management (sops-nix): optional, guarded if file exists
  sops =
    if builtins.pathExists ../../secrets/home.yaml
    then {
      defaultSopsFile = ../../secrets/home.yaml;
      # Use an Age key file in your home directory
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    }
    else {};

  # Match NixOS release used for this home config
  my.gitRepos = {
    enable = true;
    repos = import ../repos.nix;
  };

  home.stateVersion = "25.11";
}
