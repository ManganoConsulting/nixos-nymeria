#!/usr/bin/env bash
set -euo pipefail

# Ollama local model agent (chat-style)

if [[ $# -gt 0 ]]; then
  PROMPT="$*"
else
  PROMPT="$(cat)"
fi

if [[ -z "$PROMPT" ]]; then
  echo "Error: prompt is empty" >&2
  exit 1
fi

MODEL="llama3.1"

JSON_PAYLOAD=$(jq -Rs --arg model "$MODEL" '. | {model: $model, messages: [{role: "user", content: .}]}' <<< "$PROMPT")

RESPONSE=$(curl -sS -X POST \
  -H "Content-Type: application/json" \
  http://127.0.0.1:11434/api/chat \
  -d "$JSON_PAYLOAD")

if ! echo "$RESPONSE" | jq -e '.message.content' >/dev/null 2>&1; then
  echo "Error: Ollama API call failed" >&2
  echo "$RESPONSE" | jq -r '.error // . | tostring' >&2 || echo "$RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE" | jq -r '.message.content'
