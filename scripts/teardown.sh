#!/usr/bin/env bash
# teardown.sh – Remove the OTel demo and optionally delete the EKS cluster.
set -euo pipefail

NAMESPACE="${NAMESPACE:-otel-demo}"
CLUSTER_NAME="${CLUSTER_NAME:-otel-demo}"
AWS_REGION="${AWS_REGION:-eu-west-2}"

echo "==> Uninstalling OpenTelemetry Demo Helm release"
helm uninstall my-otel-demo -n "${NAMESPACE}" 2>/dev/null || true

echo "==> Deleting namespace ${NAMESPACE}"
kubectl delete namespace "${NAMESPACE}" --ignore-not-found

if [[ "${DELETE_CLUSTER:-false}" == "true" ]]; then
  echo "==> Deleting EKS cluster ${CLUSTER_NAME} in ${AWS_REGION}"
  eksctl delete cluster --name "${CLUSTER_NAME}" --region "${AWS_REGION}"
  echo "=== Cluster deleted. Teardown complete. ==="
else
  echo ""
  echo "=== Teardown complete. ==="
  echo "To also delete the EKS cluster, run:"
  echo "  DELETE_CLUSTER=true ./scripts/teardown.sh"
fi
