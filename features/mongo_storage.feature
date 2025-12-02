Feature: Persist messages to MongoDB
  # Story: S7 (docs/product/backlog/m2-webhooks-mongo-langgraph.md)

  Scenario: Insert messages with chat/user metadata in order
    Given a MongoDB collection with an index on chat_id and timestamp
    When messages with chat_id "c1" and timestamps "t1" then "t2" are inserted
    Then both messages are stored
    And sorting by timestamp returns "t1" before "t2"

  Scenario: Reject insert missing chat_id
    Given a MongoDB collection
    When an insert is attempted with no chat_id
    Then the insert is rejected with a validation error
    And no document is written

  Scenario: Query returns only messages for a chat
    Given stored messages for chat_id "c1" and chat_id "c2"
    When I query messages filtered by chat_id "c1"
    Then only messages for "c1" are returned
    And no messages for "c2" appear

  Scenario: Handle write failure without partial writes
    Given MongoDB becomes unavailable during an insert
    When the repository attempts to write a message
    Then it surfaces an error and logs it
    And no partial or duplicate document is stored
