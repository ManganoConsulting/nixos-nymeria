{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ai-web;
  aiWebSrc = ../../../ai-web;
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
        Environment = "PATH=${config.home.profileDirectory}/bin:${pkgs.nodejs_22}/bin:${pkgs.system}/sw/bin:/usr/bin:/bin";
        # Point to the source files
        WorkingDirectory = "${aiWebSrc}";
        # Use nixpkgs express
        Environment = "NODE_PATH=${pkgs.nodePackages.express}/lib/node_modules";
        ExecStart = "${pkgs.nodejs_22}/bin/node server.js";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
