{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.git-repo-manager;
  gitRepos = import ./git-repositories.nix;

  # Helper function to create activation scripts for each repository
  mkRepoActivation = name: repo: ''
    echo "Managing git repository: ${name}"

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "${repo.path}")"

    # Function to clone or update a repository
    manage_repo() {
      local repo_url="$1"
      local repo_path="$2"
      local repo_branch="$3"
      local repo_name="$4"

      if [ -d "$repo_path/.git" ]; then
        echo "  Updating repository: $repo_name"
        cd "$repo_path"

        # Fetch latest changes
        ${pkgs.git}/bin/git fetch --all --prune 2>/dev/null || echo "    Warning: Failed to fetch $repo_name"

        # Check if we're on the correct branch
        current_branch=$(${pkgs.git}/bin/git branch --show-current 2>/dev/null || echo "")
        if [ "$current_branch" != "$repo_branch" ]; then
          ${
      if (repo.enforceBranch or true)
      then ''
        echo "    Switching to branch: $repo_branch"
        ${pkgs.git}/bin/git checkout "$repo_branch" 2>/dev/null || echo "    Warning: Failed to checkout $repo_branch for $repo_name"
      ''
      else ''
        echo "    Branch enforcement disabled for $repo_name. Keeping current branch: $current_branch"
      ''
    }
        fi

        # Pull latest changes (fast-forward only)
        ${pkgs.git}/bin/git pull --ff-only origin "$repo_branch" 2>/dev/null || echo "    Warning: Failed to pull $repo_name (may have local changes)"

      else
        echo "  Cloning repository: $repo_name"
        ${pkgs.git}/bin/git clone "$repo_url" "$repo_path" || echo "    Warning: Failed to clone $repo_name"

        if [ -d "$repo_path/.git" ]; then
          cd "$repo_path"
          # Checkout the specified branch if it's not the default
          if [ "$repo_branch" != "main" ] && [ "$repo_branch" != "master" ]; then
            ${pkgs.git}/bin/git checkout "$repo_branch" 2>/dev/null || echo "    Warning: Failed to checkout $repo_branch for $repo_name"
          fi
        fi
      fi

      # Set proper ownership
      chown -R matthew:users "$repo_path" 2>/dev/null || true
    }

    # Manage main repository
    manage_repo "${repo.url}" "${repo.path}" "${repo.branch}" "${name}"

    ${optionalString (repo ? worktrees) (concatMapStringsSep "\n" (worktree: ''
        # Manage worktree: ${worktree.name}
        if [ -d "${repo.path}/.git" ]; then
          cd "${repo.path}"

          # Check if worktree already exists
          if ! ${pkgs.git}/bin/git worktree list | grep -q "${worktree.path}"; then
            echo "  Creating worktree: ${worktree.name}"
            mkdir -p "$(dirname "${worktree.path}")"
            ${pkgs.git}/bin/git worktree add "${worktree.path}" "${worktree.branch}" 2>/dev/null || echo "    Warning: Failed to create worktree ${worktree.name}"
          else
            echo "  Updating worktree: ${worktree.name}"
            if [ -d "${worktree.path}" ]; then
              cd "${worktree.path}"
              ${pkgs.git}/bin/git fetch --all --prune 2>/dev/null || echo "    Warning: Failed to fetch worktree ${worktree.name}"
              ${pkgs.git}/bin/git pull --ff-only origin "${worktree.branch}" 2>/dev/null || echo "    Warning: Failed to pull worktree ${worktree.name}"
            fi
          fi

          # Set proper ownership for worktree
          chown -R matthew:users "${worktree.path}" 2>/dev/null || true
        fi
      '')
      repo.worktrees)}

    echo "  Finished managing: ${name}"
    echo
  '';

  # Create activation script for all repositories
  repoActivationScript = concatStringsSep "\n" (mapAttrsToList mkRepoActivation gitRepos.gitRepositories);
in {
  options.services.git-repo-manager = {
    enable = mkEnableOption "Git repository manager";

    user = mkOption {
      type = types.str;
      default = "matthew";
      description = "User that owns the git repositories";
    };

    syncOnBoot = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to sync repositories on system boot";
    };
  };

  config = mkIf cfg.enable {
    # Create a systemd service for git repository management
    systemd.services.git-repo-sync = {
      description = "Git Repository Synchronization";
      wantedBy = mkIf cfg.syncOnBoot ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        User = "root"; # Need root to create directories and set ownership
        WorkingDirectory = "/home/${cfg.user}";
        RemainAfterExit = true;
      };

      script = ''
        echo "Starting git repository synchronization..."

        # Ensure the user exists and has a home directory
        if ! id "${cfg.user}" &>/dev/null; then
          echo "Error: User ${cfg.user} does not exist"
          exit 1
        fi

        # Ensure GithubProjects directory exists
        mkdir -p /home/${cfg.user}/GithubProjects
        chown ${cfg.user}:users /home/${cfg.user}/GithubProjects

        # Set up git identity if not already configured
        if [ ! -f /home/${cfg.user}/.gitconfig ]; then
          echo "Setting up default git configuration..."
          sudo -u ${cfg.user} ${pkgs.git}/bin/git config --global user.name "Matthew Mangano" || true
          sudo -u ${cfg.user} ${pkgs.git}/bin/git config --global user.email "matthew.mangano@gmail.com" || true
          sudo -u ${cfg.user} ${pkgs.git}/bin/git config --global init.defaultBranch main || true
          sudo -u ${cfg.user} ${pkgs.git}/bin/git config --global pull.rebase true || true
          sudo -u ${cfg.user} ${pkgs.git}/bin/git config --global push.autoSetupRemote true || true
        fi

        ${repoActivationScript}

        echo "Git repository synchronization completed!"
      '';
    };

    # Create a timer for periodic sync (optional)
    systemd.timers.git-repo-sync = {
      description = "Timer for git repository synchronization";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      wantedBy = ["timers.target"];
    };

    # Add git to system packages
    environment.systemPackages = with pkgs; [
      git
      openssh # For SSH key authentication
    ];
  };
}
