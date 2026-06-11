#!/usr/bin/env bash
# create-cluster.sh – Provision a minimal EKS cluster for the OTel demo.
# Usage: ./scripts/create-cluster.sh
# Override defaults with env vars: CLUSTER_NAME, AWS_REGION, NODE_COUNT, NODE_TYPE
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-otel-demo}"
AWS_REGION="${AWS_REGION:-eu-west-2}"
NODE_COUNT="${NODE_COUNT:-3}"
NODE_TYPE="${NODE_TYPE:-t3.medium}"
K8S_VERSION="${K8S_VERSION:-1.31}"

echo "==> Creating EKS cluster"
echo "    Cluster : ${CLUSTER_NAME}"
echo "    Region  : ${AWS_REGION}"
echo "    Nodes   : ${NODE_COUNT} x ${NODE_TYPE}"
echo "    K8s     : ${K8S_VERSION}"
echo ""

eksctl create cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --version "${K8S_VERSION}" \
  --nodegroup-name demo-nodes \
  --node-type "${NODE_TYPE}" \
  --nodes "${NODE_COUNT}" \
  --managed

echo "==> Updating kubeconfig"
aws eks update-kubeconfig \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}"

echo ""
echo "=== EKS cluster '${CLUSTER_NAME}' is ready ==="
echo "Next: export REGISTRY=<your-ecr-repo> && ./scripts/setup.sh"
