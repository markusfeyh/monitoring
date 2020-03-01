%%%-------------------------------------------------------------------
%% @doc monitoring public API
%% @end
%%%-------------------------------------------------------------------

-module(monitoring_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    monitoring_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
