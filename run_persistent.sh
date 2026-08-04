#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

echo "============================================"
echo "  CONFIGURING PERSISTENT ADS-B SERVICES"
echo "============================================"
echo ""

echo "[0/6] Stopping running services..."
./stop.sh
echo ""

# --- Configure fr24feed ---
echo "[1/6] Configuring fr24feed persistence..."
if systemctl is-enabled fr24feed > /dev/null 2>&1; then
    echo "  -> fr24feed is enabled, disabling..."
    systemctl disable fr24feed
else
    echo "  -> fr24feed is not enabled, skipping disable"
fi
echo "  -> Re-enabling fr24feed..."
systemctl enable fr24feed
echo "  -> fr24feed persistence configured"
echo ""

# --- Configure piaware ---
echo "[2/6] Configuring piaware persistence..."
if systemctl is-enabled piaware > /dev/null 2>&1; then
    echo "  -> piaware is enabled, disabling..."
    systemctl disable piaware
else
    echo "  -> piaware is not enabled, skipping disable"
fi
echo "  -> Re-enabling piaware..."
systemctl enable piaware
echo "  -> piaware persistence configured"
echo ""

# --- Configure aprsigate ---
echo "[3/6] Configuring aprsigate persistence..."
if systemctl is-enabled aprsigate > /dev/null 2>&1; then
    echo "  -> aprsigate is enabled, disabling..."
    systemctl disable aprsigate
else
    echo "  -> aprsigate is not enabled, skipping disable"
fi
echo "  -> Re-enabling aprsigate..."
systemctl enable aprsigate
echo "  -> aprsigate persistence configured"
echo ""

# --- Start services ---
echo "[4/6] Starting services..."
./start.sh --skip-docker
echo ""

# --- Stop existing rbfeeder ---
echo "[5/6] Stopping existing rbfeeder docker container if any..."
if docker ps --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    echo "  -> Stopping existing rbfeeder container..."
    docker stop rbfeeder
    echo "  -> rbfeeder container stopped"
else
    echo "  -> No existing rbfeeder container found"
fi
echo ""

# --- Start persistent rbfeeder ---
echo "[6/6] Setting up persistent rbfeeder docker container..."
source .env
IP=$(ip -4 -br addr show $NETWORK_ADAPTER | awk '{print $3}' | cut -d'/' -f1)
echo "  -> Detected IP: $IP"
echo "  -> Starting rbfeeder docker container..."
docker run \
    -d \
    --restart unless-stopped \
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

echo "============================================"
echo "  PERSISTENT CONFIGURATION COMPLETE"
echo "============================================"
