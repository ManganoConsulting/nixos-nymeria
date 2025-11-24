{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ai-web;
  aiWebSrc = "${config.home.homeDirectory}/GithubProjects/nixos-nymeria/ai-web";
in {
  options.services.ai-web = {
    enable = mkEnableOption "ControlStackAI Web Console";
    port = mkOption {
      type = types.int;
      default = 3000;
      description = "Port to listen on";
    };
  };

  config = mkIf cfg.enable {
    # Install desktop entry
    xdg.desktopEntries.dev-workbench = {
      name = "ControlStackAI Workbench";
      comment = "AI-Native Development Console";
      exec = "vivaldi http://localhost:3000";
      icon = "utilities-terminal";
      terminal = false;
      categories = [ "Development" ];
      settings = {
        Keywords = "ai;console;workbench;";
        StartupNotify = "true";
      };
    };

    systemd.user.services.ai-web = {
      Unit = {
        Description = "ControlStackAI Web Console";
        After = [ "network.target" ];
      };

      Service = {
        # Ensure 'ai' command is found in path
        # Point to the source files
        WorkingDirectory = "${aiWebSrc}";
        Environment = [
          "PATH=${config.home.profileDirectory}/bin:${pkgs.nodejs_22}/bin:/run/current-system/sw/bin:/usr/bin:/bin"
        ];
        ExecStart = "${pkgs.nodejs_22}/bin/node server.js";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
