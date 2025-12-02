Feature: Capture incoming text messages with metadata
  # Story: S1 (docs/product/backlog/m1-message-capture.md)

  Scenario: Capture a text message as a JSONL record
    Given the bot is running with a valid BOT_TOKEN and JSONL storage at "data/messages.jsonl"
    And a text message arrives from chat "A_chat" user "A_user" with message_id "42" and text "Hello there"
    When the message handler processes the update
    Then the JSONL file contains 1 line
    And the line includes "chat_id":"A_chat", "user_id":"A_user", "message_id":"42", and "text":"Hello there"

  Scenario: Reject a malformed text update missing required fields
    Given the bot is running with a valid BOT_TOKEN and JSONL storage at "data/messages.jsonl"
    And a text update arrives from chat "A_chat" user "A_user" with message_id "43" but no text
    When the message handler processes the update
    Then the JSONL file remains unchanged
    And a warning log entry notes the malformed text update was skipped

  Scenario: Ignore a non-text update (sticker)
    Given the bot is running with a valid BOT_TOKEN and JSONL storage at "data/messages.jsonl"
    And a sticker update arrives from chat "A_chat" user "A_user"
    When the message handler processes the update
    Then the JSONL file remains unchanged
    And an info log entry notes that a non-text message was skipped

  Scenario: Keep conversations partitioned by chat
    Given the bot is running with a valid BOT_TOKEN and JSONL storage at "data/messages.jsonl"
    And a text message arrives from chat "chat_X" user "user_X" with message_id "100" and text "Ping"
    And a text message arrives from chat "chat_Y" user "user_Y" with message_id "200" and text "Pong"
    When the message handler processes both updates
    Then the JSONL file contains 2 lines
    And one line includes "chat_id":"chat_X" and not "chat_id":"chat_Y"
    And one line includes "chat_id":"chat_Y" and not "chat_id":"chat_X"
