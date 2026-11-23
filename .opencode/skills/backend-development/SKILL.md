---
name: backend-development
description: Build and review production backend APIs, server-side business logic, background jobs, and integrations with authorization, contracts, reliability, observability, and tests.
---

# Backend Development

Use for HTTP or RPC endpoints, server-side application services, scheduled work, message consumers, and external integrations. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions for implementation; use `../tdd-workflow/SKILL.md` for behavioral changes. For review requests, remain read-only.

## Before implementation

- Inspect the actual framework, runtime versions, transport contracts, authentication middleware, persistence layer, job system, and canonical test commands.
- Trace the affected entry point through business rules, persistence, and external side effects. Identify callers, data ownership, trust boundaries, and success and failure acceptance criteria.
- Reuse existing routing, validation, error, transaction, logging, and dependency-injection conventions. Do not impose a new architecture or package for a routine feature.

Load `../api-contracts/SKILL.md` for API/event changes, `../authentication-authorization/SKILL.md` for identity or access changes, `../configuration-secrets/SKILL.md` for configuration/credentials, `../observability-recovery/SKILL.md` for runtime signals or recovery, and `../data-privacy-retention/SKILL.md` for sensitive-data lifecycle changes. Use `../dependency-supply-chain/SKILL.md` before changing packages or build sources.

## Implementation checks

1. **Contracts:** validate payload shape, size, types, ranges, and unsupported fields at the boundary. Use the project's response schemas, status codes, and safe error format. Preserve compatibility for existing callers; document intentional breaking changes and their migration plan.
2. **Access control:** distinguish authentication from authorization. Enforce operation-, object-, and tenant-level access on the server, including workers and alternate entry points. Do not trust client-provided ownership, roles, prices, or internal-network location. Test both allowed and denied access.
3. **Business rules:** keep domain decisions out of transport adapters. Enforce invariants consistently across entry points; do not duplicate validation rules inconsistently or rely on a frontend check. Handle money, precision, timestamps, and time zones according to domain conventions.
4. **Persistence:** use parameterized access, bounded queries, explicit projections, and stable pagination. Protect concurrent updates with appropriate constraints, transactions, or version checks. Follow `../database-production/SKILL.md`; an ORM does not eliminate migration or query risks.
5. **Side effects:** define repeat-submission and duplicate-delivery behavior. For operations needing idempotency, persist the operation identity and outcome safely under concurrent retries; define key scope and retention. Do not assume a database transaction also atomically commits an external call or message; use the established outbox or reconciliation pattern when required.
6. **Dependency calls:** set deadlines, cancellation, connection and response-size limits. Retry only transient failures where repeat execution is safe, with bounded attempts and backoff/jitter inside the total deadline. Validate external responses; do not hide failures as empty success results. Constrain user-supplied outbound destinations using approved URL/network controls.
7. **Jobs and consumers:** acknowledge only after durable processing. Define attempts, deduplication, concurrency, ordering, poison-message handling, recovery, and safe replay. Make failures observable and assign an operator path rather than silently dropping work.
8. **Resource safety:** bound request bodies, uploads, pagination, concurrency, and expensive work according to repository limits. Use existing rate-limit or quota controls where needed. Avoid blocking async execution or storing durable state only in process memory when multiple instances run.
9. **Operations:** validate required configuration at startup, retrieve secrets through approved mechanisms, and use least-privilege identities. Emit actionable structured errors, latency/error metrics, and trace context without credentials or personal data. Drain in-flight requests and jobs during shutdown; distinguish readiness from process liveness.
10. **Ambiguous outcomes:** a timeout or disconnect can occur after a write or external side effect succeeds. Use the established operation-status, idempotency, or reconciliation path before repeating it. Bind idempotency keys to the authorized actor/tenant and operation payload; reject conflicting reuse and do not expose another actor's saved result. Define in-progress and expired-key behavior where applicable.

## Performance and capacity checks (when affected)

- Follow the performance evidence protocol in `../production-readiness/SKILL.md`. Measure end-to-end latency distributions, including relevant p95/p99 values, alongside throughput, errors, timeouts, and resource saturation. A faster average or higher throughput with more failed requests is not proof of improvement.
- Profile the affected path before optimizing: CPU, allocations/memory growth, garbage collection where applicable, event-loop/thread contention, serialization, query count, and dependency latency. Separate queue wait from execution time; preserve cancellation and release resources on failure.
- Bound pending queues as well as active concurrency. Define admission control, backpressure, load shedding, and recovery with the existing framework and agreed limits. Verify bursts, slow dependencies, and sustained load where relevant; retries must not multiply overload. These requirements also apply to monoliths and single-service workers.
- For changed caches, define key scope, size/eviction, freshness, invalidation, and behavior on outage. Prevent hot-key or simultaneous-expiry stampedes using established bounded mechanisms. Test cold and warm caches and multiple instances; do not trade authorization or consistency for speed.
- Budget connection/thread pools and worker concurrency across replicas, autoscaling, and overlapping deployments against downstream capacity. Scaling application instances must not exhaust the database or an external provider. Verify headroom and backlog recovery against agreed objectives rather than increasing pool sizes speculatively.

## Restrictions

- Do not bypass boundary validation or server authorization, expose undocumented data, or acknowledge failed/non-durable work as successful.
- Do not change API semantics, permission policy, dependency trust, or data retention incidentally; apply the relevant specialized gates and approved scope.
- Do not introduce unbounded work, retries, or hidden fallback credentials. A missing decision for limits or sensitive behavior must be surfaced, not guessed.

## Verification and completion

- Start with a failing behavioral test. Cover the normal path plus relevant invalid input, access denial, missing resources, conflicts, dependency failures, and duplicate/concurrent execution.
- Use integration tests for actual routing, middleware, serialization, persistence constraints, or queue semantics affected by the change. Mocks alone cannot prove these boundaries work.
- Verify that new handlers and jobs are registered, reachable through the intended entry point, and have observable effects. Check API/event compatibility with affected consumers.
- Where retryable writes change, test concurrent duplicate requests, conflicting key reuse, and a committed operation whose response is lost. Verify durable state and external-effect count, not only the returned status or mocked call arguments.
- Run relevant tests and repository-required lint, type-check, and build checks. Measure changed query or throughput behavior against existing budgets when performance is an acceptance criterion.
- Report exact verification results and unavailable checks; update API/event documentation and configuration or runbooks when behavior changes. Use `../production-readiness/SKILL.md` before declaring a release ready.
