Feature: Environment and settings handling
  # Story: S2 (docs/product/backlog/m1-message-capture.md)

  Scenario: Default storage path is applied when only BOT_TOKEN is provided
    Given an environment with BOT_TOKEN set to "123" and STORAGE_PATH not set
    When the application starts
    Then it initializes storage at "./data/messages.jsonl"

  Scenario: Startup fails fast when BOT_TOKEN is missing
    Given an environment with no BOT_TOKEN set
    When the application starts
    Then it exits with an error message containing "BOT_TOKEN is required"

  Scenario: Startup fails when STORAGE_PATH is not writable
    Given an environment with BOT_TOKEN set to "123" and STORAGE_PATH set to "/root/forbidden/messages.jsonl"
    When the application starts
    Then it exits with an error message indicating the storage path cannot be written
