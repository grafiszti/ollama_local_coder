#!/bin/bash
# Generate opencode.json from opencode.json.template using variables in .env

set -euo pipefail

# ---------------------------------------------------------------------------
# Helper: extract an unquoted, unspaced value from .env
#   • skips comment lines (leading #)
#   • returns the LAST matching uncommented line
#   • strips surrounding double-quotes / single-quotes
#   • trims leading/trailing whitespace
# ---------------------------------------------------------------------------
env_var() {
    local key="$1"
    local val

    # grep only uncommented lines, take the last match, cut value after =
    val=$(grep -E "^[[:space:]]*${key}[[:space:]]*=" ".env" \
        | tail -n 1 \
        | sed 's/^[^=]*=[[:space:]]*//' \
        | sed 's/[[:space:]]*$//')

    # strip surrounding quotes (both single and double)
    val="${val#\"}"
    val="${val%\"}"
    val="${val#\'}"
    val="${val%\'}"

    echo "$val"
}

# ---------------------------------------------------------------------------
# Validate .env exists
# ---------------------------------------------------------------------------
if [ ! -f .env ]; then
    echo "Error: .env file not found" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Validate template exists
# ---------------------------------------------------------------------------
if [ ! -f templates/opencode.json.template ]; then
    echo "Error: templates/opencode.json.template not found" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Extract and validate required variables
# ---------------------------------------------------------------------------
MODEL_NAME=$(env_var "MODEL_NAME")
MODEL_NAME_ALIAS=$(env_var "MODEL_NAME_ALIAS")
PORT=$(env_var "PORT_EXTERNAL")
SEARXNG_SECRET=$(env_var "SEARXNG_SECRET")

if [ -z "$MODEL_NAME" ]; then
    echo "Error: MODEL_NAME not set in .env" >&2
    exit 1
fi

if [ -z "$MODEL_NAME_ALIAS" ]; then
    echo "Error: MODEL_NAME_ALIAS not set in .env" >&2
    exit 1
fi

if [ -z "$PORT" ]; then
    echo "Error: PORT_EXTERNAL not set in .env" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Escape for sed (handle /, \, & in values)
# ---------------------------------------------------------------------------
sed_escape() {
    local val="$1"
    # escape \, /, and & for sed
    val="${val//\\/\\\\}"
    val="${val//\//\\/}"
    val="${val//&/\\&}"
    echo "$val"
}

MODEL_NAME_ESC=$(sed_escape "$MODEL_NAME")
MODEL_NAME_ALIAS_ESC=$(sed_escape "$MODEL_NAME_ALIAS")
PORT_ESC=$(sed_escape "$PORT")
SEARXNG_SECRET_ESC=$(sed_escape "$SEARXNG_SECRET")

# ---------------------------------------------------------------------------
# Generate opencode.json
# ---------------------------------------------------------------------------
sed -e "s/{{MODEL_NAME}}/${MODEL_NAME_ESC}/g" \
    -e "s/{{MODEL_NAME_ALIAS}}/${MODEL_NAME_ALIAS_ESC}/g" \
    -e "s/{{PORT_EXTERNAL}}/${PORT_ESC}/g" \
    -e "s/{{SEARXNG_SECRET}}/${SEARXNG_SECRET_ESC}/g" \
    templates/opencode.json.template > opencode.json

echo "Successfully generated opencode.json with:"
echo "  MODEL_NAME:       $MODEL_NAME"
echo "  MODEL_NAME_ALIAS: $MODEL_NAME_ALIAS"
echo "  PORT:             $PORT"
echo "  SEARXNG_SECRET:   ${SEARXNG_SECRET:+set}${SEARXNG_SECRET:-empty}"
