# Secrets with sops-nix (Age)

This repo is wired to use sops-nix for declarative secrets.

Quick start

1) Generate an Age key (recommended location)
   - If you do not have an Age key yet:
     age-keygen -o ~/.config/sops/age/keys.txt
   - Show the public key (do not commit the private key):
     grep 'public key' ~/.config/sops/age/keys.txt
   Copy the public key value (age1...).

2) Create your secrets file
   - Copy the example and edit it with your real values (still plaintext for now):
     cp secrets/home.yaml.example secrets/home.yaml
     $EDITOR secrets/home.yaml

3) Encrypt the file with your Age public key
   - Replace AGE_PUBLIC_KEY below with your actual age1... key:
     sops --age AGE_PUBLIC_KEY --encrypt --in-place secrets/home.yaml

4) Build/apply as usual
   nix build .#nixosConfigurations.nymeria.config.system.build.toplevel --no-link
   sudo nixos-rebuild switch --flake .#nymeria

Notes
- The Home Manager config only uses secrets if secrets/home.yaml exists, so builds don’t fail before you add it.
- Encrypted files (created by sops) are safe to commit to git.
- Your Age private key must remain private at ~/.config/sops/age/keys.txt (not in git).

What is provisioned by default
- cloudflare_token -> materialized to ~/.config/cloudflare/token for CLI tools that read a token from a file.

Extending secrets
- Add more keys to secrets/home.yaml and reference them in home/matthew/home.nix under sops.secrets.<name>.path
- Example:
  In YAML: kubeconfig: "...base64 or inline yaml..."
  In HM:   sops.secrets.kubeconfig.path = "${config.home.homeDirectory}/.kube/config";

Troubleshooting
- If decryption fails at activation, ensure the Age key exists and matches the public key used to encrypt.
- To rotate recipients, re-encrypt with a new public key:
  sops --age NEW_AGE_PUBLIC_KEY --encrypt --in-place secrets/home.yaml
