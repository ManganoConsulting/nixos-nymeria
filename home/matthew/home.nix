{ config, pkgs, ... }:
{
  imports = [
    ../../modules/core/hyprland/appearance.nix
    ../../modules/core/hyprland/animations.nix
    ../../modules/core/hyprland/autostart.nix
    ../../modules/core/hyprland/input.nix
    ../../modules/core/hyprland/keybindings.nix
    ../../modules/core/hyprland/monitors.nix
    ../../modules/core/hyprland/programs.nix
    ../../modules/core/hyprland/windowrules.nix
  ];

  home.username = "matthew";
  home.homeDirectory = "/home/matthew";
  
  # Packages for enhanced shell experience
  home.packages = with pkgs; [
    # Modern replacements for common commands
    eza          # Modern replacement for ls
    bat          # Modern replacement for cat
    ripgrep      # Modern replacement for grep (rg)
    fd           # Modern replacement for find
    fzf          # Fuzzy finder
    starship     # Cross-shell prompt
    zoxide       # Smart directory jumper (z command)
    
    # Additional useful tools
    htop         # Process monitor
    tree         # Directory tree viewer
    wget         # File downloader
    curl         # HTTP client
    jq           # JSON processor
    
    # Development tools
    git          # Version control
    gh           # GitHub CLI
    
    # System utilities
    neofetch     # System info
    zip          # Archive tool
    unzip        # Archive tool
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
    initExtra = ''
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
    # You can add your git config here later
    # userName = "Your Name";
    # userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
  
  # Enhanced directory navigation and environment management
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  
  # Better file manager integration (if using a file manager)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

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
      "text/html" = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/http" = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/https" = [ "vivaldi-stable.desktop" ];
      # optional but helpful
      "x-scheme-handler/about" = [ "vivaldi-stable.desktop" ];
      "x-scheme-handler/unknown" = [ "vivaldi-stable.desktop" ];
    };
  };

  # Match NixOS release used for this home config
  home.stateVersion = "25.11";
}
