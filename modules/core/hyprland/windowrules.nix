{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # General Window Rules
    windowrulev2 = [
      "suppressevent maximize, class:.*"  # Ignore maximize requests from apps
      "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"  # Fix XWayland dragging issues

      # Example window rules (uncomment and modify as needed)
      # "float, class:^(kitty)$"
      # "float, title:^(File Manager)$"
      # "move 10 10, class:^(Firefox)$"
    ];

    # Workspace Rules (Uncomment and modify if needed)
    # workspace = [
    #   "w[tv1], gapsout:0, gapsin:0"
    #   "f[1], gapsout:0, gapsin:0"
    # ];
    
    # Assign applications to workspaces
    # "onworkspace:w[tv1], class:^(firefox)$"
    # "onworkspace:w[tv1], class:^(vlc)$"
    # "onworkspace:2, class:^(ghostty)$"
  };
}

