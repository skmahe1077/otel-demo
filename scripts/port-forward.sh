#!/usr/bin/env bash
# port-forward.sh – Auto-reconnecting port-forward for the demo.
# Keeps retrying if the connection drops, so you never lose access mid-talk.
# Usage: ./scripts/port-forward.sh
set -euo pipefail

NAMESPACE="${NAMESPACE:-otel-demo}"
SERVICE="svc/frontend-proxy"
LOCAL_PORT=8080
REMOTE_PORT=8080

echo "==> Starting auto-reconnecting port-forward (${SERVICE} -> localhost:${LOCAL_PORT})"
echo "    Press Ctrl+C to stop"
echo ""

while true; do
  echo "[$(date +%H:%M:%S)] Connecting..."
  kubectl -n "${NAMESPACE}" port-forward "${SERVICE}" "${LOCAL_PORT}:${REMOTE_PORT}" 2>&1 || true
  echo "[$(date +%H:%M:%S)] Connection dropped. Reconnecting in 2s..."
  sleep 2
done
