Feature: Tests and quality checks
  # Story: S5 (docs/product/backlog/m1-message-capture.md)

  Scenario: Handler normalizes a text update without mutation
    Given a fake Telegram text update with chat_id "chat_1", user_id "user_1", message_id "10", and text "Hello"
    When the handler processes the update
    Then it returns a record containing chat_id "chat_1", user_id "user_1", message_id "10", and text "Hello"
    And the original update object remains unchanged

  Scenario: Handler rejects a text update missing text
    Given a fake Telegram text update with chat_id "chat_1", user_id "user_1", message_id "11", and no text
    When the handler processes the update
    Then it raises or returns a validation error
    And the storage layer is not called

  Scenario: Storage retrieval partitions by chat
    Given messages from chats "chat_A" and "chat_B" are written to storage
    When I request messages filtered by chat_id "chat_A"
    Then only messages from "chat_A" are returned
    And no messages from "chat_B" are included

  Scenario: Storage retrieval returns empty when chat has no messages
    Given messages from chat "chat_A" are written to storage
    When I request messages filtered by chat_id "chat_C"
    Then an empty result is returned without error

  Scenario: Static checks pass cleanly
    Given the codebase has no lint or type errors
    When I run `ruff check` and `mypy`
    Then both commands exit with status 0

  Scenario: Static checks fail on violations
    Given a file contains a lint or type violation
    When I run `ruff check` or `mypy`
    Then the command exits with a non-zero status and reports the violation
