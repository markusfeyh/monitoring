-module(request_handler).
-include("span.hrl").

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
  ?WITH_SPAN(begin
    external_api:check_auth(),
    db:get_user(),
    external_api:make_request(),
    db:update_user()
  end),
  {"body response", Req, State}.
