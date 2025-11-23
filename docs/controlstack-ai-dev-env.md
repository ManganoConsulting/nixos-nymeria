# ControlStackAI AI Dev Environment

## Philosophy
The environment is designed to be "AI-Native", meaning AI tools are first-class citizens, not just plugins.

## Current Stack
- **OS**: NixOS (Reproducible)
- **Shell**: zsh + starship
- **Terminal**: Warp (AI-integrated)
- **Editor**: Neovim (with AI plugins) / VS Code
- **AI CLI**: `ai-cli-workspace` (Custom wrappers)

## Roadmap
- Standardize on a set of local models (Ollama) and cloud APIs.
- Create a "Context Server" that feeds OS state to the AI agent.
- Automate git workflows with AI (commit messages, PR reviews).

## TODOs
- [ ] Verify `ai-cli-workspace` functionality on `controlstackos`
- [ ] Integrate `gh` CLI with AI
