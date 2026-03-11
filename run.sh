#!/bin/bash
set -e

# Load environment variables from .env
if [ ! -f .env ]; then
  echo "Error: .env file not found. Create one based on .env.example."
  exit 1
fi

export $(grep -v '^#' .env | xargs)

# Default device to chrome if not specified
DEVICE=${1:-chrome}

echo "Running Avalokan on: $DEVICE"

flutter run -d "$DEVICE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
