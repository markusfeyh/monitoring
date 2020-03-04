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
    opencensus_cowboy2_instrumenter:setup(),
    prometheus_cowboy2_instrumenter:setup(),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/metrics/[:registry]", prometheus_cowboy2_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 4445}],
        #{env => #{dispatch => Dispatch},
            middlewares => [opencensus_cowboy2_context, cowboy_router, cowboy_handler],
            metrics_callback => fun metrics_callbacks/1,
            stream_handlers => [cowboy_metrics_h, cowboy_stream_h]}),

    monitoring_sup:start_link().

metrics_callbacks(Metrics) ->
    prometheus_cowboy2_instrumenter:observe(Metrics),
    opencensus_cowboy2_instrumenter:observe(Metrics).

stop(_State) ->
    ok = cowboy:stop_listener(http).