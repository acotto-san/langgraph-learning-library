Feature: Receive Telegram updates via webhook
  # Story: S6 (docs/product/backlog/m2-webhooks-mongo-langgraph.md)

  Scenario: Accept a valid POST on the secret webhook path
    Given a Telegram POST request to "/webhook/SECRET" with a valid update payload
    When the webhook handler processes the request
    Then it responds with HTTP 200
    And the payload is accepted for further processing

  Scenario: Reject requests to an incorrect webhook path
    Given a POST request to "/webhook/wrong" with any payload
    When the webhook handler processes the request
    Then it responds with HTTP 404 or 403
    And the payload is not processed

  Scenario: Reject non-POST methods on the webhook
    Given a GET request to "/webhook/SECRET"
    When the webhook handler processes the request
    Then it responds with HTTP 405
    And the payload is not processed

  Scenario: Reject malformed payload missing chat_id
    Given a Telegram POST request to "/webhook/SECRET" missing chat_id
    When the webhook handler processes the request
    Then it responds with HTTP 400
    And logs a warning that the payload was rejected
