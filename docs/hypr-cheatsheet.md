# Shortcut Cheat-Sheet

A quick-reference overlay for Hyprland keybindings.

## Usage
Press **SUPER + F1** to toggle the cheat sheet.

## Configuration
- **Content**: Edit `modules/core/hyprland/scripts/cheatsheet.txt` in your repo to update the list.
- **Script**: `modules/core/hyprland/scripts/cheatsheet_overlay.sh` handles the display logic.
- **Launcher**: Uses `wofi` by default.

## Note
This cheat sheet is **semi-dynamic**. It reads from a text file that is installed to `~/.config/hypr/scripts/cheatsheet.txt`. 
You must manually update the source text file when you change keybindings in `keybindings.nix`.
