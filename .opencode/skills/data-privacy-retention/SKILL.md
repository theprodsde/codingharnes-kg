---
name: data-privacy-retention
description: Minimize and protect personal or sensitive data when changing collection, storage, telemetry, exports, third-party sharing, retention, deletion, or restore behavior.
---

# Data Privacy and Retention

Use when data collection, classification, visibility, export, external processing, retention, deletion, residency, or backup behavior changes. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions; implementation uses `../tdd-workflow/SKILL.md`, while assessments remain read-only.

## Before implementation

- Identify data categories, approved purpose, owner, permission boundaries, applicable project policy, retention periods, and external processors. Map affected flows through storage, caches, queues, logs, exports, replicas, and backups.
- Ask the authorized privacy/data owner for unspecified legal, residency, consent, retention, or legal-hold decisions. Do not invent policy or assert legal compliance.

## Implementation checks

1. Collect and return only the data required for the approved purpose. Use explicit field allowlists for APIs, exports, and telemetry; do not serialize complete entities by convenience.
2. Enforce actor/object/tenant permissions for reads, exports, correction, and deletion. Verify derived datasets, caches, jobs, and external destinations preserve those boundaries.
3. Use approved encryption and key management for relevant transport/storage paths. Restrict access by role and purpose; audit sensitive operations without reproducing sensitive records in the audit trail.
4. Implement the approved retention schedule, deletion scope, and legal-hold exceptions with observable, retry-safe processing. Distinguish logical deletion from physical removal and anonymization from reversible pseudonymization.
5. Include search indexes, caches, queued work, replicas, exports, third-party copies, and backup expiry in the policy-defined lifecycle. Document limitations for immutable backups and ensure authorized restore does not silently reintroduce data that must remain deleted.
6. Use synthetic or approved anonymized fixtures. Preserve policy constraints when adding telemetry, analytics, support diagnostics, or test datasets; verify approved destination, purpose, and residency before new sharing.

## Restrictions

- Do not collect extra personal data, extend retention, change residency, add processors, or broaden access without explicit policy-owner approval of that scope.
- Do not copy real user data into tests, log raw sensitive records, expose bulk exports, or upload private datasets to external services without authorization.
- Do not treat hashing an identifier as proof of anonymity or a privacy checklist as certification of legal compliance.
- Do not run live deletion, export, backup purge, or restore without explicit authorization, bounded scope, policy checks, and recovery/verification appropriate to the operation.
- Do not bypass legal holds, audit controls, encryption, or deletion verification to simplify implementation; escalate contradictory requirements to the authorized owner.

## Verification gates

- Test affected allow/deny access, minimization, redaction, retention boundaries, legal holds, duplicate/interrupted deletion, and cross-tenant behavior with synthetic data as applicable.
- Exercise actual affected data paths, including derived stores and external adapters in approved test environments; a deletion helper test does not prove end-to-end erasure.
- Rehearse required deletion/restore reconciliation and verify the documented lifecycle scope. State which backup or external-processor behavior was not verified.
- Missing policy decisions or required lifecycle evidence blocks the affected readiness claim. Report checks and unresolved obligations to the data owner; use `../database-production/SKILL.md` and `../observability-recovery/SKILL.md` for related operations.
