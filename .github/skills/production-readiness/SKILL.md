---
name: production-readiness
description: Assess implementation and release readiness for production changes, including verification, compatibility, security, operations, and recovery.
---

# Production Readiness

Use this for changes intended to ship, especially changes to APIs, data, configuration, infrastructure, or user-visible behavior. Inspect the repository's actual deployment and test conventions; do not invent release requirements or declare readiness without evidence.

For implementation, follow `../solid-tdd-craft/SKILL.md` and its Restrictions. A readiness assessment remains read-only unless changes are explicitly requested.

## Readiness review

1. Establish the change's production impact, supported versions, rollout shape, and acceptance criteria.
2. Find the canonical build, test, lint, type-check, and CI checks. Run the smallest relevant checks, then required release gates; report anything unavailable.
3. Check compatibility across clients, services, configuration, and mixed-version deployments.
4. For data changes, inspect migration ordering, backfills, locking or downtime risk, and recovery. Prefer expand/migrate/contract when mixed versions require it; use `../database-production/SKILL.md` for a detailed database review.
5. Check security boundaries, secrets handling, permissions, and sensitive-data logging; use `../security-review/SKILL.md` for a focused assessment.
6. Check operational behavior: health signals, actionable errors, observability, capacity assumptions, and a rollback, disable, or recovery path appropriate to the change.
7. Update user or operator documentation, configuration examples, and runbooks when behavior or operations change; use `../deployment/SKILL.md` for rollout planning.
8. Check that the changed behavior is reachable through the actual UI, API, job, or consumer. Use frontend, backend, and database companions for affected layers; validate the critical integrated path, not only isolated helpers.
9. Assess relevant concurrency, partial failure, retry, capacity, and recovery behavior against agreed budgets and service objectives. Document assumptions, measured results, and operational ownership; do not add arbitrary performance or availability targets.
10. Apply specialized gates only where affected: `../api-contracts/SKILL.md`, `../authentication-authorization/SKILL.md`, `../dependency-supply-chain/SKILL.md`, `../configuration-secrets/SKILL.md`, `../observability-recovery/SKILL.md`, and `../data-privacy-retention/SKILL.md`. Record missing policy decisions and required evidence as blockers, not automatic exceptions.

## Performance evidence protocol (when affected)

Use this for performance investigations, optimizations, or changes with a material capacity risk. It does not require load testing for every edit or authorize testing shared systems.

1. **Criterion:** identify the user journey or operation, relevant latency/throughput/resource budgets, and required workload. Use project objectives; if a required acceptance budget is missing, ask its owner. Exploratory measurements may establish a baseline but cannot establish compliance with an undefined target.
2. **Baseline:** record the source/artifact, runtime and dependency versions, configuration/flags, hardware/resource limits, topology, and measurement tools. Compare before/after under equivalent conditions and report any unavoidable differences.
3. **Workload:** specify synthetic or approved anonymized dataset size/distribution, operation mix, payloads, concurrency/arrival rate, warm-up, duration, cache state, and dependency behavior. Include cold start, bursts, sustained load, or recovery after overload only where relevant to the change.
4. **Safety:** use an explicitly authorized target with bounded rate/concurrency/duration, resource limits, stop conditions, and cleanup. Localhost can still point to shared dependencies; verify the destination. Never run load experiments against shared/live services merely to complete a checklist.
5. **Measurement:** use existing tooling, repeated comparable runs, and sufficient samples for the reported percentiles. Capture relevant p50/p95/p99 latency, throughput, errors/timeouts, queueing, CPU/memory/I/O, and layer-specific measures. Record offered versus completed work and whether the load generator became the bottleneck; do not drop failures or hide stalls by reporting only successful requests.
6. **Decision:** compare against both baseline and agreed budgets; report variability, regressions, tradeoffs, and unverified environments. Preserve correctness, access controls, and durability. A microbenchmark, mocked dependency, single run, or development build is limited evidence, not an end-to-end production claim.

Use `../frontend-development/SKILL.md`, `../backend-development/SKILL.md`, and `../database-production/SKILL.md` for the affected layer's measurements. Keep results in the existing report or benchmark workflow. Require missing performance evidence only when it is an applicable acceptance or release gate; do not introduce new benchmark infrastructure without approved scope.

## Restrictions and readiness decision

- Separate **ready**, **blocked**, and **not verified** items, with evidence and named follow-up checks.
- Avoid adding infrastructure or release ceremony that the change does not need.
- Never bypass CI, tests, security checks, or approvals to make a release appear ready.
- Do not commit, push, publish, deploy, migrate production data, or change live configuration without explicit user authorization.
- A required gate that fails or lacks evidence blocks a readiness conclusion. Mark an item not applicable only with a reason; do not relabel missing evidence as passed. Any accepted exception needs the authorized owner and residual risk, not an agent-created waiver.
- Separate implementation verification, release approval, and post-deployment verification. Local passing tests do not prove a deployment, backup, failover, or production service objective has been verified.
- Do not change permission, privacy, trust, or recovery policy to satisfy a release gate; obtain the authorized owner's decision and preserve unrelated safeguards.

For each applicable gate, record the criterion, evidence or command/result, status, and owner/follow-up for outstanding work. Keep this in the requested report or existing project workflow; do not create extra tracking files by default.

Tie evidence to the reviewed revision or source state, tested artifact, configuration/flag state, and environment where relevant. Re-run affected checks after subsequent changes; earlier passing results do not verify a later implementation. For source snapshots without version control, identify the reviewed scope and do not invent a commit ID.

Use `../solid-tdd-craft/references/CHECKLIST.md` for the shared pre-merge checklist.
