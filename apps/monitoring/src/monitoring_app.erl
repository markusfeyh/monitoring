%%%-------------------------------------------------------------------
%% @doc monitoring public API
%% @end
%%%-------------------------------------------------------------------

-module(monitoring_app).

-behaviour(application).

%% API.
-export([start/2]).
-export([stop/1]).

%% API.

start(_Type, _Args) ->
    prometheus_cowboy2_instrumenter:setup(),
    opentelemetry_cowboy:setup(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/metrics/[:registry]", prometheus_cowboy2_handler, []},
            {"/request", request_handler, []},
            {"/service", service_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 4445}],
        #{env => #{dispatch => Dispatch},
            middlewares => [trace_ctx_middleware, cowboy_router, cowboy_handler],
            %% cowboy_metrics_h feeds prometheus_cowboy through metrics_callback.
            %% cowboy_telemetry_h emits the telemetry events opentelemetry_cowboy
            %% turns into server spans. It must come after cowboy_metrics_h, as
            %% it replaces metrics_callback for the stream handlers below it.
            metrics_callback => fun prometheus_cowboy2_instrumenter:observe/1,
            stream_handlers => [cowboy_metrics_h, cowboy_telemetry_h, cowboy_stream_h]}),

    monitoring_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).
