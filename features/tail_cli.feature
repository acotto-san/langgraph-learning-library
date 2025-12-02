Feature: Tail recent messages via CLI
  # Story: S4 (docs/product/backlog/m1-message-capture.md)

  Scenario: Tail last 20 messages for a specific chat
    Given a JSONL file at "data/messages.jsonl" containing 30 messages across chats "123" and "456"
    When I run `python -m src.cli.tail --chat-id 123`
    Then I see only the last 20 messages for chat "123"
    And no messages from chat "456" appear

  Scenario: Reject invalid limit input
    Given a JSONL file at "data/messages.jsonl" containing messages for chat "123"
    When I run `python -m src.cli.tail --chat-id 123 --limit 0`
    Then the CLI prints a usage error explaining the limit must be positive
    And the command exits with a non-zero status without a stack trace

  Scenario: Output is human-readable
    Given a JSONL file at "data/messages.jsonl" containing a message with timestamp "2023-01-01T12:00:00Z" from user "user_1" saying "Hello"
    When I run `python -m src.cli.tail --chat-id 123 --limit 1`
    Then the output line shows the timestamp, a user label, and the text "Hello" in a readable format

  Scenario: Long text is handled without breaking format
    Given a JSONL file at "data/messages.jsonl" containing a message for chat "123" with text longer than 500 characters
    When I run `python -m src.cli.tail --chat-id 123 --limit 1`
    Then the output shows the long text truncated or wrapped clearly
    And the format of the line remains readable

  Scenario: CLI handles missing storage file gracefully
    Given no JSONL file exists at "data/messages.jsonl"
    When I run `python -m src.cli.tail --chat-id 123`
    Then the CLI prints "no messages found" with a hint to run the bot
    And the command exits successfully
