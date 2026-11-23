---
name: microservices-architecture
description: Design or assess microservice boundaries, service communication, data ownership, resilience, and independent operations.
---

# Microservices Architecture

Use when a system is already distributed or a proposal would split a deployable into services. Do not recommend microservices by default: compare the operational and organizational cost with a modular monolith using `../monolithic-architecture/SKILL.md`.

For implementation, follow `../solid-tdd-craft/SKILL.md` and its Restrictions; architecture review stays read-only. Use `../backend-development/SKILL.md` for service and worker implementation and `../database-production/SKILL.md` for persistent-data changes.

## Design checks

1. Set service boundaries around cohesive business capabilities, ownership, and change patterns—not technical layers or tables. Each service needs a clear reason to change and an accountable owner.
2. Require independent deployment or scaling benefits to justify a service boundary. Avoid shared databases, hidden cross-service transactions, and synchronous call chains that create a distributed monolith.
3. Give each service ownership of its data. Expose stable contracts; evolve APIs and event schemas compatibly, with explicit deprecation and consumer migration plans.
4. Choose synchronous calls when callers need an immediate result; use asynchronous messaging for decoupling or workflows that can be eventually consistent. Document ordering, duplication, delivery, and replay behavior.
5. Set timeouts and deadlines on remote calls. Use bounded retries with backoff and jitter only for transient failures; make retried operations idempotent. Apply circuit breaking and bulkheads where they protect the system.
6. Design cross-service workflows for partial failure. Prefer local transactions and explicit compensating actions over pretending a global transaction exists. Make event publication and consumption resilient to crashes and duplicate delivery.
7. Propagate trace context and correlation IDs. Monitor per-service latency, errors, saturation, dependency failures, and queue lag; keep sensitive data out of telemetry.
8. Authenticate service identities, authorize each operation, and constrain network access. A trusted internal network is not an authorization boundary.
9. Specify event versioning, producer/consumer rollout order, retention, dead-letter handling, and replay ownership. Use the established outbox/inbox or equivalent durability pattern when database writes and messaging must remain consistent; do not claim end-to-end exactly-once behavior without proving its scope.
10. Propagate request deadlines and bound total retry amplification across layers. Define overload/backpressure and dependency degradation behavior; test whether one failing service can exhaust shared resources.

## Verification

- Test service behavior and contract compatibility; test failure paths such as timeouts, duplicate messages, unavailable dependencies, and retries.
- Validate deployability and operability independently, including health checks, configuration, capacity, alerts, and recovery procedures.
- State consistency, availability, and data ownership tradeoffs explicitly. Avoid adding a broker, service mesh, or orchestration layer without a concrete need.
- Check mixed producer/consumer versions and durable state transitions under relevant crash windows, not just mocked call success. Rehearse required recovery with isolated fixtures; capture evidence and unresolved operating assumptions.
