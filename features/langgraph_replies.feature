Feature: Send LangGraph-generated replies
  # Story: S8 (docs/product/backlog/m2-webhooks-mongo-langgraph.md)

  Scenario: Forward text to LangGraph and send reply back to chat
    Given an incoming text message "Hello" from chat_id "c1"
    And the LangGraph agent responds with "Hi!"
    When the bot processes the message
    Then the agent is called with "Hello"
    And the bot sends "Hi!" to chat_id "c1"

  Scenario: Do not echo original message as reply
    Given an incoming text message "Hello" from chat_id "c1"
    And the LangGraph agent responds with "Hi!"
    When the bot processes the message
    Then the message sent back to chat_id "c1" is "Hi!"
    And it is not identical to the original "Hello"

  Scenario: Timeout leads to graceful fallback
    Given the LangGraph agent takes longer than the configured timeout
    When the bot waits for a reply
    Then it sends a fallback message like "Sorry, something went wrong" to chat_id "c1"
    And logs the timeout as an error

  Scenario: Missing chat_id blocks sending reply
    Given an agent reply is produced but the chat_id is missing
    When the bot attempts to send the reply
    Then no message is sent
    And an error is logged
