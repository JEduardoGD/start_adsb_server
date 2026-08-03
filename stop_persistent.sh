#!/bin/bash

echo "============================================"
echo "  STOPPING PERSISTENT ADS-B SERVICES"
echo "============================================"
echo ""

echo "[0/5] Stopping running services..."
./stop.sh
echo ""

# --- Disable fr24feed ---
echo "[1/5] Disabling fr24feed persistence..."
if systemctl is-enabled fr24feed > /dev/null 2>&1; then
    echo "  -> fr24feed is enabled, disabling..."
    systemctl disable fr24feed
else
    echo "  -> fr24feed is not enabled, skipping disable"
fi
echo "  -> fr24feed persistence disabled"
echo ""

# --- Disable piaware ---
echo "[2/5] Disabling piaware persistence..."
if systemctl is-enabled piaware > /dev/null 2>&1; then
    echo "  -> piaware is enabled, disabling..."
    systemctl disable piaware
else
    echo "  -> piaware is not enabled, skipping disable"
fi
echo "  -> piaware persistence disabled"
echo ""

# --- Stop fr24feed ---
echo "[3/5] Stopping fr24feed service..."
if systemctl is-active --quiet fr24feed; then
    echo "  -> Stopping fr24feed..."
    systemctl stop fr24feed
    echo "  -> fr24feed stopped"
else
    echo "  -> fr24feed is not running"
fi
echo ""

# --- Stop piaware ---
echo "[4/5] Stopping piaware service..."
if systemctl is-active --quiet piaware; then
    echo "  -> Stopping piaware..."
    systemctl stop piaware
    echo "  -> piaware stopped"
else
    echo "  -> piaware is not running"
fi
echo ""

# --- Stop and delete rbfeeder ---
echo "[5/5] Stopping and removing rbfeeder docker container..."
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
