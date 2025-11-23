#!/usr/bin/env bash
set -euo pipefail

# Hugging Face text generation agent (Inference API)

if [[ -z "${HUGGINGFACE_API_TOKEN:-}" ]]; then
  echo "Error: HUGGINGFACE_API_TOKEN is not set" >&2
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

# Placeholder model; change to your preferred hosted text-generation model
MODEL="gpt2"

JSON_PAYLOAD=$(jq -Rs '. | {inputs: ., parameters: {max_new_tokens: 200}}' <<< "$PROMPT")

RESPONSE=$(curl -sS -X POST \
  -H "Authorization: Bearer $HUGGINGFACE_API_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api-inference.huggingface.co/models/$MODEL" \
  -d "$JSON_PAYLOAD")

# The Inference API may return either an error object or an array of results
if echo "$RESPONSE" | jq -e '.[0].generated_text' >/dev/null 2>&1; then
  echo "$RESPONSE" | jq -r '.[0].generated_text'
else
  echo "Error: Hugging Face API call failed" >&2
  echo "$RESPONSE" | jq -r '.error // . | tostring' >&2 || echo "$RESPONSE" >&2
  exit 1
fi
