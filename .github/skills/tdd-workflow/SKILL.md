---
name: tdd-workflow
description: Plan, implement, and verify code changes using test-first red-green-refactor. Use for features, bug fixes, and refactors.
---

# Test-Driven Development Workflow

Follow `../solid-tdd-craft/SKILL.md` and its Restrictions. This workflow applies to behavioral code changes; documentation-only edits do not need invented tests. For static configuration changes, run applicable schema, build, or configuration checks and explain where a behavioral test is not applicable.

## Before editing

1. Restate the goal and acceptance criteria. Ask when a requirement is ambiguous.
2. Survey the relevant implementation, tests, naming, and project commands.
3. Use the simplest established approach. Compare viable alternatives when a meaningful design decision exists; do not invent a second approach for a trivial fix. Ask before unresolved choices that change behavior or compatibility.
4. Identify input boundaries, failure cases, and the smallest behavior to test first.

## Red-green-refactor

For each behavior:

1. **Red:** write one focused test that describes an observable outcome; run it and confirm it fails for the expected reason.
2. **Green:** make the smallest production change that passes the test; run the focused tests.
3. **Refactor:** improve the design without changing behavior; rerun relevant tests.

Repeat for the next behavior. A bug fix starts with a test that reproduces the bug. Do not write production code before its failing test.

## Test quality

- Use the project's naming and test structure; otherwise name tests `should_<outcome>_when_<condition>`.
- Keep each test focused on one behavior, deterministic, isolated, and explicit about its Arrange / Act / Assert steps.
- Prefer real behavior through public interfaces. Mock only boundaries owned by the code under test.
- Cover the happy path, meaningful boundaries, invalid inputs, and relevant failure paths.
- Never delete, weaken, skip, or leave focused tests to hide a failure. When an approved behavior change supersedes an old expectation, replace it with coverage of the new acceptance criterion and retain unaffected regression coverage; explain the intentional expectation change.
- Distinguish an expected assertion failure from a setup, import, or unavailable-service failure; the latter does not establish the red step. If required tooling is unavailable, report the blocker rather than treating the test as passed.
- For refactors, run existing tests first and add characterization tests for relevant unprotected behavior before changing it. Existing passing tests can guard unchanged behavior; do not intentionally break them merely to manufacture a red step.
- Use unit tests for domain decisions, integration tests for affected real boundaries, and end-to-end tests for critical changed journeys. Test concurrency, retries, and cancellation only where the change introduces or affects them.
- Ensure test fixtures and mocks do not implement the feature themselves or bypass the registration/boundary under test. Assert externally observable outcomes, including durable state or rendered UI where relevant; snapshots, import checks, and mocked call counts alone do not prove the requested journey works.
- Keep asynchronous tests deterministic using the repository's clocks, synchronization, and isolated resources. Await assertions and cleanup; do not hide timing failures with arbitrary sleeps or automatic retries of failing tests.

## Verification

- Run the smallest relevant test command after each change, then the broader required checks when appropriate.
- Report exact checks run and their results. If a check cannot run, say why and provide the command needed to run it.
- Before finishing, review the diff for scope, regressions, documentation needs, and unverified assumptions.
- Verify the actual application entry point uses the new code; a passing isolated helper test is not evidence of delivery. If the baseline already fails, report those failures separately and ensure the change introduces no additional failures; do not claim a green suite.
