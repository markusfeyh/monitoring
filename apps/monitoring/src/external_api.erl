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
  ?START_SPAN,
  ibrowse:send_req("http://127.0.0.1:4445/service", get_span_header(), get),
  ?FINISH_SPAN.

get_span_header() ->
  [{BinHeader, IOList}] = oc_propagation_http_tracecontext:to_headers(ocp:current_span_ctx()),
  [{binary_to_list(BinHeader), binary_to_list(iolist_to_binary(IOList))}].
