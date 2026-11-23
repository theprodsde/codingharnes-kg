---
name: api-contracts
description: Preserve API and event compatibility when changing endpoints, payloads, response schemas, pagination, errors, generated clients, or consumer contracts.
---

# API Contracts and Compatibility

Use for public or internal HTTP/RPC interfaces, webhooks, and event schemas. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions; use `../tdd-workflow/SKILL.md` for behavioral changes. Keep contract reviews read-only.

## Before implementation

- Find the canonical contract, deployed versions, consumers, generated clients, and compatibility policy. Inspect existing routing, serialization, error, and versioning conventions.
- Identify the required behavior and supported old/new producer-consumer combinations. If consumer ownership or a breaking-change decision is unknown, ask before changing the contract.

## Implementation checks

1. Validate request and response shape at the actual transport boundary. Keep types, runtime validation, documentation, and generated artifacts consistent using the project's existing generator.
2. Assess required fields, nullability, defaults, enum values, status/error codes, pagination, ordering, and semantic meaning. Additive fields or enum values can still break strict clients; check actual consumers rather than assuming compatibility.
3. Preserve authorization and data visibility when evolving responses. Avoid exposing persistence entities directly; return only contract-approved fields.
4. Define retry/idempotency and cancellation behavior where callers can repeat operations. For events, define versioning, delivery, ordering, replay, and rollout sequence.
5. Use the established deprecation process for approved breaking changes: consumer migration, overlap period, version routing, monitoring, and recovery. Update affected callers together where coordinated rollout is intended.
6. Define wire representations for precision-sensitive numbers, identifiers, timestamps/time zones, and absent versus null values. Verify round trips through actual consumers, especially across languages; matching server and client type names do not prove matching serialization semantics.

## Restrictions

- Do not rename/remove fields, strengthen input requirements, change response semantics, or alter event meaning without explicit approval of the breaking scope and migration plan.
- Do not silently accept invalid input, return success for failed operations, or add undocumented fallback formats.
- Do not hand-edit generated clients when the repository requires regeneration, or weaken schema/contract checks to hide incompatibility.
- Do not assume internal APIs have no consumers or that a version-number change alone makes a rollout safe.

## Verification gates

- Run focused transport/serialization tests for valid, invalid, and error cases. Confirm actual endpoints emit the documented shape, not merely that DTO types compile.
- Run existing contract/schema checks and affected consumer tests for supported version combinations. Exercise changed pagination, optional fields, enum handling, and event replay where relevant.
- Verify generated artifacts are reproducible and application callers use the changed contract. Missing required consumer evidence blocks a compatibility claim.
- Report exact checks, compatibility decisions, approved breaking changes, and unresolved consumers. Use `../backend-development/SKILL.md` for implementation and `../production-readiness/SKILL.md` for release assessment.
