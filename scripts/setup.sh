#!/usr/bin/env bash
# setup.sh – Deploy the official OpenTelemetry demo on EKS.
# Ref: https://opentelemetry.io/docs/demo/kubernetes-deployment/
# Usage: ./scripts/setup.sh
set -euo pipefail

NAMESPACE="${NAMESPACE:-otel-demo}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "==> Adding OpenTelemetry Helm repo"
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

echo "==> Installing OpenTelemetry Demo (this takes a few minutes)"
helm install my-otel-demo open-telemetry/opentelemetry-demo \
  --namespace "${NAMESPACE}" --create-namespace \
  --values "${REPO_ROOT}/helm/otel-demo-values.yaml" \
  --timeout 10m \
  --wait

echo "==> Waiting for key pods to be ready"
kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/instance=my-otel-demo \
  -n "${NAMESPACE}" \
  --timeout=300s 2>/dev/null || true

echo ""
echo "=== Setup complete ==="
echo ""
echo "Port-forward the frontend-proxy to access all UIs:"
echo "  kubectl --namespace ${NAMESPACE} port-forward svc/frontend-proxy 8080:8080"
echo ""
echo "Then open:"
echo "  Web store:        http://localhost:8080/"
echo "  Grafana:          http://localhost:8080/grafana/"
echo "  Jaeger UI:        http://localhost:8080/jaeger/ui/"
echo "  Load Generator:   http://localhost:8080/loadgen/"
echo "  Feature Flags:    http://localhost:8080/feature"
