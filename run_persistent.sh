#!/bin/bash

echo "============================================"
echo "  CONFIGURING PERSISTENT ADS-B SERVICES"
echo "============================================"
echo ""

echo "[0/5] Stopping running services..."
./stop.sh
echo ""

# --- Configure fr24feed ---
echo "[1/5] Configuring fr24feed persistence..."
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
echo "[2/5] Configuring piaware persistence..."
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

# --- Start services ---
echo "[3/5] Starting services..."
./start.sh --skip-docker
echo ""

# --- Stop existing rbfeeder ---
echo "[4/5] Stopping existing rbfeeder docker container if any..."
if docker ps --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    echo "  -> Stopping existing rbfeeder container..."
    docker stop rbfeeder
    echo "  -> rbfeeder container stopped"
else
    echo "  -> No existing rbfeeder container found"
fi
echo ""

# --- Start persistent rbfeeder ---
echo "[5/5] Setting up persistent rbfeeder docker container..."
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
