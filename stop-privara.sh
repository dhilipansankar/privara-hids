x`#!/usr/bin/env bash
#
# Privara HIDS - Stop Script
# Gracefully stops all running Privara services
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping Privara HIDS services...${NC}"
echo ""

# Stop backend
if [ -f "$SCRIPT_DIR/.backend.pid" ]; then
    BACKEND_PID=$(cat "$SCRIPT_DIR/.backend.pid")
    if kill -0 "$BACKEND_PID" 2>/dev/null; then
        echo -e "${YELLOW}Stopping backend (PID: $BACKEND_PID)...${NC}"
        kill "$BACKEND_PID"
        echo -e "${GREEN}✓ Backend stopped${NC}"
    else
        echo -e "${YELLOW}Backend not running${NC}"
    fi
    rm -f "$SCRIPT_DIR/.backend.pid"
fi

# Stop monitor
if [ -f "$SCRIPT_DIR/.monitor.pid" ]; then
    MONITOR_PID=$(cat "$SCRIPT_DIR/.monitor.pid")
    if kill -0 "$MONITOR_PID" 2>/dev/null; then
        echo -e "${YELLOW}Stopping monitor (PID: $MONITOR_PID)...${NC}"
        kill "$MONITOR_PID"
        echo -e "${GREEN}✓ Monitor stopped${NC}"
    else
        echo -e "${YELLOW}Monitor not running${NC}"
    fi
    rm -f "$SCRIPT_DIR/.monitor.pid"
fi

echo ""
echo -e "${GREEN}All Privara services stopped.${NC}"
