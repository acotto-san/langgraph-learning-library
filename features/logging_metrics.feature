Feature: Structured logging and basic metrics
  # Story: S9 (docs/product/backlog/m2-webhooks-mongo-langgraph.md)

  Scenario: Log inbound webhook with trace and chat identifiers
    Given a webhook request for chat_id "c1" and message_id "m1"
    When the request is processed
    Then an info log entry is written containing chat_id "c1", message_id "m1", and a trace_id

  Scenario: Generate a trace_id if missing
    Given a webhook request without a trace_id
    When the request is processed
    Then a new trace_id is generated and logged with the request

  Scenario: Log errors with exception details
    Given the LangGraph agent returns an error during processing
    When the bot handles the error
    Then an error-level log entry includes the exception message and stack info

  Scenario: Emit metrics for received messages and failures
    Given metrics are enabled
    When a webhook message is processed successfully
    Then the "received_messages" counter increments
    When a processing error occurs
    Then the "failures" counter increments

  Scenario: Metrics emitter failure is non-fatal
    Given the metrics backend is temporarily unavailable
    When a message is processed
    Then a warning is logged about metrics emission failure
    And the request handling still completes
