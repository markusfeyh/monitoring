-module(utils).

%% API
-export([sleep_random/0]).

sleep_random() ->
  ReqTime = round(abs(1000 * rand:normal())),
  timer:sleep(ReqTime).
