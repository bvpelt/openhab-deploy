#!/bin/bash

# Usage: ./run_proxy.sh [start|stop|status]

ACTION=$1
NETWORK_NAME="proxy_network"

# 1. Ask for action if not provided
if [ -z "$ACTION" ]; then
    read -p "Enter action (start/stop/status): " ACTION
fi
ACTION=${ACTION,,}

# 2. Pre-flight Check: Ensure Proxy Network exists
if [ "$ACTION" == "start" ]; then
    if ! docker network ls | grep -q "$NETWORK_NAME"; then
        echo "🌐 $NETWORK_NAME not found. Creating it now..."
        docker network create "$NETWORK_NAME"
    else
        echo "✅ Network $NETWORK_NAME is ready."
    fi
fi

# 5. Logic Switch
COMPOSE_CMD="docker compose --env-file ./proxy/.env -f ./proxy/docker-compose.yml"

case "$ACTION" in
    start)
        echo "🚀 Starting proxy..."
        $COMPOSE_CMD up -d
        ;;
    stop)
        echo "🛑 Stopping proxy..."
        $COMPOSE_CMD stop
        ;;
    status)
        echo "📊 Status for proxy"
        $COMPOSE_CMD ps
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac
