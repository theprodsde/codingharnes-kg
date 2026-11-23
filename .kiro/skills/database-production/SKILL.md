---
name: database-production
description: Design and review production database schemas, queries, migrations, reliability, security, and operational readiness.
---

# Database Production

Use when application changes introduce or modify persistent data, queries, migrations, backups, or database operations. Inspect the actual database engine, workload, data sensitivity, and deployment topology; verify vendor-specific behavior instead of assuming it.

Follow `../solid-tdd-craft/SKILL.md` and its Restrictions for implementation; use `../tdd-workflow/SKILL.md` for changed behavior. Keep review requests read-only. Include ORM-generated SQL and migrations in the scope.

Use `../data-privacy-retention/SKILL.md` for sensitive data, retention, deletion, and restore reconciliation; `../authentication-authorization/SKILL.md` for tenant/access policy; and `../configuration-secrets/SKILL.md` for database credentials. Apply `../observability-recovery/SKILL.md` when changing operational signals or recovery.

## Development and schema

1. Model invariants in the database where appropriate with constraints, keys, and explicit nullability. Choose types and precision for the domain; define time-zone and encoding conventions.
2. Give application components clear data ownership. Avoid cross-service shared writes. Treat schema and query changes as compatibility changes for every deployed application version and consumer.
3. Use parameterized queries and least-privilege identities. Validate authorization before data access; never interpolate untrusted input into SQL or expose credentials, personal data, or query parameters in logs.
4. Index measured access paths, not every column. Review query plans and realistic data volume; consider write amplification, storage, cardinality, and index maintenance. Prevent unbounded scans, N+1 access, and unbounded result sets.
5. Bound transactions and connection-pool use. Choose isolation based on required invariants; handle deadlocks and transient failures with bounded retries, and make retried writes idempotent where possible.
6. Define consistency and cache behavior explicitly. Plan for stale reads, invalidation, replication lag, and pagination stability where they affect user-visible correctness.
7. Test races rather than relying on application-side read-then-write checks. Use constraints, atomic updates, or explicit concurrency control for uniqueness, balances, inventory, and other affected invariants. Include tenant boundaries and cascade/delete behavior where relevant.
8. Retry at the engine/driver's documented transaction boundary, including all reads and decisions when the whole transaction must be repeated. Do not retry only the last statement of an aborted transaction. Distinguish a confirmed rollback from a lost commit acknowledgment; reconcile an unknown commit outcome before replaying non-idempotent writes, and keep non-repeatable external side effects outside retried callbacks.

## Production changes and operations

1. Prefer backward-compatible expand/migrate/contract changes when old and new application versions can overlap. Deploy additive schema first, backfill safely, switch reads/writes, then remove obsolete schema only after consumers have moved.
2. Estimate locks, table rewrites, disk growth, and migration duration on representative data. Batch and throttle large backfills; make progress observable and interruption/retry safe.
3. Define rollback and recovery before rollout. Some data transformations are irreversible; use a forward-fix or restore plan rather than promising that reverting application code reverses data changes.
4. Verify automated backups and point-in-time recovery where supported. Test restoration and document recovery point and recovery time objectives; replicas alone are not backups.
5. Monitor availability, connection saturation, query latency, errors, lock waits, storage, replication lag, and backup/restore health. Alert on symptoms tied to service impact and assign operational ownership.
6. Apply retention, deletion, encryption, audit, and residency requirements to stored data, replicas, logs, exports, and backups. Restrict production access and use safe, anonymized test data.
7. Preserve migration history according to the repository's migration tool and policy. Do not rewrite an already-applied migration to fix deployed state; add a forward migration. Verify data-conversion and backfill postconditions, including row reconciliation and affected invariants, rather than treating runner exit status as proof of correctness.

## Performance and capacity checks (when affected)

- Follow the performance evidence protocol in `../production-readiness/SKILL.md` using the supported engine/version. Exercise representative data volume, distribution/skew, parameter values, tenant sizes, hot keys, and read/write concurrency; tiny uniform fixtures cannot establish production query performance.
- Inspect generated SQL, query counts, execution plans, estimated versus actual row counts where safely available, rows scanned, sorts/spills, I/O, and lock waits. Check optimizer statistics and engine-specific maintenance needs before adding indexes or hints. Compare latency distributions and write cost, not just one fast query.
- Assess composite-index column order and selectivity, filter/sort access paths, and expensive deep-offset pagination. Use stable ordering with a unique tie-breaker; consider keyset pagination only where the API's navigation and consistency requirements permit it. Do not add indexes or change pagination semantics without evidence and approved scope.
- Budget the sum of database connections across application replicas, workers, rollout overlap, and administrative/recovery needs. Bound pool acquisition, statements, and lock waits using approved engine/driver settings; verify saturation behavior instead of merely raising limits.
- Account for storage and log growth, index build space, maintenance/compaction or vacuum where applicable, replication lag, and backup/backfill load. Measure interference with normal traffic in an authorized isolated environment; partitioning, sharding, and replicas require a demonstrated need and an explicit consistency/operations plan.

## Verification evidence

- Test affected constraints and queries on an isolated instance of the supported engine/version; an in-memory substitute or mocked ORM does not prove locking, isolation, or SQL compatibility.
- Rehearse migrations from the previous supported schema, including existing rows, defaults, nullability, constraints, and old/new application compatibility. Also check a fresh install when the migration path affects it.
- Exercise relevant transaction rollback, concurrent update, retry, and interrupted-backfill behavior. Verify migration-runner coordination prevents concurrent execution where needed.
- For changed retry/recovery paths, exercise an aborted transaction and an unknown commit outcome using supported test controls on an isolated database. Verify final durable state; do not infer rollback solely from a client exception.
- Capture query plans and measured latency against representative synthetic or approved anonymized data when query performance changes. Check pagination/result correctness as well as speed.
- Distinguish a planned restore or failover procedure from a successfully rehearsed recovery. Record verified recovery objectives and blockers; do not run against live data to obtain evidence without authorization.

## Restrictions

- Do not run production migrations, destructive queries, exports, or restore procedures without explicit authorization and bounded scope.
- Verify the engine's plan-tool semantics before use: execution-enabled commands such as `EXPLAIN ANALYZE` can execute the statement, including writes and side effects. Use isolated fixtures and approved scope; a transaction rollback does not guarantee reversal of every external or engine-specific effect.
- Do not weaken constraints, broaden access, copy live data into fixtures, or bypass retention/legal-hold policy to make tests or migrations pass.
- Do not treat soft deletion, replication, or a scheduled backup as proof of erasure or recovery. Report engine-specific assumptions and any load, lifecycle, recovery, or failover behavior not verified.
