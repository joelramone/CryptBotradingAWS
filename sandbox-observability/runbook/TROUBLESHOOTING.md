# CryptoBotradingAWS – Observability Runbook

## 0) Entradas rápidas
- CloudWatch Dashboard: `${project}-${env}-observability`
- SNS topic: `${project}-${env}-alarms`

## 1) Primer diagnóstico (5 minutos)
Revisar:
- AWS/Lambda: Errors, Throttles, Duration p95
- Custom EMF: OrdersRouted, OrdersAttempted, OrdersFilled, LambdaError, LambdaLatency

Alarmas clave:
- `*-orders-routed-zero`: posible caída de flujo
- `*-execution-router-lambdaerror`: error crítico de ejecución (EMF)
- `*-execution-router-error-rate`: error rate alto (Errors/Invocations)

## 2) Correlación (request_id / trace_id)
Tomar `request_id` del log `lambda_start` y buscar en Logs Insights.

### Query por request_id
fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter request_id = "REPLACE_ME"
| sort @timestamp asc


### Query por trace_id


fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter trace_id = "REPLACE_ME"
| sort @timestamp asc


### Errores últimos 60 min


fields @timestamp, level, message, request_id, trace_id, symbol, strategy_id, execution_id, service
| filter level in ["ERROR"] or message like /error/i
| sort @timestamp desc
| limit 200


## 3) Incidentes típicos

### A) OrdersAttempted sube y OrdersFilled cae
- Revisar logs del broker (`broker-binance` / `broker-alpaca`)
- Validar secretos / credenciales
- Chequear rate limit / bans / 429

### B) Throttling en Lambdas
- Ajustar concurrency (reserved/provisioned si aplica)
- Reducir paralelismo en triggers upstream

### C) Duration p95 alto / timeouts
- Buscar tramo lento por `latency_ms`
- Revisar dependencias externas
- Subir memory si aplica

### D) OrdersRouted = 0 (caída de flujo)
- Confirmar trigger upstream (scheduler / ingest)
- Revisar Step Function failures (si aplica)
- Revisar permisos IAM del trigger

## 4) Evidencia mínima para escalar
- `request_id` + `trace_id`
- extract logs (start → error)
- captura métrica (widget) con timestamp UTC
- nombre/ARN del recurso afectado