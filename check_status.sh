#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (use sudo)"
    exit 1
fi

echo "============================================"
echo "  ADS-B FEED SERVICES STATUS CHECK"
echo "============================================"
echo ""

all_running=true

# --- Check fr24feed ---
echo "[1/4] fr24feed (systemd service)"
echo "  -> Unit:    fr24feed.service"
if systemctl is-active --quiet fr24feed; then
    state="active (running)"
    since=$(systemctl show -p ActiveEnterTimestamp fr24feed | cut -d'=' -f2)
    echo "  -> Status:  ACTIVE"
    echo "  -> Since:   $since"
else
    state="inactive"
    echo "  -> Status:  INACTIVE"
    all_running=false
fi
echo ""

# --- Check piaware ---
echo "[2/4] piaware (systemd service)"
echo "  -> Unit:    piaware.service"
if systemctl is-active --quiet piaware; then
    state="active (running)"
    since=$(systemctl show -p ActiveEnterTimestamp piaware | cut -d'=' -f2)
    echo "  -> Status:  ACTIVE"
    echo "  -> Since:   $since"
else
    state="inactive"
    echo "  -> Status:  INACTIVE"
    all_running=false
fi
echo ""

# --- Check aprsigate ---
echo "[3/4] aprsigate (systemd service)"
echo "  -> Unit:    aprsigate.service"
if systemctl is-active --quiet aprsigate; then
    state="active (running)"
    since=$(systemctl show -p ActiveEnterTimestamp aprsigate | cut -d'=' -f2)
    echo "  -> Status:  ACTIVE"
    echo "  -> Since:   $since"
else
    state="inactive"
    echo "  -> Status:  INACTIVE"
    all_running=false
fi
echo ""

# --- Check rbfeeder (docker) ---
echo "[4/4] rbfeeder (docker container)"
echo "  -> Image:   ghcr.io/sdr-enthusiasts/docker-airnavradar:latest"
if docker ps --format '{{.Names}}' | grep -q '^rbfeeder$'; then
    container_status=$(docker inspect -f '{{.State.Status}}' rbfeeder)
    container_since=$(docker inspect -f '{{.State.StartedAt}}' rbfeeder)
    container_image=$(docker inspect -f '{{.Config.Image}}' rbfeeder)
    container_uptime=$(docker inspect -f '{{.State.StartedAt}}' rbfeeder | xargs -I{} date -d {} '+%a %d %b %Y %T %Z')
    echo "  -> Status:  RUNNING"
    echo "  -> Image:   $container_image"
    echo "  -> Since:   $container_uptime"
else
    echo "  -> Status:  NOT RUNNING"
    all_running=false
fi
echo ""

echo "============================================"
if $all_running; then
    echo "  RESULT: ALL SERVICES ARE RUNNING"
else
    echo "  RESULT: SOME SERVICES ARE NOT RUNNING"
fi
echo "============================================"
