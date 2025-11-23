# ControlStackAI AI Development Environment

## Vision
An "AI-first" development workflow where tools like Warp, Cursor, and local agents are first-class citizens.

## Current Tools
- **Terminal**: Warp (Primary).
- **Shell**: zsh + oh-my-zsh (configured in `programs.nix`).
- **Editor**: Neovim (configured via `nvf` in `modules/core/neovim`).

## Missing / Planned
- **Local LLM Serving**: Ollama / Llama.cpp service integration.
- **MCP Servers**: Matlab MCP, File system MCP.
- **Agentic Tools**: `ai-cli` scripts (already present in `ai-cli-workspace`, need better integration).
