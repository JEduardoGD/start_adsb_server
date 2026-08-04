#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

echo "============================================"
echo "  STOPPING ALL ADS-B FEED SERVICES"
echo "============================================"
echo ""

# --- Check and stop fr24feed ---
echo "[1/5] Checking fr24feed service..."
if systemctl is-active --quiet fr24feed; then
    echo "  -> Stopping fr24feed..."
    systemctl stop fr24feed
    echo "  -> fr24feed stopped successfully"
else
    echo "  -> fr24feed is already stopped"
fi
echo ""

# --- Check and stop piaware ---
echo "[2/5] Checking piaware service..."
if systemctl is-active --quiet piaware; then
    echo "  -> Stopping piaware..."
    systemctl stop piaware
    echo "  -> piaware stopped successfully"
else
    echo "  -> piaware is already stopped"
fi
echo ""

# --- Check and stop aprsigate ---
echo "[3/5] Checking aprsigate service..."
if systemctl is-active --quiet aprsigate; then
    echo "  -> Stopping aprsigate..."
    systemctl stop aprsigate
    echo "  -> aprsigate stopped successfully"
else
    echo "  -> aprsigate is already stopped"
fi
echo ""

# --- Check and stop docker rbfeeder ---
echo "[4/5] Checking rbfeeder docker container..."
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
echo "[5/5] Cleaning up stopped rbfeeder docker container..."
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
