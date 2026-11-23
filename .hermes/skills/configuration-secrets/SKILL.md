---
name: configuration-secrets
description: Implement validated runtime configuration and safe secret handling, environment compatibility, rotation, and redaction without exposing credentials or modifying live settings.
---

# Configuration and Secrets

Use when environment variables, feature flags, configuration schemas, secret references, or runtime credential handling change. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions; use `../tdd-workflow/SKILL.md` for behavior. Configuration reviews remain read-only.

## Before implementation

- Inspect the canonical config loader, precedence rules, environment separation, approved secret manager, startup validation, and deployment templates.
- Identify which settings are required, sensitive, public/browser-visible, reloadable, or version-dependent. Obtain decisions for defaults or flags that change access, data handling, or user behavior.

## Implementation checks

1. Parse and validate types, ranges, allowed values, and cross-field constraints at the established boundary. Fail explicitly for missing/invalid required settings; defaults must be documented and safe, not a substitute for absent credentials.
2. Keep config access consistent through the existing loader. Document precedence and reload/restart behavior; distinguish an absent value from an intentionally empty value where the domain requires it.
3. Retrieve secrets with least-privilege runtime identities. Keep secret values out of browser bundles, generated files, examples, process arguments, telemetry, and error responses; use synthetic placeholders in tests.
4. Define rotation, cache lifetime, expiry, and overlapping old/new credentials using provider-supported mechanisms. Handle unavailable secret stores explicitly; never fall back to a built-in credential.
5. Keep old/new application configuration compatible during rollout. For feature flags, define ownership, safe defaults, failure behavior, rollout scope, and removal criteria. A feature flag is not authorization.
6. Distinguish build-time substitution from runtime configuration. Browser-exposed build values are public and often require rebuilding to change; a deployment environment variable may not change an already-built bundle. Use the existing runtime-config mechanism when available and keep flags consistent across server rendering and client hydration.

## Restrictions

- Do not read, print, copy, or modify real secrets or private environment files merely to investigate configuration; use names, schemas, and sanitized diagnostics.
- Do not hard-code credentials, dump full configuration/environment objects, weaken validation, disable certificate checks, or silently select a privileged default.
- Do not rotate/revoke live credentials, change secret-store policy, toggle production flags, or change live configuration without explicit authorization and a recovery plan.
- Do not add a secret manager or configuration framework when the repository already has an approved mechanism. An example file must never contain usable credentials.

## Verification gates

- Test missing, malformed, out-of-range, precedence, and relevant reload behavior using isolated synthetic configuration; verify safe redacted errors.
- Exercise affected startup/runtime paths and project build/config-schema checks. For frontend changes, check that only explicitly public settings enter the client artifact.
- Test changed feature behavior with flags enabled and disabled, including supported missing/unavailable-provider behavior. Verify values at the actual consumption point, not only in the config loader; record when a setting requires rebuilding rather than restarting.
- Rehearse required rotation and unavailable-provider behavior in an authorized non-production environment; mocks alone do not prove provider rotation works.
- Update sanitized examples and operator instructions. Missing decisions for sensitive defaults or required configuration/rotation evidence block the affected readiness claim; report checks not run.
