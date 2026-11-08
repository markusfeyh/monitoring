%% Small helpers on top of the OpenTelemetry API macros (?with_span etc.).
-include_lib("opentelemetry_api/include/otel_tracer.hrl").

%% Span name for the enclosing function, e.g. <<"db:get_user/0">>.
-define(MFA_SPAN_NAME,
  iolist_to_binary(
    io_lib:format("~s:~s/~p",
      [?MODULE_STRING, ?FUNCTION_NAME, ?FUNCTION_ARITY]))).

%% Evaluate Body inside a child span of the current span. The span is ended
%% and the previous span made current again, even if Body throws.
%% Wrap multiple expressions in begin ... end.
-define(WITH_SPAN(Body),
  ?WITH_SPAN(#{}, Body)).

-define(WITH_SPAN(Attrs, Body),
  ?WITH_SPAN(?MFA_SPAN_NAME, Attrs, Body)).

-define(WITH_SPAN(SpanName, Attrs, Body),
  ?with_span(SpanName, #{attributes => Attrs}, fun(_SpanCtx) -> Body end)).
