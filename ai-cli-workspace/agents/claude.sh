#!/usr/bin/env bash
set -euo pipefail

# Anthropic Claude messages API agent

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "Error: ANTHROPIC_API_KEY is not set" >&2
  exit 1
fi

if [[ $# -gt 0 ]]; then
  PROMPT="$*"
else
  PROMPT="$(cat)"
fi

if [[ -z "$PROMPT" ]]; then
  echo "Error: prompt is empty" >&2
  exit 1
fi

JSON_PAYLOAD=$(jq -Rs --arg model "claude-3-5-sonnet-latest" '.
  | {model: $model, max_tokens: 800, messages: [{role: "user", content: [{type: "text", text: .}]}]}' <<< "$PROMPT")

RESPONSE=$(curl -sS -X POST \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  https://api.anthropic.com/v1/messages \
  -d "$JSON_PAYLOAD")

if ! echo "$RESPONSE" | jq -e '.content[0].text' >/dev/null 2>&1; then
  echo "Error: Anthropic API call failed" >&2
  echo "$RESPONSE" | jq -r '.error.message // . | tostring' >&2 || echo "$RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE" | jq -r '.content[0].text'
