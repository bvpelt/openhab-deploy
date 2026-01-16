#!/bin/bash

# Usage: ./run_openhab.sh [home|church] [start|stop|status]

DEPLOYMENT=$1
ACTION=$2
NETWORK_NAME="proxy_network"

# 1. Ask for environment if not provided
if [ -z "$DEPLOYMENT" ]; then
    read -p "Enter deployment environment (home/church): " DEPLOYMENT
fi
DEPLOYMENT=${DEPLOYMENT,,}

# 2. Ask for action if not provided
if [ -z "$ACTION" ]; then
    read -p "Enter action (start/stop/status): " ACTION
fi
ACTION=${ACTION,,}

# 3. Validation
if [ ! -d "./$DEPLOYMENT" ]; then
    echo "❌ Error: Directory ./$DEPLOYMENT not found."
    exit 1
fi

# 4. Pre-flight Check: Ensure Proxy Network exists
if [ "$ACTION" == "start" ]; then
    if ! docker network ls | grep -q "$NETWORK_NAME"; then
        echo "🌐 $NETWORK_NAME not found. Creating it now..."
        docker network create "$NETWORK_NAME"
    else
        echo "✅ Network $NETWORK_NAME is ready."
    fi
fi

# 5. Logic Switch
COMPOSE_CMD="docker compose --env-file ./$DEPLOYMENT/.env -f ./common/docker-compose.yml"

case "$ACTION" in
    start)
        echo "🚀 Starting openHAB for $DEPLOYMENT..."
        $COMPOSE_CMD up -d
        ;;
    stop)
        echo "🛑 Stopping openHAB for $DEPLOYMENT..."
        $COMPOSE_CMD stop
        ;;
    status)
        echo "📊 Status for $DEPLOYMENT:"
        $COMPOSE_CMD ps
        ;;
    *)
        echo "Usage: $0 {home|church} {start|stop|status}"
        exit 1
        ;;
esac
