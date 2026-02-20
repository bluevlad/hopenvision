#!/bin/bash
set -e

echo "=== HopenVision Production Deployment ==="
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

COMPOSE_FILE="docker-compose.prod.yml"
HEALTH_RETRIES=5
HEALTH_INTERVAL=15

# 롤백용: 현재 이미지 ID 저장
PREV_IMAGES=""
save_current_images() {
    PREV_IMAGES=$(docker compose -f "$COMPOSE_FILE" images -q 2>/dev/null || true)
}

health_check() {
    local attempt=1
    while [ $attempt -le $HEALTH_RETRIES ]; do
        echo "  Health check attempt $attempt/$HEALTH_RETRIES..."
        local fe_ok=false be_ok=false

        if curl -f -s -o /dev/null --max-time 10 http://localhost:4060; then
            fe_ok=true
        fi
        if curl -f -s -o /dev/null --max-time 10 "http://localhost:9050/api/exams?page=0&size=1"; then
            be_ok=true
        fi

        if $fe_ok && $be_ok; then
            echo "  Frontend (4060): OK"
            echo "  Backend  (9050): OK"
            return 0
        fi

        echo "  Frontend: $($fe_ok && echo OK || echo FAILED) | Backend: $($be_ok && echo OK || echo FAILED)"

        if [ $attempt -lt $HEALTH_RETRIES ]; then
            echo "  Retrying in ${HEALTH_INTERVAL}s..."
            sleep $HEALTH_INTERVAL
        fi
        attempt=$((attempt + 1))
    done
    return 1
}

rollback() {
    echo ""
    echo "=== ROLLBACK: Health check failed, restoring previous version ==="
    docker compose -f "$COMPOSE_FILE" down --timeout 30 || true

    if [ -n "$PREV_IMAGES" ]; then
        echo "  Restarting with previous images..."
        docker compose -f "$COMPOSE_FILE" up -d
        sleep 30
        if health_check; then
            echo "  Rollback succeeded."
        else
            echo "  WARNING: Rollback health check also failed. Manual intervention required."
        fi
    else
        echo "  No previous images found. Manual intervention required."
    fi
    exit 1
}

echo "[1/6] Pulling latest code from prod branch..."
git fetch origin
git checkout prod
git pull origin prod

echo "[2/6] Saving current deployment state..."
save_current_images

echo "[3/6] Stopping existing services..."
docker compose -f "$COMPOSE_FILE" down --timeout 30 || true

echo "[4/6] Building Docker images..."
docker compose -f "$COMPOSE_FILE" build --no-cache

echo "[5/6] Starting services..."
docker compose -f "$COMPOSE_FILE" up -d

echo "[6/6] Running health checks (max ${HEALTH_RETRIES} attempts)..."
sleep 30

if health_check; then
    echo ""
    echo "=== Deployment Successful ==="
    echo "  Frontend: http://localhost:4060"
    echo "  Backend:  http://localhost:9050"
    echo "  Database: localhost:5432"
    exit 0
else
    rollback
fi
