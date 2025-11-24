{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.gitRepos;
  inherit (lib) mkIf mkOption mkEnableOption types;

  # Build a JSON string for the activation script to consume safely.
  reposJson = builtins.toJSON (map (r: {
      path = r.path;
      url = r.url;
      branch = r.branch or "main";
      enforceBranch = r.enforceBranch or true;
      worktrees = map (wt: {
        path = wt.path;
        branch = wt.branch;
      }) (r.worktrees or []);
    })
    cfg.repos);

  ensureScript = pkgs.writeShellScript "ensure-git-repos" ''
    set -euo pipefail

    jq=${pkgs.jq}/bin/jq
    git=${pkgs.git}/bin/git
    ssh_bin=${pkgs.openssh}/bin/ssh

    # Ensure git uses a known-good ssh binary even in minimal activation environments
    export GIT_SSH="$ssh_bin"

    echo '${reposJson}' | "$jq" -c '.[]' | while IFS= read -r repo; do
      path=$(echo "$repo" | "$jq" -r '.path')
      url=$(echo  "$repo" | "$jq" -r '.url')
      branch=$(echo "$repo" | "$jq" -r '.branch')
      enforce_branch=$(echo "$repo" | "$jq" -r '.enforceBranch // "true"')

      if [ -z "$path" ] || [ -z "$url" ]; then
        echo "[git-repos] Skipping entry with missing path or url: $repo" >&2
        continue
      fi

      # Clone if missing
      if [ ! -d "$path/.git" ]; then
        mkdir -p "$(dirname "$path")"
        "$git" clone --origin origin --branch "$branch" "$url" "$path" \
          || "$git" clone "$url" "$path"
      fi

      if [ -d "$path/.git" ]; then
        # Ensure remote URL is correct
        current_url=$("$git" -C "$path" remote get-url origin 2>/dev/null || echo "")
        if [ "$current_url" != "$url" ]; then
          if "$git" -C "$path" remote | grep -qx origin; then
            "$git" -C "$path" remote set-url origin "$url" || true
          else
            "$git" -C "$path" remote add origin "$url" || true
          fi
        fi

        # Fetch and attempt to fast-forward
        "$git" -C "$path" fetch --all --prune || true

        current_branch=$("$git" -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
        if [ "$enforce_branch" = "true" ] && [ "$current_branch" != "$branch" ] && [ -n "$branch" ]; then
          "$git" -C "$path" fetch origin "$branch" || true
          # Attempt a non-destructive switch first, fallback to tracking remote
          "$git" -C "$path" switch --quiet "$branch" 2>/dev/null \
            || "$git" -C "$path" checkout -q -B "$branch" "origin/$branch" 2>/dev/null \
            || echo "[git-repos] Warning: unable to switch $path to $branch (possibly uncommitted changes or branch missing)" >&2
        fi

        # Fast-forward if possible (ignore failures)
        "$git" -C "$path" pull --ff-only 2>/dev/null || true

        # Ensure declared worktrees
        echo "$repo" | "$jq" -c '.worktrees[]?' | while IFS= read -r wt; do
          wt_path=$(echo "$wt" | "$jq" -r '.path')
          wt_branch=$(echo "$wt" | "$jq" -r '.branch')
          if [ -z "$wt_path" ] || [ -z "$wt_branch" ]; then
            continue
          fi

          if [ ! -d "$wt_path/.git" ]; then
            mkdir -p "$(dirname "$wt_path")"
            "$git" -C "$path" fetch origin "$wt_branch" || true

            # Avoid adding if branch already in use by any worktree of this repo
            if "$git" -C "$path" worktree list --porcelain | grep -q "^branch refs/heads/$wt_branch$"; then
              echo "[git-repos] Branch $wt_branch already used by another worktree of $path; skipping $wt_path" >&2
            else
              "$git" -C "$path" worktree add -B "$wt_branch" "$wt_path" "origin/$wt_branch" 2>/dev/null \
                || "$git" -C "$path" worktree add -b "$wt_branch" "$wt_path" 2>/dev/null \
                || echo "[git-repos] Warning: unable to create worktree $wt_path for branch $wt_branch" >&2
            fi
          fi
        done
      fi
    done
  '';
in {
  options.my.gitRepos = {
    enable = mkEnableOption "Ensure user git repositories are cloned and set to specified branches and worktrees";
    repos = mkOption {
      type = with types;
        listOf (submodule ({...}: {
          options = {
            name = mkOption {
              type = with types; nullOr str;
              default = null;
              description = "Friendly name (optional)";
            };
            path = mkOption {
              type = types.str;
              example = "/home/matthew/GithubProjects/example";
              description = "Absolute target directory for the repository";
            };
            url = mkOption {
              type = types.str;
              description = "Git clone URL (e.g., git@github.com:owner/repo.git)";
            };
            branch = mkOption {
              type = types.str;
              default = "main";
              description = "Branch to keep checked out in the main worktree";
            };
            enforceBranch = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to enforce that the main worktree stays on the configured branch";
            };
            worktrees = mkOption {
              type = with types;
                listOf (submodule ({...}: {
                  options = {
                    path = mkOption {
                      type = types.str;
                      description = "Worktree directory path";
                    };
                    branch = mkOption {
                      type = types.str;
                      description = "Branch for this worktree";
                    };
                  };
                }));
              default = [];
              description = "Additional worktrees to create for this repository";
            };
          };
        }));
      default = [];
      description = "List of repositories to manage";
    };
  };

  config = mkIf cfg.enable {
    # Run after files are in place so paths like ~/GithubProjects exist
    home.activation.manageGitRepos = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${ensureScript}
    '';
  };
}
