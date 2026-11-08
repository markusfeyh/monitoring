

webserver
https://github.com/ninenines/cowboy

example monitoring stack
https://github.com/ToddG/erlang-seed

prometheus
https://prometheus.io/docs/instrumenting/exposition_formats/#prometheus-text-format
https://github.com/prometheus-erl/prometheus.erl (moved from deadtrickster/prometheus.erl)
https://github.com/prometheus-erl/prometheus-cowboy (moved from deadtrickster/prometheus-cowboy)
https://hexdocs.pm/prometheus_cowboy/prometheus_cowboy2_instrumenter.html
Comes with a nice set of built-in labels
adds default configuration for you

tracing
OpenCensus (https://github.com/census-instrumentation/opencensus-erlang) was archived in 2023,
OpenTelemetry is its successor
https://opentelemetry.io/docs/languages/erlang/
https://github.com/open-telemetry/opentelemetry-erlang
https://github.com/open-telemetry/opentelemetry-erlang-contrib/tree/main/instrumentation/opentelemetry_cowboy
https://github.com/beam-telemetry/cowboy_telemetry
https://www.w3.org/TR/trace-context/
https://opentelemetry.io/docs/specs/otlp/

debugging
eper (https://github.com/massemanet/eper) is parked; its redbug lives on separately
https://github.com/ferd/recon
https://github.com/massemanet/redbug
