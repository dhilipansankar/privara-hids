#!/usr/bin/env bash
# Run the Privara Python backend (Flask + SQLite + psutil)
# Place this in the same folder as server.py, index.html, app.js.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Basic checks
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required but not installed."
  exit 1
fi

# Ensure required Python packages are available
python3 - << 'EOF'
import sys
missing = []
for pkg in ("flask", "psutil"):
    try:
        __import__(pkg)
    except ImportError:
        missing.append(pkg)

if missing:
    print("Missing Python packages:", ", ".join(missing))
    print("Install them with:")
    print("  python3 -m pip install " + " ".join(missing))
    sys.exit(1)
EOF

echo "Starting Privara backend on http://localhost:8000"
echo "Press Ctrl+C to stop."
python3 server.py
