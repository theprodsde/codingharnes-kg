---
name: authentication-authorization
description: Implement or assess authentication, sessions, permissions, object and tenant access, service identities, and account lifecycle changes with explicit deny-path verification.
---

# Authentication and Authorization

Use when identity, credentials, login/logout, sessions, permissions, ownership, tenant boundaries, or account recovery change. Follow `../solid-tdd-craft/SKILL.md` and its Restrictions; use `../tdd-workflow/SKILL.md` for implementation. Assessments remain read-only; use `../security-review/SKILL.md` for a focused security review.

## Before implementation

- Identify the approved identity provider/library, credential/session lifecycle, trust boundaries, and permission policy. Inspect middleware, server entry points, workers, and data-access controls.
- Define an allow/deny matrix for affected actions, actors, ownership, and tenants. Obtain the product/security owner's decision when policy is unspecified; do not invent roles or broaden access.

## Implementation checks

1. Authenticate using the established provider and verify credentials/tokens with its supported validation path, including issuer, audience, expiry, and accepted algorithms where applicable. Use approved password hashing, MFA, and recovery mechanisms; do not implement custom cryptography.
2. Authorize server-side at each affected operation and object boundary. Apply tenant scope to reads, writes, exports, caches, and jobs. Derive trusted identity and policy from validated server context, not request-supplied roles or ownership.
3. Follow project rules for session cookies, CSRF, token storage, rotation, logout, expiry, and revocation. Define how account disablement and permission changes affect existing sessions and cached policy.
4. Keep account creation, recovery, privilege changes, and service identities least-privileged. Use established abuse controls and audit events without leaking credentials or sensitive account details.
5. Fail closed when identity or policy cannot be established. Return the established safe error and actionable internal diagnostics; avoid credential disclosure or unauthorized resource enumeration.

## Restrictions

- Do not bypass middleware, create debug logins, hard-code privileged users, grant wildcard/admin permissions, or change deny-by-default policy without approved scope.
- Do not trust frontend hiding, CORS, an internal network, or possession of an object ID as authorization.
- Do not disable token verification, use permissive fallback roles on errors, store plaintext passwords, or print tokens/session cookies in logs or tests.
- Do not change live accounts, identity-provider settings, keys, or permissions without explicit authorization. Never use real credentials to satisfy a test.

## Verification gates

- Test allowed and denied access for each changed policy, including unauthenticated, wrong owner/tenant, insufficient permission, expired/invalid identity, and unavailable policy dependencies where applicable.
- Exercise the real routing/middleware/data boundary; unit tests of a permission helper alone are insufficient. Check alternate entry points and cross-tenant cache/job behavior affected by the change.
- Test relevant logout/revocation, permission changes, and recovery behavior with synthetic identities. Verify no sensitive credentials appear in responses or telemetry.
- Missing policy approval or required deny-path evidence blocks completion of an access-policy change. Report exact checks and remaining risks; do not claim a system is secure solely because these tests pass.
