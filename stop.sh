#!/bin/bash

echo "============================================"
echo "  STOPPING ALL ADS-B FEED SERVICES"
echo "============================================"
echo ""

# --- Check and stop fr24feed ---
echo "[1/4] Checking fr24feed service..."
if systemctl is-active --quiet fr24feed; then
    echo "  -> Stopping fr24feed..."
    systemctl stop fr24feed
    echo "  -> fr24feed stopped successfully"
else
    echo "  -> fr24feed is already stopped"
fi
echo ""

# --- Check and stop piaware ---
echo "[2/4] Checking piaware service..."
if systemctl is-active --quiet piaware; then
    echo "  -> Stopping piaware..."
    systemctl stop piaware
    echo "  -> piaware stopped successfully"
else
    echo "  -> piaware is already stopped"
fi
echo ""

# --- Check and stop docker rbfeeder ---
echo "[3/4] Checking rbfeeder docker container..."
if docker ps --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    echo "  -> Stopping rbfeeder docker container..."
    docker stop rbfeeder
    echo "  -> Removing rbfeeder docker container..."
    docker rm rbfeeder
    echo "  -> rbfeeder stopped and removed successfully"
else
    echo "  -> rbfeeder docker container is already stopped"
fi
echo ""

# --- Clean up stopped rbfeeder container ---
echo "[4/4] Cleaning up stopped rbfeeder docker container..."
if docker ps -a --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    echo "  -> Removing rbfeeder docker container..."
    docker rm rbfeeder
    echo "  -> rbfeeder removed successfully"
else
    echo "  -> No rbfeeder container to clean up"
fi
echo ""

echo "============================================"
echo "  ALL SERVICES STOPPED"
echo "============================================"
