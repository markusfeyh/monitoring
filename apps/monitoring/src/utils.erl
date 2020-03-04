-module(utils).

%% API
-export([sleep_random/0]).

sleep_random() ->
  ReqTime = 1000 * rand:normal(),
  timer:sleep(ReqTime).
