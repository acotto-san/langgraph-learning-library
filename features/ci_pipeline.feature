Feature: CI pipeline for linting, typing, and tests
  # Story: S10 (docs/product/backlog/m2-webhooks-mongo-langgraph.md)

  Scenario: CI passes when code is clean
    Given the repository has no lint, type, or test failures
    When CI runs ruff, mypy, and pytest
    Then all steps pass and the pipeline succeeds

  Scenario: Lint failure blocks the pipeline
    Given a file has a ruff lint violation
    When CI runs ruff
    Then the pipeline fails and reports the offending file

  Scenario: Type error blocks the pipeline
    Given a file has a mypy type error
    When CI runs mypy
    Then the pipeline fails and reports the type error

  Scenario: Test failure stops the pipeline
    Given a failing test exists
    When CI runs pytest
    Then the pipeline fails and surfaces the failing test and traceback

  Scenario: Secrets check prevents leaks
    Given a secret token is accidentally committed
    When CI runs the secrets scanner
    Then the pipeline fails and reports the secret
