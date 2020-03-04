-module(metrics_handler).

-export([init/2]).
-export([content_types_provided/2]).
-export([get_text/2]).

init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.

content_types_provided(Req, State) ->
  {[
    {<<"text/plain">>, get_text}
  ], Req, State}.

get_text(Req, State) ->
  Body = prometheus_text_format:format(),
  {Body, Req, State}.