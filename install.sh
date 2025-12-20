#!/bin/bash
# Wrapper script that retries setup.sh up to 10 times on failure
# Handles intermittent network issues (GitHub rate limits, connection timeouts, etc.)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="${SCRIPT_DIR}/setup.sh"

MAX_RETRIES=15
RETRY_DELAY=2  # seconds between retries

if [[ ! -f "$SETUP_SCRIPT" ]]; then
    echo "Error: setup.sh not found at $SETUP_SCRIPT"
    exit 1
fi

if [[ ! -x "$SETUP_SCRIPT" ]]; then
    chmod +x "$SETUP_SCRIPT"
fi

attempt=1
while [[ $attempt -le $MAX_RETRIES ]]; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Running setup.sh (attempt $attempt/$MAX_RETRIES)..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if "$SETUP_SCRIPT"; then
        echo ""
        echo "✅ Setup completed successfully!"
        exit 0
    else
        exit_code=$?
        echo ""
        echo "❌ Setup failed with exit code $exit_code"
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            echo "⏳ Waiting ${RETRY_DELAY} seconds before retry..."
            sleep $RETRY_DELAY
            echo ""
        fi
    fi
    
    ((attempt++))
done

echo ""
echo "❌ Setup failed after $MAX_RETRIES attempts"
exit 1

