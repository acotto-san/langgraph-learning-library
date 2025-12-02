# Example Mapping Session — Milestone 2

Notes from a simulated example-mapping session for stories S6–S10. Each rule has at least one happy and one negative/edge example. Questions capture open decisions.

## S6 Webhook ingestion
- Rules:
  - R1: Expose HTTPS webhook endpoint with secret path/token.
  - R2: Accept only valid Telegram POST payloads; respond 200 quickly; reject other methods/paths.
  - R3: Validate/update metadata (`chat_id`, `user_id`, `message_id`, `timestamp`); keep per-chat partitioning.
- Examples:
  - E1 (R1, happy): Telegram sends POST to `/webhook/SECRET` with valid payload → 200 OK, payload accepted.
  - E2 (R1, negative): Request to `/webhook/wrong` → 404/403; nothing processed.
  - E3 (R2, happy): Valid POST processed in under 1s, 200 returned.
  - E4 (R2, negative): GET request to `/webhook/SECRET` returns 405 and is not processed.
  - E5 (R3, happy): Payload with chat_id/user_id is parsed; record tagged with those ids.
  - E6 (R3, negative): Payload missing chat_id is rejected/logged and not stored.
- Questions:
  - Q1: Should we verify Telegram IPs? (Decision: optional; skip in M2, document as future hardening.)
  - Q2: Should we verify signature/hmac? (Decision: Telegram secret path is used; deeper verification deferred.)

## S7 MongoDB storage
- Rules:
  - R1: Insert message documents with chat/user metadata and timestamps; maintain order.
  - R2: Enforce per-chat partition (index on `chat_id`, `timestamp`); no cross-chat bleed.
  - R3: Handle connectivity/write failures gracefully (log error; no partial writes).
- Examples:
  - E1 (R1, happy): Message with chat_id `c1`, ts `t1` inserted; subsequent message `t2` sorts after `t1`.
  - E2 (R1, negative): Insert missing chat_id is rejected with validation error; nothing written.
  - E3 (R2, happy): Index on `chat_id` + `timestamp` exists; query by `chat_id=c1` returns only c1 messages.
  - E4 (R2, negative): Query by `chat_id=c2` returns empty without mixing other chats.
  - E5 (R3, happy): Short Mongo outage triggers logged error, request fails cleanly, no partial doc stored.
  - E6 (R3, negative): Write attempt during disconnection returns an error; handler does not crash the process.
- Questions:
  - Q1: Use unique constraint on `message_id` per chat? (Decision: recommended; consider in M2 if driver support is simple.)
  - Q2: Do we need TTL/index for retention? (Decision: future milestone.)

## S8 LangGraph replies
- Rules:
  - R1: Forward incoming text to LangGraph agent and await reply with timeout.
  - R2: Send agent reply back to same chat; do not echo original message.
  - R3: On agent failure/timeout, send fallback message and log error.
- Examples:
  - E1 (R1, happy): Text "Hello" is sent to agent; reply "Hi!" received within timeout.
  - E2 (R1, negative): Agent exceeds timeout → treated as failure; no reply body returned.
  - E3 (R2, happy): Agent reply "Hi!" is sent to original chat_id; user sees only agent reply.
  - E4 (R2, negative): Attempt to send reply with missing chat_id is blocked/logged; nothing sent.
  - E5 (R3, happy): On agent error, user receives fallback "Sorry, something went wrong"; error is logged.
  - E6 (R3, negative): If fallback send fails, system logs an error and does not retry endlessly.
- Questions:
  - Q1: Should we stream partial replies? (Decision: not in M2.)
  - Q2: Should we store agent replies? (Decision: nice-to-have; optional in M2.)

## S9 Observability (logging/metrics)
- Rules:
  - R1: Log inbound webhooks and outbound replies with chat/message ids and correlation/trace ids.
  - R2: Log errors with exception info; severity levels respected.
  - R3: Emit metrics for received messages, sent replies, and failures.
- Examples:
  - E1 (R1, happy): A processed webhook logs an info entry with chat_id, message_id, and trace_id.
  - E2 (R1, negative): Missing trace_id generates a new one and logs it.
  - E3 (R2, happy): An agent error logs at error level with stack/exception.
  - E4 (R2, negative): Noisy info logs do not use error level.
  - E5 (R3, happy): Counter for received messages increments on each webhook.
  - E6 (R3, negative): Metrics emitter failure is logged at warning but does not crash request handling.
- Questions:
  - Q1: Which metric backend? (Decision: start with in-process counters/logs; real backend later.)
  - Q2: Log format JSON or text? (Decision: JSON for structure in M2.)

## S10 CI pipeline
- Rules:
  - R1: CI runs lint (`ruff`), types (`mypy`), and tests on push/PR; all must pass.
  - R2: CI fails fast on violations; reports failures clearly.
  - R3: CI avoids leaking secrets (no tokens in logs/config).
- Examples:
  - E1 (R1, happy): CI run with clean code passes ruff, mypy, and tests.
  - E2 (R1, negative): Code with a lint error fails the CI pipeline and reports the failing file.
  - E3 (R2, happy): Type error causes mypy step to fail the build early with a clear message.
  - E4 (R2, negative): Test failure stops pipeline and surfaces traceback.
  - E5 (R3, happy): Secrets scanner reports no secrets; logs do not contain tokens.
  - E6 (R3, negative): If a secret is committed, CI flags and fails the build.
- Questions:
  - Q1: Which CI provider? (Decision: GitHub Actions assumed; adaptable.)
  - Q2: Should we cache deps? (Decision: yes if convenient; not central to scenarios.)
