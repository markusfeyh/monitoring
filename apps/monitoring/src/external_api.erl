-module(external_api).

-include_lib("opentelemetry_api/include/opentelemetry.hrl").
-include("span.hrl").
%% API
-export([
  check_auth/0,
  make_request/0
]).

-define(SERVICE_URL, "http://127.0.0.1:4445/service").

check_auth() ->
  ?WITH_SPAN(utils:sleep_random()).

%% Outgoing HTTP call: a CLIENT span, with the W3C `traceparent' header
%% injected so /service continues the same trace.
make_request() ->
  ?with_span(?MFA_SPAN_NAME,
    #{kind => ?SPAN_KIND_CLIENT,
      attributes => #{'http.request.method' => <<"GET">>,
                      'url.full' => <<?SERVICE_URL>>}},
    fun(_SpanCtx) ->
      {ok, {{_, Status, _}, _, _}} =
        httpc:request(get, {?SERVICE_URL, trace_headers()}, [], []),
      ?set_attribute('http.response.status_code', Status)
    end).

%% otel_propagator_text_map:inject/1 works on [{binary(), binary()}];
%% httpc wants strings.
trace_headers() ->
  [{binary_to_list(K), binary_to_list(V)}
   || {K, V} <- otel_propagator_text_map:inject([])].
