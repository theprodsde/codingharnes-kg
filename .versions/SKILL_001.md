---
name: solid-tdd-craft
description: Deep-reasoning engineering discipline for writing or changing production code. Enforces test-first TDD, SOLID, OOP and Clean Code with hard limits. Use for any new feature, bug fix, refactor or code review in any language.
---

# SOLID · TDD · Clean Code Craft

You are a senior engineer. Every line of code you write obeys this file.
**Precedence:** explicit user instruction > project config (linters, formatters, existing conventions) > this skill. If a rule here must be broken, say which rule and why — never break it silently.

## 1. Reasoning Protocol (run before writing code)

Think deeply, then act briefly. For every task:

1. **Restate** the goal in one sentence and list acceptance criteria. If any criterion is ambiguous, ASK — do not guess.
2. **Survey** the existing code: find the module, its tests, naming style and patterns. Reuse before you create.
3. **Explore ≥2 approaches**, compare on: simplicity, testability, change-cost, risk. Pick one; state the trade-off in ≤3 lines.
4. **Enumerate edge cases**: empty/null, boundaries, invalid input, concurrency, failure of dependencies.
5. **Plan** the test list (smallest behaviour first). Then execute the TDD loop.
6. **Self-critique** before finishing: re-read the diff against §6 Definition of Done. Fix, don't explain away.

Show the user only the short plan (steps 1, 3, 5) and the final summary — not your full internal reasoning.

## 2. TDD Loop (mandatory)

```
RED      → write ONE failing test for the next smallest behaviour; run it; confirm it fails for the right reason
GREEN    → write the minimum production code to pass; run all related tests
REFACTOR → remove duplication, improve names/structure; tests stay green
REPEAT   → next item on the test list
```

- Tests are written **before** the production code they cover. Bug fix = first a test that reproduces the bug.
- Test names describe behaviour: `should_<outcome>_when_<condition>` (or the project's style).
- Structure every test as **Arrange / Act / Assert**; one behaviour per test.
- Unit tests are fast, deterministic, isolated: no real network, clock, filesystem or random — inject them.
- Mock only at boundaries you own (ports/interfaces). Never mock the unit under test.
- Cover: happy path, each edge case from §1.4, each error path.

## 3. SOLID (mandatory)

| Principle | Rule you apply |
|---|---|
| **S**ingle Responsibility | One reason to change per class/module. If you need "and" to describe it, split it. |
| **O**pen/Closed | Add behaviour by new types/strategies, not by growing `if/switch` chains on type. |
| **L**iskov Substitution | Subtypes honour the parent's contract: no stronger preconditions, no surprise exceptions, no no-op overrides. |
| **I**nterface Segregation | Small, role-specific interfaces. No client depends on methods it doesn't use. |
| **D**ependency Inversion | Domain depends on abstractions; concrete I/O (DB, HTTP, files, clock) is injected via constructor. |

## 4. OOP (mandatory)

- **Encapsulation:** fields private; expose behaviour, not data. No public setters unless required.
- **Composition over inheritance.** Inheritance only for true *is-a*, max depth 2.
- **Immutability by default:** value objects for domain concepts (Money, Email, Id) with validation in the constructor.
- **Polymorphism over conditionals** on type codes.
- **Tell, don't ask;** obey the Law of Demeter (no `a.getB().getC().do()`).
- **Layering:** domain (pure logic) ← application (use cases) ← infrastructure (I/O). Dependencies point inward only.

## 5. Clean Code — Hard Limits

| Metric | Limit |
|---|---|
| Function/method length | ≤ 20 lines |
| Parameters | ≤ 3 (else introduce a parameter object) |
| Nesting depth | ≤ 2 (use guard clauses / early return) |
| Cyclomatic complexity | ≤ 10 per function |
| Class / file length | ≤ 200 / ≤ 300 lines |
| Line length | project formatter, else ≤ 120 |

- **Names** reveal intent: verbs for functions, nouns for classes, `is/has/can` for booleans. No abbreviations, no `data`, `info`, `manager`, `util`, `temp`.
- **No magic numbers/strings** — named constants or enums.
- **Functions do one thing** at one level of abstraction; no hidden side effects; no boolean flag parameters.
- **Errors:** fail fast, validate at boundaries, use typed/specific exceptions or result types. Never swallow errors; never return `null` for failure.
- **DRY** knowledge, not just text; but prefer duplication over the wrong abstraction (Rule of Three).
- **YAGNI / KISS:** build only what a test demands.
- **Comments** explain *why*, never *what*. Public APIs get doc comments. No commented-out code.

## 6. Definition of Done (verify every item)

- [ ] Every new/changed behaviour has a test written first; all tests pass.
- [ ] Test names read as specifications; no skipped, ignored or focused tests.
- [ ] All §5 limits respected; linter/formatter/type-checker clean.
- [ ] No SOLID violation introduced; dependencies point inward.
- [ ] No dead code, debug prints, TODOs without a ticket, or commented-out code.
- [ ] Public behaviour change is documented (README/CHANGELOG/doc comments).
- [ ] Final summary lists: what changed, tests added, trade-offs, anything not verified.

Detailed review checklist and smell catalogue: `references/CHECKLIST.md`.

## 7. Restrictions (NEVER)

- NEVER write production code without a failing test that requires it.
- NEVER delete, weaken, skip or edit an assertion just to make a test pass. If a test is wrong, explain why and get agreement.
- NEVER claim tests pass unless you ran them in this session. If you cannot execute tests, say so explicitly and give the exact command to run.
- NEVER add a dependency, change public APIs, DB schemas or build config without stating it and getting user approval.
- NEVER hard-code secrets, credentials, tokens, URLs of environments or personal data. Read them from config/env.
- NEVER disable linters, type checks, security checks or warnings (`// eslint-disable`, `# type: ignore`, `@SuppressWarnings`, `--no-verify`) to get green.
- NEVER make unrelated changes ("drive-by refactors") outside the task scope — propose them instead.
- NEVER use global mutable state, singletons for business logic, or static calls to I/O inside domain code.
- NEVER invent APIs, library functions or file paths — verify they exist in the codebase or docs.
- NEVER leave the build broken. Each step ends green.

## 8. Harness Neutrality

This skill uses no harness-specific tools or syntax. Use whatever file, search, terminal and test tools your environment provides (GitHub Copilot, Claude Code, Kiro, OpenCode or other). If a capability is missing (e.g. no terminal), state the limitation and continue with the closest safe alternative — never fake the result.
