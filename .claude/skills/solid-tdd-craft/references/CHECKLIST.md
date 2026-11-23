# Review Checklist & Smell Catalogue

Load this when reviewing code or before declaring a task done.

## Pre-merge checklist
1. Would the focused behavior test detect the regression it claims to cover? Use mutation testing only when the project supports it; not every line needs its own assertion.
2. Are affected classes and modules cohesive, with clear responsibilities?
3. Can relevant infrastructure boundaries (DB, HTTP, clock) be controlled in tests without rewriting domain rules?
4. Is repeated type-based branching a real extension problem, or is a simple conditional clearer for this closed set?
5. Are all inputs validated at the boundary and all errors specific and surfaced?
6. Would a new team member understand every name without reading the body?
7. Is new code justified by acceptance criteria or required operational behavior, and is it wired into the real application? Flag unjustified changes; remove only within an authorized implementation scope, never during read-only review.
8. Are affected public contracts, types, callers, and failure paths consistent, with no weakened checks or success-shaped failure defaults?
9. Does each acceptance criterion have evidence through its intended entry point, including relevant registration and flag states? Are mocks hiding missing integration or placeholder behavior?
10. Where writes can be repeated, do timeout, disconnect, cancellation, and lost acknowledgments preserve the intended durable outcome without duplicate effects? Is user/tenant cache state isolated across identity changes?

## Production readiness (when the change affects production)
- Required CI checks, tests, static analysis, and security scans pass; exceptions are explicit.
- API, data, and configuration changes remain compatible with the intended rollout order.
- Database migrations are safe across mixed application versions and have a recovery strategy.
- Secrets and sensitive data are not logged, committed, or exposed through errors.
- Operational changes have appropriate health signals, alerting, and a rollback or disable path.
- User-facing behavior, configuration, and operator documentation are updated where needed.
- Relevant UI accessibility, integrated API authorization, database constraints, and concurrency/retry behavior are verified with the appropriate domain skills.
- Readiness evidence distinguishes passing, blocked, not verified, and not applicable checks; missing required evidence is not approval.
- Evidence applies to the current source/artifact and configuration, not an earlier passing build. Environment-specific builds are identified and checked separately.
- Performance-sensitive changes have comparable baseline/current measurements, representative workloads, agreed budgets, and errors/resource saturation alongside latency and throughput; use `../../production-readiness/SKILL.md`. Load tests have bounded, authorized targets. Check applicable browser field/lab distinctions, cache behavior, aggregate pool capacity, and database plan-tool execution risks.

## Specialized gates (only for affected areas)

- API/event changes: supported consumers and mixed versions preserve the approved contract; use `../../api-contracts/SKILL.md`.
- Identity/access changes: real entry points enforce the approved allow/deny and tenant policy; use `../../authentication-authorization/SKILL.md`.
- Dependency/build-source changes: lockfiles, trust controls, required advisory/license/provenance checks, and runtime compatibility remain valid; use `../../dependency-supply-chain/SKILL.md`.
- Configuration/secret changes: invalid inputs fail safely, outputs are redacted, and relevant startup/rotation behavior is verified; use `../../configuration-secrets/SKILL.md`.
- Operational changes: signals have bounded volume, alerts have owners, and required recovery evidence meets agreed objectives; use `../../observability-recovery/SKILL.md`.
- Sensitive-data changes: minimization, access, retention/deletion, sharing, and restore reconciliation follow approved policy; use `../../data-privacy-retention/SKILL.md`.
- Unspecified policy, missing required evidence, or failed gates are reported with an owner/follow-up. No skill grants live access, certifies compliance, or permits an agent-created exception.

## Smell → Refactoring
| Smell | Refactoring |
|---|---|
| Long function | Extract Function, Replace Temp with Query |
| Long parameter list | Introduce Parameter Object, Preserve Whole Object |
| God class / large class | Extract Class, split by responsibility |
| Repeated type branching with independent variants | Consider Polymorphism / Strategy; keep simple closed-set conditionals |
| Feature envy | Move Function to the data it uses |
| Primitive obsession | Introduce Value Object |
| Shotgun surgery | Move related behaviour into one module |
| Duplicated code (×3) | Extract Function / Template Method |
| Deep nesting | Guard Clauses, Decompose Conditional |
| Flag argument | Split into two explicit functions |
| Hidden dependency (`new` / static I/O in domain) | Constructor injection behind an interface |
| Train wreck `a.b().c().d()` | Hide Delegate, Tell-Don't-Ask |

## Test smells
| Smell | Fix |
|---|---|
| Multiple behaviours per test | Split; one reason to fail |
| Test depends on order / shared state | Fresh fixture per test |
| Sleeps / real time | Inject a clock |
| Over-mocking internals | Test through the public API; mock only ports |
| Assertion-free test | Assert observable outcome |
| Testing private methods | Test via public behaviour or extract a class |
