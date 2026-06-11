#!/usr/bin/env bash
# break.sh – Enable the paymentFailure feature flag via flagd.
# This makes the payment service return errors, creating a visible bottleneck
# in Jaeger/Grafana traces.
set -euo pipefail

NAMESPACE="${NAMESPACE:-otel-demo}"
CONFIGMAP="flagd-config"
FLAG="paymentFailure"

echo "==> Enabling ${FLAG} feature flag..."

kubectl get configmap "${CONFIGMAP}" -n "${NAMESPACE}" -o json \
  | python3 -c "
import sys, json
cm = json.load(sys.stdin)
data = json.loads(cm['data']['demo.flagd.json'])
data['flags']['${FLAG}']['defaultVariant'] = 'on'
cm['data']['demo.flagd.json'] = json.dumps(data)
json.dump(cm, sys.stdout)
" | kubectl apply -f -

# flagd watches the ConfigMap via inotify, but restart to be safe
echo "==> Restarting flagd to pick up changes..."
kubectl delete pod -l app.kubernetes.io/component=flagd -n "${NAMESPACE}" 2>/dev/null || true
kubectl rollout status deployment/flagd -n "${NAMESPACE}" --timeout=60s 2>/dev/null || true

echo ""
echo "Payment service is now FAILING."
echo "Open Jaeger (http://localhost:8080/jaeger/ui/) and search for 'checkoutservice'"
echo "to see error spans in the checkout -> payment call chain."
echo ""
echo "To heal: ./scripts/heal.sh"
