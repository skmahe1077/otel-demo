# Demo Script – "Getting Started with OpenTelemetry"

**Event:** OTel Night Birmingham
**Duration:** ~20-25 minutes
**Speaker notes are in [brackets].**

---

## Pre-Talk Checklist (30 min before)

- [ ] EKS cluster is running: `kubectl get nodes` (3 nodes, all Ready)
- [ ] OTel demo is deployed: `kubectl get pods -n otel-demo` (29 pods Running)
- [ ] Port-forward is active:
  ```bash
  kubectl -n otel-demo port-forward svc/my-otel-demo-frontendproxy 8080:8080 &
  ```
- [ ] Browser tabs pre-opened:
  - Web Store: http://localhost:8080/
  - Jaeger: http://localhost:8080/jaeger/ui/
  - Grafana: http://localhost:8080/grafana/
  - Load Generator: http://localhost:8080/loadgen/
- [ ] Terminal ready with repo open
- [ ] Backup screen recording ready (in case of WiFi issues)

---

## Part 1: Introduction (3 min)

> "What is OpenTelemetry and why should you care?"

**Talking points:**

- OpenTelemetry is a **CNCF project** – the 2nd most active after Kubernetes
- It gives you **one standard** for traces, metrics, and logs across every language
- Vendor-neutral: switch backends (Jaeger, Datadog, Grafana Cloud) without changing code
- Today we're going to see it in action with a real microservices app on EKS

---

## Part 2: Show the Architecture (3 min)

> "Let me show you what's running"

**Run in terminal:**

```bash
kubectl get pods -n otel-demo
```

**Talking points (while pods display):**

- 15+ microservices: Go, Python, Java, .NET, JavaScript, Rust, Ruby, PHP
- Each service is instrumented with OpenTelemetry SDKs
- All telemetry flows through the **OpenTelemetry Collector**
- The Collector exports traces to **Jaeger** and metrics to **Prometheus**
- **Grafana** ties it all together with pre-built dashboards
- **Locust load generator** drives continuous traffic so we always have data

**Switch to browser – show the Web Store:**

- http://localhost:8080/
- "This is an online astronomy shop – browse products, add to cart, checkout"
- Click around briefly to show it's a real working app

---

## Part 3: Explore Healthy Traces (5 min)

> "Let's look at what OpenTelemetry gives us out of the box"

**Switch to Jaeger UI:** http://localhost:8080/jaeger/ui/

1. **Select Service:** `checkoutservice` from the dropdown
2. Click **Find Traces**
3. Click on any trace

**Walk through the trace waterfall:**

- "Here's a single checkout request"
- "The root span is `checkoutservice`"
- "It fans out to: `cartservice`, `productcatalogservice`, `currencyservice`, `paymentservice`, `shippingservice`, `emailservice`"
- "Each span shows the service name, operation, and duration"
- "This is **distributed tracing** – one request, multiple services, one correlated view"

**Point out key details:**

- Span durations (everything is fast, a few ms each)
- Service-to-service relationships
- HTTP status codes and attributes on each span

**Switch to Grafana:** http://localhost:8080/grafana/

- Go to **Explore** → select **Jaeger** datasource
- "You can also query traces directly from Grafana"
- Show the **Service Map** if available (Grafana → Dashboards)

---

## Part 4: The OpenTelemetry Collector (3 min)

> "How does the telemetry actually flow?"

**Talking points (can show a slide or draw on whiteboard):**

```
App (SDK) → OTLP → [Collector] → Jaeger (traces)
                              → Prometheus (metrics)
                              → Loki (logs)
```

- Every service sends telemetry via **OTLP** (OpenTelemetry Protocol) to the Collector
- The Collector has a **pipeline**: Receivers → Processors → Exporters
- **Receivers:** accept OTLP (gRPC + HTTP)
- **Processors:** batch, filter, transform, sample
- **Exporters:** send to any backend – Jaeger, Prometheus, Datadog, Grafana Cloud, etc.
- "The Collector is the **Swiss Army knife** – you configure it once, and swap backends without touching app code"

---

## Part 5: Break It! (5 min)

> "Now for the fun part. Let's break something and see if we can find the problem."

**[Build suspense]** "In a real production system, something goes wrong. A service starts failing. Can we find it using traces?"

**Run in terminal:**

```bash
./scripts/break.sh
```

**Explain while it runs:**

- "All I did was toggle a feature flag – no code changes, no redeployment"
- "The payment service will now start returning errors"

**Wait ~30 seconds, then switch to Jaeger:**

1. Select **`checkoutservice`** → Find Traces
2. **Look for red error spans** – they'll be immediately visible
3. Click on an error trace

**Walk through the broken trace:**

- "See the red span? That's `paymentservice`"
- "The error propagates up – `checkoutservice` fails because `paymentservice` failed"
- Click on the error span → show the error tags/logs
- "OpenTelemetry captured the error message, the stack trace, the HTTP status code"

**Ask the audience:**

> "Which service is the problem? How long did it take you to find it?"

**Key point:** "Without distributed tracing, you'd be grepping through logs across 15 services. With OpenTelemetry, it took us 10 seconds."

---

## Part 6: Heal It (2 min)

> "Let's fix it"

**Run in terminal:**

```bash
./scripts/heal.sh
```

**Switch to Jaeger after ~30 seconds:**

- Find new traces – they should all be green/healthy again
- "One flag toggle and we're back to normal"

---

## Part 7: Wrap-Up & Key Takeaways (3 min)

> "What did we learn?"

**Talking points:**

1. **OpenTelemetry is the standard** – one SDK, every language, every backend
2. **The Collector is your telemetry hub** – decouple apps from backends
3. **Distributed tracing finds problems fast** – follow a request across services
4. **It works with what you have** – EKS, GKE, on-prem, any Kubernetes cluster
5. **Getting started is easy** – the official demo is one `helm install`

**Getting started for YOUR apps:**

- Add the OpenTelemetry SDK to your service (most languages: a few lines of config)
- Or use **auto-instrumentation** (Java agent, Python agent, .NET agent) for zero code changes
- Point at a Collector, export to your backend of choice
- Start with traces – they give you the most immediate value

**Resources:**

- https://opentelemetry.io/docs/
- https://opentelemetry.io/docs/demo/
- This demo repo: _(share your GitHub link)_

---

## Bonus Scenarios (if you have extra time)

You can toggle other feature flags for more break/heal demos:

```bash
# See all available flags
kubectl get configmap flagd-config -n otel-demo -o jsonpath='{.data.demo\.flagd\.json}' | python3 -m json.tool | grep -A2 '"state"'
```

| Flag | What it does |
|------|-------------|
| `paymentFailure` | Payment service returns errors |
| `paymentUnreachable` | Payment service is unreachable |
| `productCatalogFailure` | Product catalog errors |
| `cartFailure` | Cart service fails |
| `adFailure` | Ad service errors |
| `kafkaQueueProblems` | Kafka queue issues |
| `imageSlowLoad` | Images load slowly |
| `recommendationCacheFailure` | Recommendation cache fails |

To toggle any flag, edit `break.sh` and change the `FLAG=` variable.

---

## Emergency Fallback

If the live cluster dies mid-talk:

1. Switch to your backup screen recording
2. Walk through the same trace screenshots
3. The teaching points are the same – the live demo just makes it more engaging
