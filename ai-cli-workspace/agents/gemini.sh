#!/usr/bin/env bash
set -euo pipefail

# Google Gemini text model agent

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "Error: GEMINI_API_KEY is not set" >&2
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

MODEL="gemini-1.5-flash"

JSON_PAYLOAD=$(jq -Rs '. | {contents: [{parts: [{text: .}]}]}' <<< "$PROMPT")

RESPONSE=$(curl -sS -X POST \
  -H "Content-Type: application/json" \
  "https://generativelanguage.googleapis.com/v1beta/models/$MODEL:generateContent?key=$GEMINI_API_KEY" \
  -d "$JSON_PAYLOAD")

if ! echo "$RESPONSE" | jq -e '.candidates[0].content.parts[0].text' >/dev/null 2>&1; then
  echo "Error: Gemini API call failed" >&2
  echo "$RESPONSE" | jq -r '.error.message // . | tostring' >&2 || echo "$RESPONSE" >&2
  exit 1
fi

echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text'
