-module(db).
-include("span.hrl").
%% API
-export([get_user/0]).

get_user() ->
  ?WITH_SPAN(utils:sleep_random()).