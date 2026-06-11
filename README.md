# Getting Started with OpenTelemetry – OTel Night Birmingham

A conference demo deploying the **official OpenTelemetry Demo** on Amazon EKS.
The demo ships 15+ microservices (Go, Python, Java, .NET, JS, Rust, etc.) with
full distributed tracing, metrics, and logs – plus Grafana, Jaeger, and Prometheus
pre-configured out of the box.

Ref: https://opentelemetry.io/docs/demo/kubernetes-deployment/

## Architecture

The official OTel demo includes:
- **15+ microservices** in multiple languages, all instrumented with OpenTelemetry
- **OpenTelemetry Collector** – receives, processes, and exports telemetry
- **Jaeger** – distributed trace viewer
- **Grafana** – dashboards with pre-provisioned datasources (Prometheus + Jaeger)
- **Prometheus** – metrics storage
- **flagd** – feature flag service (used for break/heal scenarios)
- **Load Generator** – continuous traffic via Locust

All accessible through a single **frontend-proxy** port-forward.

## Prerequisites

- AWS CLI configured with credentials (`aws configure`)
- `eksctl`, `kubectl`, `helm` (3.14+), `docker` CLI tools
- Kubernetes 1.24+ (EKS cluster with at least **6 GB RAM** across nodes)

## Repo Layout

```
helm/               Helm values for the OTel demo chart
scripts/            create-cluster.sh, setup.sh, break.sh, heal.sh, teardown.sh
```

## Run of Show

### 0. Create the EKS cluster (one-time)

```bash
# Defaults: cluster=otel-demo, region=eu-west-2, 3x t3.medium nodes
./scripts/create-cluster.sh

# Or override:
# CLUSTER_NAME=my-demo AWS_REGION=us-west-2 NODE_TYPE=t3.large ./scripts/create-cluster.sh
```

### 1. Deploy the demo (do this BEFORE the talk)

```bash
./scripts/setup.sh
```

### 2. Access the UIs

```bash
kubectl --namespace otel-demo port-forward svc/frontend-proxy 8080:8080
```

Open in your browser:

| UI               | URL                                    |
|------------------|----------------------------------------|
| Web Store        | http://localhost:8080/                  |
| Grafana          | http://localhost:8080/grafana/          |
| Jaeger           | http://localhost:8080/jaeger/ui/        |
| Load Generator   | http://localhost:8080/loadgen/          |
| Feature Flags    | http://localhost:8080/feature           |

### 3. Show healthy traces

- Open **Jaeger UI** → Select `checkoutservice` → Find Traces
- Or open **Grafana** → Explore → Jaeger datasource
- Note the trace waterfall: `frontend` → `checkoutservice` → `paymentservice`, `shippingservice`, etc.

### 4. Break it

```bash
./scripts/break.sh
```

This enables the `paymentServiceFailure` feature flag via flagd. The payment
service starts returning errors. Within ~30 seconds you'll see red error spans
in Jaeger.

Ask the audience: **"Which service is failing? How can you tell?"**

### 5. Heal it

```bash
./scripts/heal.sh
```

Disables the flag. Traces return to normal within seconds.

### 6. Teardown (after the talk)

```bash
# Remove the demo
./scripts/teardown.sh

# Also delete the EKS cluster to stop all billing:
DELETE_CLUSTER=true ./scripts/teardown.sh
```

## Key Teaching Points

1. **Distributed tracing across polyglot services** – 15+ services in different
   languages all producing correlated traces via OpenTelemetry.
2. **OpenTelemetry Collector as the hub** – receives OTLP from all services,
   exports to Jaeger (traces) and Prometheus (metrics).
3. **Finding the bottleneck** – one feature flag toggle breaks payments; Jaeger
   makes the failing span immediately obvious.
4. **Feature flags for chaos** – flagd integration lets you toggle failure
   scenarios without redeploying.

## Stage Tips

- **Pre-provision** everything 30 min before the talk. Run `create-cluster.sh` + `setup.sh`.
- **Record a backup** screen capture of traces in case WiFi fails.
- **Teardown** after the talk to stop EKS billing.
- The demo needs **6 GB RAM** – 3x `t3.medium` (4 GB each) provides enough headroom for all 29 pods.

## License

MIT
