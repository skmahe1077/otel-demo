# Grafana Demo Script – Step-by-Step Walkthrough

**URL:** http://localhost:8080/grafana/
**Pre-requisite:** Port-forward is running:
```bash
kubectl -n otel-demo port-forward svc/frontend-proxy 8080:8080
```

---

## Scene 1: Demo Dashboard – The Big Picture (5 min)

**Open:** http://localhost:8080/grafana/d/W2gX2zHVk/demo-dashboard

> "This is our overview dashboard. Everything you see here is powered by OpenTelemetry – traces, metrics, and logs from 20 services, all in one place."

### What to point out:

**Top row – Spanmetrics (RED Metrics):**
- **Requests Rate by Span Name** — "Every bar is a service operation. You can see the load generator is driving steady traffic across all services."
- **Error Rate by Span Name** — "Right now everything is green – no errors. We'll change that soon."
- **Average Duration by Span Name** — "All operations are completing in milliseconds. Note the relative sizes – some operations are naturally slower."

**Middle row – Application Logs:**
- **Log Records by Severity** — "OpenTelemetry also collects logs. You can see INFO, WARN, ERROR counts over time."
- **Log Records (100 recent entries)** — "These logs are correlated with traces – click any log line and you can jump to the exact trace."

**Bottom row – Application Metrics:**
- **Python services (CPU%, Memory)** — "Runtime metrics from the Python services – recommendation, quote services."
- **Java/.NET metrics** — "Same for Java and .NET services – all collected via OTel SDK."

### Live demo action:
1. Set time range to **Last 15 minutes** (top right)
2. Point out the steady traffic pattern
3. Say: "Let's keep this open and come back after we break something"

---

## Scene 2: Spanmetrics Dashboard – Service Performance (3 min)

**Open:** http://localhost:8080/grafana/d/W2gX2zHVk48/spanmetrics-demo-dashboard

> "This dashboard turns traces INTO metrics. The OpenTelemetry Collector automatically computes request rates, error rates, and latency percentiles from spans."

### What to point out:

- **Top 3x3 Service Latency (p95)** — "These are the 3 slowest services at the 95th percentile. In a healthy system, they're all fast."
- **Top 7 Services Mean Rate** — "Request throughput per service – you can see which services handle the most traffic."
- **Top 7 Services Mean ERROR Rate** — "Error rates per service – all flat at zero right now."
- **Top 7 Highest Endpoint Latencies** — "Individual endpoint latencies – useful for spotting slow API routes."

### Key teaching point:
> "These metrics are derived from traces – you didn't have to add any Prometheus metrics code. The Collector's spanmetrics connector computes them automatically."

---

## Scene 3: APM Dashboard – Full Observability (3 min)

**Open:** http://localhost:8080/grafana/d/febljk0a32qyoa/apm-dashboard-jaeger-prometheus-opensearch

> "This is a full APM view. It combines all three signals – traces from Jaeger, metrics from Prometheus, and logs from OpenSearch."

### What to point out:

- **Service dropdown** (top) — Select `checkoutservice`
- **Duration** panel — "Average and p99 latency for this service"
- **Error** panel — "Error rate over time"
- **Request Rate** panel — "Throughput"
- **HTTP Operations** — "Breakdown by HTTP endpoint"
- **gRPC Operations** — "Breakdown by gRPC method"
- **Outbound Services** — "Which downstream services does checkout call? You can see payment, shipping, cart, etc."

### Key teaching point:
> "This is the RED method – Rate, Errors, Duration. With OpenTelemetry, you get this for every service, in every language, with the same dashboard."

---

## Scene 4: Break It – Watch Errors in Real Time (5 min)

### Step 1: Keep the Demo Dashboard open
**Open:** http://localhost:8080/grafana/d/W2gX2zHVk/demo-dashboard

Set auto-refresh to **5s** (top right → refresh icon → 5s)

### Step 2: Run break.sh in terminal
```bash
./scripts/break.sh
```

### Step 3: Watch the dashboard (wait 30-60 seconds)

> "Watch the Error Rate panel..."

**What the audience will see:**
- **Error Rate by Span Name** — A red spike appears for `payment` / `checkout` operations
- **Average Duration by Span Name** — Duration may spike for checkout (waiting for failed payment)
- **Log Records by Severity** — ERROR log count increases

### Step 4: Switch to Spanmetrics Dashboard
**Open:** http://localhost:8080/grafana/d/W2gX2zHVk48/spanmetrics-demo-dashboard

- **Top 7 Services Mean ERROR Rate** — `paymentservice` now has a visible error rate
- **Top 3x3 Service Latency** — checkout latency may spike

### Step 5: Drill into the APM Dashboard
**Open:** http://localhost:8080/grafana/d/febljk0a32qyoa/apm-dashboard-jaeger-prometheus-opensearch

1. Select **Service:** `checkoutservice`
2. **Error panel** shows the spike
3. **Outbound Services** — shows `payment` is the failing dependency

### Step 6: Find the trace in Jaeger (via Grafana Explore)
1. Click **Explore** (compass icon, left sidebar)
2. Select **Jaeger** datasource
3. **Service:** `checkoutservice`
4. Click **Run query**
5. Click on a red/error trace
6. Walk through the waterfall:
   - `checkoutservice` → `paymentservice` → **ERROR span**
   - Click the error span → show error tags and message

> Ask the audience: **"We broke one service. How many dashboards showed us the problem? All of them. That's the power of correlated observability."**

---

## Scene 5: Heal It – Watch Recovery (2 min)

### Step 1: Keep a dashboard open with 5s auto-refresh

### Step 2: Run heal.sh
```bash
./scripts/heal.sh
```

### Step 3: Watch the recovery
- Error rates drop back to zero
- Latencies return to normal
- Logs go back to INFO-only

> "One command to break, one command to heal. The observability stack showed us the problem in seconds, not hours."

---

## Scene 6: Cart Service Exemplars – Metrics-to-Traces (2 min)

**Open:** http://localhost:8080/grafana/d/ce6sd46kfkglca/cart-service-exemplars

> "This is my favourite feature. Exemplars link metrics directly to traces."

### What to point out:

- **GetCart Latency Heatmap with Exemplars** — "Each dot on this heatmap is an exemplar – a specific trace that contributed to that metric bucket."
- **Click on a dot** → it opens the trace in Jaeger
- "You see a latency spike at p95? Click the dot, and you're looking at the EXACT request that was slow."

### Key teaching point:
> "With traditional monitoring, you see 'p99 latency is high' but you don't know WHY. With exemplars, you click the spike and land on the exact trace. Metrics tell you WHAT happened, traces tell you WHY."

---

## Scene 7: OpenTelemetry Collector Dashboard (2 min)

**Open:** http://localhost:8080/grafana/d/otel-demo_otel-collector_dashboard/opentelemetry-collector

> "The Collector itself is instrumented. This dashboard shows you the health of your telemetry pipeline."

### What to point out:

- **Spans received vs exported** — "Are we losing data? Is the pipeline keeping up?"
- **Drop Rate** — "If this goes above zero, you're losing telemetry"
- **Export errors** — "Is the backend (Jaeger/Prometheus) healthy?"
- **Queue length** — "Is the Collector backing up?"

### Key teaching point:
> "In production, this is critical. You need to monitor the monitor. If your Collector drops spans, you're flying blind and don't even know it."

---

## Quick Reference – Dashboard URLs

| Dashboard | URL | Best for |
|---|---|---|
| Demo Dashboard | http://localhost:8080/grafana/d/W2gX2zHVk/demo-dashboard | Overview, break/heal demo |
| Spanmetrics | http://localhost:8080/grafana/d/W2gX2zHVk48/spanmetrics-demo-dashboard | Service latencies, error rates |
| APM Dashboard | http://localhost:8080/grafana/d/febljk0a32qyoa/apm-dashboard-jaeger-prometheus-opensearch | Per-service deep dive |
| Cart Exemplars | http://localhost:8080/grafana/d/ce6sd46kfkglca/cart-service-exemplars | Metrics-to-traces link |
| OTel Collector | http://localhost:8080/grafana/d/otel-demo_otel-collector_dashboard/opentelemetry-collector | Pipeline health |
| PostgreSQL | http://localhost:8080/grafana/d/xHhbQmdjA/postgresql | DB metrics |
| Linux Host | http://localhost:8080/grafana/d/otel-demo-hostmetrics/linux | Node-level metrics |
| NGINX | http://localhost:8080/grafana/d/6fb665e0-cb81-40a5-bd21-a9485c5477b4/image-provider-nginx-metrics | Image provider metrics |

---

## Speaker Tips

- **Set auto-refresh to 5s** before the break/heal demo so changes appear live
- **Use Last 15 minutes** time range – wide enough to see trends, narrow enough to see the spike
- **Pre-open dashboard tabs** before the talk so you just switch tabs, no typing URLs
- **Demo Dashboard → Spanmetrics → APM → Explore/Jaeger** is a natural drill-down flow
- The **Exemplars** scene is a crowd-pleaser – practise the click-to-trace flow beforehand
