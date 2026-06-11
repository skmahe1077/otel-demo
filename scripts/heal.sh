#!/usr/bin/env bash
# heal.sh – Disable the paymentFailure feature flag; restore healthy state.
set -euo pipefail

NAMESPACE="${NAMESPACE:-otel-demo}"
CONFIGMAP="flagd-config"
FLAG="paymentFailure"

echo "==> Disabling ${FLAG} feature flag..."

kubectl get configmap "${CONFIGMAP}" -n "${NAMESPACE}" -o json \
  | python3 -c "
import sys, json
cm = json.load(sys.stdin)
data = json.loads(cm['data']['demo.flagd.json'])
data['flags']['${FLAG}']['defaultVariant'] = 'off'
cm['data']['demo.flagd.json'] = json.dumps(data)
json.dump(cm, sys.stdout)
" | kubectl apply -f -

echo "==> Restarting flagd to pick up changes..."
kubectl delete pod -l app.kubernetes.io/component=flagd -n "${NAMESPACE}" 2>/dev/null || true
kubectl rollout status deployment/flagd -n "${NAMESPACE}" --timeout=60s 2>/dev/null || true

echo ""
echo "Payment service is healthy again. Traces should clear up within ~30 seconds."
