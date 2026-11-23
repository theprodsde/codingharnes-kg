---
name: observability-recovery
description: Define and verify safe logs, metrics, traces, alerts, incident runbooks, rollout signals, and recovery behavior against project service objectives.
---

# Observability and Incident Recovery

Use when runtime failure behavior, telemetry, alerting, health signals, incident procedures, or recovery paths change. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions; assessments stay read-only and do not authorize incident actions.

## Before implementation

- Identify service owners, critical user outcomes, existing telemetry stack, service objectives, alert routing, recovery objectives, and approved runbooks.
- Trace affected failure modes and dependencies. Use agreed budgets and normal workload patterns; ask the owner when a release/recovery threshold is missing rather than inventing one.

## Implementation checks

1. Emit actionable structured logs, meaningful latency/error/saturation metrics, and trace context using established helpers. Distinguish retries, dependency failures, and user-visible failure without duplicating noisy events.
2. Keep metrics label sets bounded and telemetry volume proportional. Exclude credentials and personal data; untrusted correlation IDs or payload fields are not safe to log without validation/redaction.
3. Link critical alerts to user/service impact, a responsible owner, escalation, and a concrete runbook. Set agreed thresholds and observation windows; avoid an alert with no actionable decision.
4. Keep liveness, readiness, dependency checks, and graceful shutdown semantically distinct. Ensure degraded dependencies do not trigger cascading restart or retry storms.
5. Define disable, rollback, forward-fix, replay, restore, or failover steps appropriate to durable state and external side effects. Include prerequisites, permission scope, safe stop criteria, data-loss limits, and how recovery success is verified.
6. Record recovery objectives and measured rehearsals where required. Replica availability or a scheduled backup is not evidence of a successful restore; use `../database-production/SKILL.md` for database recovery.

## Restrictions

- Do not suppress actionable errors, mark failed work successful, disable alerts, erase incident evidence, or waive recovery gates to claim availability.
- Do not generate unbounded/high-cardinality telemetry, log raw payloads or identifiers by default, or send private telemetry to a new external destination without authorization.
- Do not run load, chaos, failover, restore, traffic-switching, or destructive recovery experiments against shared or live systems without explicit scope and authorization.
- Do not restart services, replay jobs, mute paging, or change live dashboards/alerts merely because an assessment suggests it. Use approved incident ownership and change procedures.

## Verification gates

- Test changed failure signals, redaction, health, and draining behavior locally with synthetic fixtures. Check the real instrumentation path, not only mocked logger invocations.
- Rehearse relevant alert routing, runbook actions, and recovery verification in an authorized non-production environment when required by project risk/gates.
- Compare measured service/recovery behavior with agreed objectives. Distinguish a documented plan, local simulation, and successful operational rehearsal.
- Required missing alert ownership, recovery decisions, or evidence blocks operational readiness. Report exact checks and unresolved limitations; use `../deployment/SKILL.md` for rollout gates.
