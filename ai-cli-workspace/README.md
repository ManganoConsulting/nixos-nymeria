# Nymeria AI CLI Workspace

This directory contains a unified AI CLI toolkit, Git-aware helpers, and documentation for the Nymeria AI Console web UI.

## 1. Environment and API keys

1. Copy the example environment file:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your own API keys (never commit this file):

   ```bash
   export OPENAI_API_KEY="..."
   export ANTHROPIC_API_KEY="..."
   export GEMINI_API_KEY="..."
   export HUGGINGFACE_API_TOKEN="..."
   ```

3. Load the environment in your shell before using the CLI or web UI:

   ```bash
   source .env
   ```

## 2. NixOS integration

The system module `modules/core/ai-tools.nix` provides:

- CLI tooling: `curl`, `jq`, `git`, `nodejs_22`, and Python + Hugging Face helpers.
- A commented scaffold for `environment.sessionVariables` showing the expected API key names.
- A commented example `services.ollama` configuration for running local models.

To build and activate the updated system configuration for host `nymeria`:

```bash
sudo nixos-rebuild switch --flake .#nymeria
```

You can also build or test without switching:

```bash
sudo nixos-rebuild build --flake .#nymeria
sudo nixos-rebuild test --flake .#nymeria
```

## 3. Unified AI CLI

From the repository root or within `ai-cli-workspace/`:

```bash
./ai-cli-workspace/ai openai "Explain Nix flakes"
./ai-cli-workspace/ai claude "Review this function for edge cases: ..."

echo "Write a unit test for X" | ./ai-cli-workspace/ai gemini
```

Backends:

- `openai` → OpenAI Chat Completions (`gpt-4.1-mini` placeholder model).
- `claude` → Anthropic Claude (`claude-3-5-sonnet-latest`).
- `gemini` → Google Gemini (`gemini-1.5-flash`).
- `huggingface` / `hf` → Hugging Face Inference API (placeholder `gpt2` model).
- `ollama` → Local Ollama instance (default `llama3.1`), listening on `127.0.0.1:11434`.

## 4. One-shot helper

`ai-one-shot` reads the prompt from stdin and sends it to a single backend (default `openai`, overridable via `AI_BACKEND`):

```bash
echo "Summarize this log" | ./ai-cli-workspace/ai-one-shot

AI_BACKEND=claude echo "Draft a commit message for the current diff" | ./ai-cli-workspace/ai-one-shot
```

## 5. Git-integrated helper: `ai-git`

Run from the root of a Git repository to let an AI model inspect your current status and diff.

Examples:

```bash
./ai-cli-workspace/ai-git explain
./ai-cli-workspace/ai-git explain claude "Focus on files under modules/core"
./ai-cli-workspace/ai-git patch "Refactor for better error handling"
```

Behavior:

- Collects `git status --short` and `git diff` (truncated if extremely large).
- Constructs a single prompt that includes the status, diff, and your request.
- In `explain` mode: asks the model for a plain-text explanation and improvement suggestions.
- In `patch` mode: asks the model to output **only** a unified diff patch.
- For `patch`:
  - The patch is saved to `ai-cli-workspace/ai.patch`.
  - The patch is printed to stdout for review.
  - Nothing is applied automatically.

To apply a generated patch manually:

```bash
git apply ai-cli-workspace/ai.patch
```

## 6. Nymeria AI Console (web UI)

The web UI lives in `ai-web/` and uses the same CLI wrapper under the hood.

### Start the server

Ensure `node` and `express` are available (e.g. via Nix and `npm install express` in `ai-web/`), then run:

```bash
cd ai-web
node server.js
```

By default the server listens on:

- `http://localhost:3000`

### Use the console

Open the URL in a browser (desktop or mobile Safari on iPhone):

- Choose a backend from the dropdown (OpenAI, Claude, Gemini, Hugging Face, Ollama).
- Type or paste your prompt into the textarea.
- Click **Send** to issue a request via the underlying `ai` CLI script.
- The chat log shows `YOU` and `AI` messages in chronological order.

### Voice and speech

- **Voice** button:
  - Uses the browser Web Speech API (where available) to capture speech and append the recognized text into the prompt textarea.
  - On unsupported browsers, shows a simple "Voice input not supported" alert.
- **Speak Reply** button:
  - Uses `window.speechSynthesis` to read the last AI reply aloud, when supported.

These are browser-side only; no audio is sent to the server.

## 7. Web UI security notes

The Nymeria AI Console is intended for personal / development use.

Recommendations:

- Keep the server bound to localhost (the default).
- To reach it from a phone, prefer:
  - Tailscale (access your laptop on its tailnet address), or
  - A locked-down Cloudflare Tunnel with Access rules.
- Avoid exposing `http://localhost:3000` directly to the public Internet without an authenticated proxy.

## 8. Directory overview

- `ai-cli-workspace/`
  - `ai` – unified backend wrapper.
  - `ai-one-shot` – stdin-only helper.
  - `ai-git` – Git-aware explain/patch helper.
  - `agents/`
    - `openai.sh`, `claude.sh`, `gemini.sh`, `huggingface.sh`, `ollama.sh`.
  - `.env.example` – non-secret API key scaffold.
  - `README.md` – this document.
- `ai-web/`
  - `server.js` – Express server exposing `/chat` and serving static assets.
  - `public/index.html` – mobile-friendly Nymeria AI Console UI.
  - `public/app.js` – front-end logic (chat flow, voice input, text-to-speech).
