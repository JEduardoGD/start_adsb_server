#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

echo "============================================"
echo "  STOPPING PERSISTENT ADS-B SERVICES"
echo "============================================"
echo ""

echo "[0/7] Stopping running services..."
./stop.sh
echo ""

# --- Disable fr24feed ---
echo "[1/7] Disabling fr24feed persistence..."
if systemctl is-enabled fr24feed > /dev/null 2>&1; then
    echo "  -> fr24feed is enabled, disabling..."
    systemctl disable fr24feed
else
    echo "  -> fr24feed is not enabled, skipping disable"
fi
echo "  -> fr24feed persistence disabled"
echo ""

# --- Disable piaware ---
echo "[2/7] Disabling piaware persistence..."
if systemctl is-enabled piaware > /dev/null 2>&1; then
    echo "  -> piaware is enabled, disabling..."
    systemctl disable piaware
else
    echo "  -> piaware is not enabled, skipping disable"
fi
echo "  -> piaware persistence disabled"
echo ""

# --- Disable aprsigate ---
echo "[3/7] Disabling aprsigate persistence..."
if systemctl is-enabled aprsigate > /dev/null 2>&1; then
    echo "  -> aprsigate is enabled, disabling..."
    systemctl disable aprsigate
else
    echo "  -> aprsigate is not enabled, skipping disable"
fi
echo "  -> aprsigate persistence disabled"
echo ""

# --- Stop fr24feed ---
echo "[4/7] Stopping fr24feed service..."
if systemctl is-active --quiet fr24feed; then
    echo "  -> Stopping fr24feed..."
    systemctl stop fr24feed
    echo "  -> fr24feed stopped"
else
    echo "  -> fr24feed is not running"
fi
echo ""

# --- Stop piaware ---
echo "[5/7] Stopping piaware service..."
if systemctl is-active --quiet piaware; then
    echo "  -> Stopping piaware..."
    systemctl stop piaware
    echo "  -> piaware stopped"
else
    echo "  -> piaware is not running"
fi
echo ""

# --- Stop aprsigate ---
echo "[6/7] Stopping aprsigate service..."
if systemctl is-active --quiet aprsigate; then
    echo "  -> Stopping aprsigate..."
    systemctl stop aprsigate
    echo "  -> aprsigate stopped"
else
    echo "  -> aprsigate is not running"
fi
echo ""

# --- Stop and delete rbfeeder ---
echo "[7/7] Stopping and removing rbfeeder docker container..."
if docker ps --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    echo "  -> Stopping rbfeeder container..."
    docker stop rbfeeder
    echo "  -> rbfeeder container stopped"
else
    echo "  -> No running rbfeeder container found"
fi
if docker ps -a --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    echo "  -> Removing rbfeeder container..."
    docker rm rbfeeder
    echo "  -> rbfeeder container removed"
else
    echo "  -> No rbfeeder container to remove"
fi
echo ""

echo "============================================"
echo "  PERSISTENT SERVICES STOPPED AND DISABLED"
echo "============================================"
