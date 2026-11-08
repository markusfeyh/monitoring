monitoring
=====

A small Erlang/OTP demo of how to monitor a service with **metrics**
(Prometheus) and **distributed tracing** (OpenTelemetry).

A [cowboy](https://github.com/ninenines/cowboy) server on port 4445 exposes:

| Path       | What it does                                                                                |
|------------|---------------------------------------------------------------------------------------------|
| `/request` | Calls a fake auth check and fake DB functions (random sleeps), then calls `/service` over HTTP. |
| `/service` | The "downstream service": more fake auth and DB calls.                                      |
| `/metrics` | Prometheus metrics: cowboy request counters and histograms, plus Erlang VM metrics.       |

Every function is wrapped in a span named after it (`?WITH_SPAN`, see
[`span.hrl`](apps/monitoring/include/span.hrl)). One call to `/request`
therefore produces a single trace across both HTTP hops:

```
GET  url.path=/request                (SERVER, opentelemetry_cowboy)
└─ request_handler:get_text/2
   ├─ external_api:check_auth/0
   ├─ db:get_user/0
   ├─ external_api:make_request/0     (CLIENT, sends `traceparent`)
   │  └─ GET  url.path=/service       (SERVER)
   │     └─ service_handler:get_text/2
   │        ├─ external_api:check_auth/0
   │        ├─ db:get_user/0
   │        └─ db:update_user/0
   └─ db:update_user/0
```

How it's wired
--------------

* **Metrics**: [prometheus_cowboy](https://github.com/prometheus-erl/prometheus-cowboy)
  turns cowboy's `cowboy_metrics_h` callbacks into Prometheus metrics, and
  [prometheus.erl](https://github.com/prometheus-erl/prometheus.erl) adds its
  default Erlang VM collectors. `prometheus_cowboy2_handler` serves `/metrics`.
* **Traces**: [opentelemetry_cowboy](https://github.com/open-telemetry/opentelemetry-erlang-contrib/tree/main/instrumentation/opentelemetry_cowboy)
  creates a server span per request from
  [cowboy_telemetry](https://github.com/beam-telemetry/cowboy_telemetry) events.
  Cowboy runs handlers in their own process, so `trace_ctx_middleware` makes
  that server span the parent of the handler spans.
  `external_api:make_request/0` injects the
  [W3C trace context](https://www.w3.org/TR/trace-context/) (`traceparent`)
  into the outgoing `httpc` request, so `/service` continues the same trace.
* **Export**: spans are batched and sent with
  [OTLP](https://opentelemetry.io/docs/specs/otlp/) over HTTP/protobuf to
  `http://localhost:4318` (see [`config/sys.config`](config/sys.config)). Set
  `OTEL_EXPORTER_OTLP_ENDPOINT` to send them somewhere else. If nothing is
  listening, the spans are dropped and the service keeps working.

Run it
------

Tested with Erlang/OTP 29.1 and rebar3 3.28.

    $ rebar3 release
    $ _build/default/rel/monitoring/bin/monitoring foreground   # or: daemon, then: stop

or, for development, `rebar3 shell`.

    $ curl localhost:4445/request
    $ curl localhost:4445/metrics

Viewing traces
--------------

Start any backend that accepts OTLP before you send requests, for example:

* **Jaeger** (all-in-one, UI on http://localhost:16686, pick service `monitoring`):

      docker run --rm -p 16686:16686 -p 4317:4317 -p 4318:4318 jaegertracing/jaeger:latest

* **Grafana Tempo** with Grafana, Prometheus and Loki in one container
  ([grafana/otel-lgtm](https://github.com/grafana/docker-otel-lgtm), Grafana on http://localhost:3000):

      docker run --rm -p 3000:3000 -p 4317:4317 -p 4318:4318 grafana/otel-lgtm

* **Zipkin**: the [zipkin-otel](https://github.com/openzipkin-contrib/zipkin-otel)
  image adds an OTLP/HTTP receiver on Zipkin's own port:

      docker run --rm -p 9411:9411 ghcr.io/openzipkin-contrib/zipkin-otel
      OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:9411 _build/default/rel/monitoring/bin/monitoring foreground

Viewing metrics
---------------

`/metrics` uses the Prometheus text format, so any Prometheus-compatible
scraper works. A minimal `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: monitoring
    static_configs:
      - targets: ["localhost:4445"]
```

Note that prometheus.erl 6 renamed some VM metrics to follow OpenMetrics
naming (e.g. `erlang_vm_process_count` is now `erlang_vm_processes`).

Debugging a live node
---------------------

The release includes [recon](https://github.com/ferd/recon):

    $ _build/default/rel/monitoring/bin/monitoring remote_console
    1> recon:proc_count(memory, 5).

For production-safe call tracing, add
[redbug](https://github.com/massemanet/redbug). It started out in eper,
which this demo used to depend on.
