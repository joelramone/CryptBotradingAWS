from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from .context import ObsContext

METRIC_NAMESPACE = os.getenv("METRIC_NAMESPACE", "CryptoBot")


def _emf_base(
    ctx: Optional[ObsContext],
    dimensions: Dict[str, str],
    metrics: List[Dict[str, Any]],
) -> Dict[str, Any]:
    dims = dict(dimensions)
    if ctx:
        if ctx.symbol:
            dims.setdefault("symbol", ctx.symbol)
        if ctx.strategy_id:
            dims.setdefault("strategy_id", ctx.strategy_id)

    emf = {
        "_aws": {
            "Timestamp": int(datetime.now(timezone.utc).timestamp() * 1000),
            "CloudWatchMetrics": [
                {
                    "Namespace": METRIC_NAMESPACE,
                    "Dimensions": [list(dims.keys())] if dims else [[]],
                    "Metrics": metrics,
                }
            ],
        }
    }
    emf.update(dims)
    return emf


def emit_metric(
    name: str,
    value: float,
    unit: str = "None",
    *,
    ctx: Optional[ObsContext] = None,
    dimensions: Optional[Dict[str, str]] = None,
    props: Optional[Dict[str, Any]] = None,
) -> None:
    dims = dimensions or {}
    base = _emf_base(ctx, dims, [{"Name": name, "Unit": unit}])
    base[name] = value
    if props:
        base.update(props)
    print(json.dumps(base, ensure_ascii=False))


def emit_latency_metric(
    name: str,
    latency_ms: float,
    *,
    ctx: Optional[ObsContext] = None,
    dimensions: Optional[Dict[str, str]] = None,
    props: Optional[Dict[str, Any]] = None,
) -> None:
    emit_metric(
        name=name,
        value=float(latency_ms),
        unit="Milliseconds",
        ctx=ctx,
        dimensions=dimensions,
        props=props,
    )


def emit_counter(
    name: str,
    count: int = 1,
    *,
    ctx: Optional[ObsContext] = None,
    dimensions: Optional[Dict[str, str]] = None,
    props: Optional[Dict[str, Any]] = None,
) -> None:
    emit_metric(
        name=name,
        value=float(count),
        unit="Count",
        ctx=ctx,
        dimensions=dimensions,
        props=props,
    )
