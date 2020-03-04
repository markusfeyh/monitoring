-module(external_api).

-include("span.hrl").
%% API
-export([check_auth/0]).

check_auth() ->
  ?WITH_SPAN(utils:sleep_random()).