-module(external_api).

-include("span.hrl").
%% API
-export([
  check_auth/0,
  make_request/0
]).

check_auth() ->
  ?WITH_SPAN(utils:sleep_random()).

make_request() ->
  ?WITH_SPAN(ibrowse:send_req("http:  //localhost:4445/service", [], get)).