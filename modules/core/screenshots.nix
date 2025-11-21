{
  config,
  pkgs,
  ...
}: let
  screenshotRegion = pkgs.writeShellScriptBin "screenshot-region" ''
    #!/usr/bin/env bash
    set -euo pipefail

    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/screenshot-$(date +'%Y%m%d-%H%M%S').png"

    grim -g "$(slurp)" "$file"

    # Optional: open in swappy for quick annotation if available
    if command -v swappy >/dev/null 2>&1; then
      swappy -f "$file" || true
    fi
  '';

  screenshotFull = pkgs.writeShellScriptBin "screenshot-full" ''
    #!/usr/bin/env bash
    set -euo pipefail

    dir="$HOME/Pictures/Screenshots"
    mkdir -p "$dir"
    file="$dir/screenshot-full-$(date +'%Y%m%d-%H%M%S').png"

    grim "$file"
  '';

  screenrecordToggle = pkgs.writeShellScriptBin "screenrecord-toggle" ''
    #!/usr/bin/env bash
    set -euo pipefail

    state_file="/tmp/wl-screenrec.pid"

    if [[ -f "$state_file" ]] && kill -0 "$(cat "$state_file")" 2>/dev/null; then
      # Stop current recording
      kill "$(cat "$state_file")" || true
      rm -f "$state_file"
      exit 0
    fi

    dir="$HOME/Videos"
    mkdir -p "$dir"
    file="$dir/record-$(date +'%Y%m%d-%H%M%S').mp4"

    # Start a new recording with audio in the background
    wl-screenrec --audio -f "$file" &
    echo $! > "$state_file"
  '';
in {
  environment.systemPackages = [
    screenshotRegion
    screenshotFull
    screenrecordToggle
  ];
}
