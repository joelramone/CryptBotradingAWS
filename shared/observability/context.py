from __future__ import annotations

import os
import re
import uuid
from dataclasses import dataclass, field
from typing import Any, Dict, Optional


_TRACE_RE = re.compile(r"Root=([^;]+)")


def _get_trace_id() -> str:
    # AWS X-Ray trace header (Lambda env)
    hdr = os.getenv("_X_AMZN_TRACE_ID", "")
    m = _TRACE_RE.search(hdr)
    if m:
        return m.group(1)
    return f"local-{uuid.uuid4().hex}"


@dataclass
class ObsContext:
    request_id: str
    trace_id: str
    symbol: Optional[str] = None
    strategy_id: Optional[str] = None
    execution_id: Optional[str] = None
    extra: Dict[str, Any] = field(default_factory=dict)

    @staticmethod
    def from_lambda(event: Any, aws_request_id: str) -> "ObsContext":
        # best-effort extraction from common shapes
        symbol = None
        strategy_id = None
        execution_id = None

        if isinstance(event, dict):
            symbol = event.get("symbol") or event.get("Symbol") or (event.get("input", {}) or {}).get("symbol")
            strategy_id = event.get("strategy_id") or event.get("strategyId") or event.get("strategy")
            execution_id = event.get("execution_id") or event.get("executionId")

        return ObsContext(
            request_id=aws_request_id,
            trace_id=_get_trace_id(),
            symbol=symbol,
            strategy_id=strategy_id,
            execution_id=execution_id,
        )

    def as_log_fields(self) -> Dict[str, Any]:
        base = {
            "request_id": self.request_id,
            "trace_id": self.trace_id,
        }
        if self.symbol:
            base["symbol"] = self.symbol
        if self.strategy_id:
            base["strategy_id"] = self.strategy_id
        if self.execution_id:
            base["execution_id"] = self.execution_id
        if self.extra:
            base.update(self.extra)
        return base
