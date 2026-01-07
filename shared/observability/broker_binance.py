from __future__ import annotations

from typing import Any, Dict

from shared.observability import get_logger, bind_context, emit_counter, emit_latency_metric


def place_order(order: Dict[str, Any], obs_ctx):
    logger = bind_context(get_logger("broker-binance"), obs_ctx)

    logger.info("place_order_start", extra={"obs": {"service": "broker-binance"}})
    emit_counter("OrdersAttempted", 1, ctx=obs_ctx, dimensions={"service": "broker-binance"})

    # TODO: integrate real Binance client
    # On success:
    emit_counter("OrdersFilled", 1, ctx=obs_ctx, dimensions={"service": "broker-binance"})
    logger.info("place_order_ok", extra={"obs": {"service": "broker-binance"}})

    return {"status": "FILLED", "broker": "binance", "order": order}
