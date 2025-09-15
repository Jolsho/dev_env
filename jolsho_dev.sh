#!/bin/bash

# Default container name
CONTAINER_NAME="dev_env"

# Check argument
COMMAND="$1"

if [ -z "$COMMAND" ]; then
    echo "Usage: $0 {start|stop|exec}"
    exit 1
fi

case "$COMMAND" in
    start)
        sudo docker start -ai "$CONTAINER_NAME"
        ;;
    stop)
        sudo docker stop "$CONTAINER_NAME"
        ;;
    exec)
        sudo docker exec -it "$CONTAINER_NAME" bash
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: $0 {start|stop|exec}"
        exit 1
        ;;
esac
