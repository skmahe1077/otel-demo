#!/usr/bin/env bash
# break.sh – Enable the paymentFailure feature flag via flagd.
# This makes the payment service fail 100% of the time, creating a visible
# bottleneck in Jaeger/Grafana traces.
set -euo pipefail

NAMESPACE="${NAMESPACE:-otel-demo}"
CONFIGMAP="flagd-config"
FLAG="paymentFailure"
# Valid variants: "off", "10%", "25%", "50%", "75%", "90%", "100%"
VARIANT="100%"

echo "==> Enabling ${FLAG} feature flag (variant: ${VARIANT})..."

kubectl get configmap "${CONFIGMAP}" -n "${NAMESPACE}" -o json \
  | python3 -c "
import sys, json
cm = json.load(sys.stdin)
data = json.loads(cm['data']['demo.flagd.json'])
data['flags']['${FLAG}']['defaultVariant'] = '${VARIANT}'
cm['data']['demo.flagd.json'] = json.dumps(data)
json.dump(cm, sys.stdout)
" | kubectl apply -f -

echo "==> Restarting flagd to pick up changes..."
kubectl delete pod -l app.kubernetes.io/component=flagd -n "${NAMESPACE}" 2>/dev/null || true
kubectl rollout status deployment/flagd -n "${NAMESPACE}" --timeout=60s 2>/dev/null || true

echo ""
echo "Payment service is now FAILING (${VARIANT} of requests)."
echo ""
echo "What happens:"
echo "  - Web Store: browsing works, but 'Place Order' silently fails (500 from API)"
echo "  - Jaeger (http://localhost:8080/jaeger/ui/) -> Search 'checkout' -> Red error spans"
echo "  - Error span: oteldemo.PaymentService/Charge -> 'Payment request failed. Invalid token'"
echo "  - Grafana Demo Dashboard -> Error Rate panel spikes"
echo ""
echo "To heal: ./scripts/heal.sh"
