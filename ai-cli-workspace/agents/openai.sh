#!/usr/bin/env bash
set -euo pipefail

# OpenAI chat completion agent

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "Error: OPENAI_API_KEY is not set" >&2
  exit 1
fi

if [[ $# -gt 0 ]]; then
  PROMPT="$*"
else
  # Read full prompt from stdin
  PROMPT="$(cat)"
fi

if [[ -z "$PROMPT" ]]; then
  echo "Error: prompt is empty" >&2
  exit 1
fi

JSON_PAYLOAD=$(jq -Rs --arg model "gpt-4.1-mini" '.
  | {model: $model, messages: [{role: "user", content: .}], max_tokens: 800}' <<< "$PROMPT")

RESPONSE=$(curl -sS -X POST \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  https://api.openai.com/v1/chat/completions \
  -d "$JSON_PAYLOAD")

# Fail fast on HTTP or API errors
if ! echo "$RESPONSE" | jq -e '.choices[0].message.content' >/dev/null 2>&1; then
  echo "Error: OpenAI API call failed" >&2
  echo "$RESPONSE" | jq -r '.error.message // . | tostring' >&2 || echo "$RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE" | jq -r '.choices[0].message.content'
