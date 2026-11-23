---
name: deployment
description: Plan and assess safe application deployments, release configuration, health checks, rollout, monitoring, and recovery.
---

# Deployment

Use for deployment pipelines, release plans, runtime configuration, and production rollout changes. First inspect the application's real hosting platform, CI/CD process, and operating constraints; keep recommendations proportional to the system.

Follow `../solid-tdd-craft/SKILL.md` and its Restrictions for implementation. A deployment assessment does not authorize a rollout or live-system access.

Use `../dependency-supply-chain/SKILL.md` for artifact/build trust, `../configuration-secrets/SKILL.md` for runtime settings and credentials, and `../observability-recovery/SKILL.md` for alerting and operational recovery. Apply their relevant restrictions and evidence gates before claiming readiness.

## Deployment checks

1. Prefer building a reproducible, identifiable artifact once and promoting that artifact across environments. If the existing platform requires environment-specific builds, such as a frontend with build-time public configuration, identify and verify each target artifact separately; do not claim a different build is the previously tested artifact. Pin or verify dependencies and permissions according to the repository's supply-chain controls.
2. Keep runtime environment-specific configuration outside the artifact. Document unavoidable public build-time configuration and its rebuild requirements; never embed secrets in client artifacts. Retrieve runtime secrets from the approved secret manager; never log or commit them. Grant deployment and runtime identities only required permissions.
3. Confirm configuration and schema compatibility with currently running versions. Plan data migrations separately where needed; use `../database-production/SKILL.md` for database rollout risks.
4. Choose a rollout strategy suited to risk and platform (for example, rolling, canary, or blue-green). Specify gates, health checks, and how traffic is advanced or stopped.
5. Verify startup, readiness, graceful shutdown, resource limits, and health signals. Ensure monitoring can distinguish a healthy process from a healthy user-facing service.
6. Define rollback or forward-recovery steps, including data and configuration limitations. A code rollback alone may not reverse a migration or external side effect.
7. After release, verify key user journeys, error rates, latency, saturation, and relevant business signals. Record ownership and escalation paths for incidents.
8. Define rollout stop/rollback thresholds and an observation window using agreed service objectives and normal traffic patterns. Check alerts and dashboards are available to the release owner; "monitor after deploy" without a decision rule is not a gate.
9. Check readiness reflects ability to serve traffic and liveness does not create restart storms during dependency outages. Test termination grace periods, in-flight draining, and job ownership across overlapping versions where affected.

## Verification evidence

- Validate pipeline/configuration syntax and artifact build using the existing tools. Rehearse affected rollout and recovery steps in an authorized non-production environment before live changes when required by risk or project gates.
- Identify the artifact, configuration version, migration ordering, operator, and approved recovery path. Check rollback compatibility with data and external effects; do not assume redeploying an old artifact is safe.
- Mark gates planned, verified, or blocked with evidence. Do not report post-release success before an authorized deployment and its observation checks actually occur.

## Restrictions

- Do not deploy, publish, change live configuration, or run production migrations without explicit authorization.
- Never bypass required approvals, CI checks, security scans, or rollout gates.
- Distinguish verified checks from assumptions; identify platform-specific checks that could not be run.
- Do not disable alerts, broaden deployment identities, bypass artifact verification, or alter live secrets/flags to force rollout success. Missing rollback or stop criteria require an owner's decision before an affected live change.
