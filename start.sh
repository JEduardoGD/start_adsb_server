#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

echo "============================================"
echo "  STARTING ALL ADS-B FEED SERVICES"
echo "============================================"
echo ""

# --- Check and start fr24feed ---
echo "[1/3] Checking fr24feed service..."
if systemctl is-active --quiet fr24feed; then
    echo "  -> fr24feed is already running"
else
    echo "  -> Starting fr24feed..."
    systemctl start fr24feed
    echo "  -> fr24feed started successfully"
fi
echo ""

# --- Check and start piaware ---
echo "[2/3] Checking piaware service..."
if systemctl is-active --quiet piaware; then
    echo "  -> piaware is already running"
else
    echo "  -> Starting piaware..."
    systemctl start piaware
    echo "  -> piaware started successfully"
fi
echo ""

if [[ "$1" == "--skip-docker" ]]; then
    echo "[3/3] Skipping rbfeeder docker container (--skip-docker)"
    echo ""
else
    # --- Docker rbfeeder ---
    echo "[3/3] Setting up rbfeeder docker container..."
    source .env
    IP=$(ip -4 -br addr show $NETWORK_ADAPTER | awk '{print $3}' | cut -d'/' -f1)
    echo "  -> Detected IP: $IP"

    if docker ps --format '{{.Names}}' | grep -q '^rbfeeder$'; then
        echo "  -> rbfeeder docker container is already running"
    else
        echo "  -> Starting rbfeeder docker container..."
        docker run \
            -d \
            --rm \
            --name rbfeeder \
            -e TZ="$TZ" \
            -e BEASTHOST=$IP \
            -e BEASTPORT=30005 \
            -e LAT=$LAT \
            -e LONG=$LONG \
            -e ALT=$ALT \
            -e SHARING_KEY="$SHARING_KEY" \
            ghcr.io/sdr-enthusiasts/docker-airnavradar:latest
        echo "  -> rbfeeder started successfully"
    fi
    echo ""
fi

echo "============================================"
echo "  ALL SERVICES STARTED"
echo "============================================"
