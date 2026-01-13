#!/usr/bin/env bash
#
# Privara HIDS - Quick Start Script
# Automatically starts backend, JavaFX monitor, and opens web dashboard
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/app"
MONITOR_DIR="$SCRIPT_DIR/javafx-monitor"
LOG_FILE="$SCRIPT_DIR/privara-startup.log"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}   Privara HIDS v3.0 - Quick Start   ${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/6] Checking prerequisites...${NC}"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 not found. Please install Python 3.10+${NC}"
    exit 1
fi

if ! command -v java &> /dev/null; then
    echo -e "${RED}Error: java not found. Please install Java 17+${NC}"
    exit 1
fi

if ! command -v mvn &> /dev/null; then
    echo -e "${YELLOW}Warning: maven not found. JavaFX monitor may not be built.${NC}"
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"
echo ""

# Check Python dependencies
echo -e "${YELLOW}[2/6] Checking Python dependencies...${NC}"

if ! python3 -c "import flask" 2>/dev/null; then
    echo -e "${YELLOW}Installing Flask...${NC}"
    pip3 install flask
fi

if ! python3 -c "import psutil" 2>/dev/null; then
    echo -e "${YELLOW}Installing psutil...${NC}"
    pip3 install psutil
fi

echo -e "${GREEN}✓ Python dependencies OK${NC}"
echo ""

# Build JavaFX monitor if needed
echo -e "${YELLOW}[3/6] Building JavaFX monitor...${NC}"

if [ ! -f "$MONITOR_DIR/target/privara-monitor-1.0.jar" ]; then
    if command -v mvn &> /dev/null; then
        echo -e "${YELLOW}Building for the first time...${NC}"
        cd "$MONITOR_DIR"
        mvn clean package -q
        cd "$SCRIPT_DIR"
        echo -e "${GREEN}✓ Build complete${NC}"
    else
        echo -e "${RED}Error: Maven not found, cannot build JavaFX monitor.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ JavaFX monitor already built${NC}"
fi
echo ""

# Start Python backend
echo -e "${YELLOW}[4/6] Starting Python backend...${NC}"

cd "$BACKEND_DIR"
python3 server.py >> "$LOG_FILE" 2>&1 &
BACKEND_PID=$!

echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
echo "  Log: $LOG_FILE"
echo ""

# Wait for backend to be ready
sleep 2

if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}Error: Backend failed to start. Check log file.${NC}"
    exit 1
fi

# Start JavaFX monitor
echo -e "${YELLOW}[5/6] Starting JavaFX monitor...${NC}"

cd "$MONITOR_DIR"
java -jar target/privara-monitor-1.0.jar >> "$LOG_FILE" 2>&1 &
MONITOR_PID=$!

echo -e "${GREEN}✓ Monitor started (PID: $MONITOR_PID)${NC}"
echo ""

# Save PIDs for cleanup
echo "$BACKEND_PID" > "$SCRIPT_DIR/.backend.pid"
echo "$MONITOR_PID" > "$SCRIPT_DIR/.monitor.pid"

# Open web dashboard
echo -e "${YELLOW}[6/6] Opening web dashboard...${NC}"
sleep 1

URL="http://localhost:8000"

if command -v xdg-open &> /dev/null; then
    xdg-open "$URL" &> /dev/null
elif command -v open &> /dev/null; then
    open "$URL"
elif command -v start &> /dev/null; then
    start "$URL"
else
    echo -e "${YELLOW}Could not auto-open browser. Please visit:${NC}"
    echo "  $URL"
fi

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}   Privara HIDS is now running!     ${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "Dashboard: $URL"
echo "Backend PID: $BACKEND_PID"
echo "Monitor PID: $MONITOR_PID"
echo "Logs: $LOG_FILE"
echo ""
echo -e "${YELLOW}To stop all services, run:${NC}"
echo "  ./stop-privara.sh"
echo ""
echo -e "${YELLOW}To view logs in real-time:${NC}"
echo "  tail -f $LOG_FILE"
echo ""
