---
name: monolithic-architecture
description: Design and evolve a modular monolithic application with clear boundaries, reliable deployment, and deliberate extraction criteria.
---

# Monolithic Architecture

Use when designing a single deployable application or deciding whether to split one. A monolith can be modular and horizontally scalable; choose it when its simpler transactions, local calls, and operations fit the team's needs.

For implementation, follow `../solid-tdd-craft/SKILL.md` and its Restrictions; keep assessments read-only. Use frontend, backend, and database companions for the layers actually changed.

## Design checks

1. Divide the codebase into cohesive modules aligned with business capabilities. Give each module a clear public interface and keep implementation details private.
2. Enforce dependency direction and ownership. Prevent arbitrary cross-module access to internals and shared mutable state; use explicit interfaces for allowed collaboration.
3. Keep domain rules out of transport, UI, and persistence concerns. Use the simplest in-process call that preserves boundaries; avoid adding distributed infrastructure to simulate service separation.
4. Make data ownership explicit even when modules share a database. Centralize writes behind the owning module's API and avoid coupling modules to each other's schema details.
5. Use transactions to protect local invariants. Keep transaction scope bounded, and make external side effects resilient to retries and partial failure.
6. Keep deployment reproducible and configuration externalized. If the application is horizontally scaled, avoid process-local state as the source of truth and verify session, cache, and background-job behavior across instances.
7. Test module behavior and important integration boundaries. Avoid requiring a full production-like environment for every fast feedback test.
8. Keep scheduled jobs and external side effects safe under concurrent instances and restarts. A single deployable does not imply single execution or make external operations part of its database transaction.

## Verification

- Use existing dependency/import checks to enforce module boundaries when available; inspect affected callers and test public module behavior rather than private internals.
- Verify the real composition root wires new code into routes, jobs, or UI. Exercise changed persistence and external boundaries with focused integration tests.
- For scaling or extraction claims, provide workload measurements and operating costs; distinguish assumptions from evidence. Validate relevant multi-instance, concurrency, and recovery behavior before recommending a new deployment topology.

## When to split

Consider extraction only when evidence shows a capability needs independent scaling, release cadence, security isolation, ownership, or fault containment that the modular monolith cannot meet economically. Before extraction, define the contract, data ownership transition, migration and rollback plan, observability, and operational owner. Preserve module boundaries so a future extraction remains possible without paying distributed-systems costs prematurely.
