%%%-------------------------------------------------------------------
%% @doc Makes the request's server span the current span in the
%% request process.
%%
%% opentelemetry_cowboy starts the server span from cowboy_telemetry_h,
%% a stream handler, so it lives in the connection process. Cowboy runs
%% middlewares and handlers in a separate request process spawned from
%% it; copying the context over makes the handler spans children of
%% the server span. (opentelemetry_phoenix does the same for cowboy.)
%% @end
%%%-------------------------------------------------------------------
-module(trace_ctx_middleware).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req, Env) ->
    case opentelemetry_process_propagator:fetch_parent_ctx() of
        undefined -> ok;
        Ctx -> otel_ctx:attach(Ctx)
    end,
    {ok, Req, Env}.
