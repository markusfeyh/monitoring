-define(MFA_SPAN_NAME,
  iolist_to_binary(
    io_lib:format("~s:~s/~p",
      [?MODULE_STRING, ?FUNCTION_NAME, ?FUNCTION_ARITY]))).

-define(START_SPAN,
  _ = ocp:with_child_span(?MFA_SPAN_NAME)
).

-define(START_SPAN(Attrs),
  _ = ocp:with_child_span(?MFA_SPAN_NAME, Attrs)
).

-define(START_SPAN(SpanName, Attrs),
  _ = ocp:with_child_span(SpanName, Attrs)
).

-define(FINISH_SPAN,
  ocp:finish_span()
).


-define(INLINE_SPAN(SpanName, Attrs),
  ?START_SPAN(SpanName, Attrs), ?FINISH_SPAN
).
-define(INLINE_SPAN(Attrs),
  ?START_SPAN(Attrs), ?FINISH_SPAN
).

-define(INLINE_SPAN,
  ?START_SPAN, ?FINISH_SPAN
).

-define(WITH_SPAN(Body),
  begin
    ?START_SPAN,
    try
      Body
    after
      ?FINISH_SPAN
    end
  end
).
-define(WITH_SPAN(Attrs, Body),
  begin
    ?START_SPAN(Attrs),
    try
      Body
    after
      ?FINISH_SPAN
    end
  end
).
-define(WITH_SPAN(SpanName, Attrs, Body),
  begin
    ?START_SPAN(SpanName, Attrs),
    try
      Body
    after
      ?FINISH_SPAN
    end
  end
).