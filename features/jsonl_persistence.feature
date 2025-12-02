Feature: Append messages to JSONL storage
  # Story: S3 (docs/product/backlog/m1-message-capture.md)

  Scenario: Messages from the same chat append in order
    Given an empty JSONL file at "data/messages.jsonl"
    When messages "Hello" and "How are you?" arrive from chat "chat_1" user "user_1" in that order
    And the handler writes them to storage
    Then the JSONL file has 2 lines
    And line 1 includes "chat_id":"chat_1" and "text":"Hello"
    And line 2 includes "chat_id":"chat_1" and "text":"How are you?"

  Scenario: Messages from different chats are kept distinct
    Given an empty JSONL file at "data/messages.jsonl"
    When a message "Ping" arrives from chat "chat_X" user "user_X"
    And a message "Pong" arrives from chat "chat_Y" user "user_Y"
    And the handler writes them to storage
    Then the JSONL file has 2 lines
    And one line includes "chat_id":"chat_X" and "text":"Ping"
    And one line includes "chat_id":"chat_Y" and "text":"Pong"

  Scenario: Create storage file and directory on first write
    Given no file exists at "tmp/data/messages.jsonl" and the directory "tmp/data" does not exist
    When a message "Hello" arrives from chat "chat_new" user "user_new"
    And the handler writes it to storage at "tmp/data/messages.jsonl"
    Then the directory "tmp/data" is created
    And the JSONL file "tmp/data/messages.jsonl" exists with 1 line containing "chat_id":"chat_new"

  Scenario: Fail gracefully when directory creation is denied
    Given a storage path at "/root/forbidden/messages.jsonl" that cannot be created or written
    When a message "Hello" arrives from chat "chat_denied" user "user_denied"
    And the handler attempts to write it to storage at "/root/forbidden/messages.jsonl"
    Then no JSONL file is created
    And an error is logged indicating the storage path could not be created or written

  Scenario: Reject messages missing chat_id
    Given an empty JSONL file at "data/messages.jsonl"
    When a message "Hello" arrives without a chat_id but with user "user_missing"
    And the handler processes the update
    Then the JSONL file remains empty
    And a warning is logged that the record was skipped due to missing chat_id

  Scenario: Do not persist partial lines on write failure
    Given an empty JSONL file at "data/messages.jsonl" and the file system becomes read-only after the first write
    When a message "First" arrives from chat "chat_1" user "user_1"
    And a message "Second" arrives from chat "chat_1" user "user_1"
    And the handler writes the first message successfully but fails on the second due to write error
    Then the JSONL file contains only 1 line for "First"
    And an error is logged indicating the second write failed and no partial line was persisted
