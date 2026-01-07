from __future__ import annotations

import time
from typing import Any, Callable, Dict, Tuple

from .context import ObsContext
from .logger import bind_context, get_logger
from .metrics import emit_counter, emit_latency_metric


def instrument_lambda(service_name: str) -> Callable[[Callable[..., Any]], Callable[..., Any]]:
    """
    Usage:
      @instrument_lambda("execution-router")
      def handler(event, context): ...
    """
    def decorator(fn: Callable[..., Any]) -> Callable[..., Any]:
        def wrapper(event: Any, context: Any) -> Any:
            start = time.perf_counter()

            aws_request_id = getattr(context, "aws_request_id", "unknown")
            ctx = ObsContext.from_lambda(event, aws_request_id)
            logger = bind_context(get_logger(service_name), ctx)

            logger.info("lambda_start", extra={"obs": {"service": service_name}})

            try:
                result = fn(event, context, logger, ctx)
                emit_counter("LambdaSuccess", 1, ctx=ctx, dimensions={"service": service_name})
                return result
            except Exception as e:
                emit_counter("LambdaError", 1, ctx=ctx, dimensions={"service": service_name})
                logger.exception("lambda_error", extra={"obs": {"service": service_name}})
                raise
            finally:
                elapsed_ms = (time.perf_counter() - start) * 1000.0
                emit_latency_metric("LambdaLatency", elapsed_ms, ctx=ctx, dimensions={"service": service_name})
                logger.info("lambda_end", extra={"obs": {"service": service_name, "latency_ms": elapsed_ms}})
        return wrapper
    return decorator
