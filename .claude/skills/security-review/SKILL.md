---
name: security-review
description: Perform a focused, read-only security review of code changes, trust boundaries, data handling, and dependency or deployment configuration.
---

# Security Review

Review only the requested scope. Trace untrusted inputs to sensitive operations and report verified risks; do not modify code or claim that a system is secure based on a checklist alone.

Follow shared Restrictions in `../solid-tdd-craft/SKILL.md`; its implementation workflow does not authorize edits during a review. Use synthetic inputs and isolated local environments only.

Use `../authentication-authorization/SKILL.md`, `../configuration-secrets/SKILL.md`, `../dependency-supply-chain/SKILL.md`, and `../data-privacy-retention/SKILL.md` for relevant policy and verification questions. Missing evidence is not certification and does not authorize live tests.

## Review sequence

1. Identify sensitive assets, trust boundaries, actors, and the changed attack surface.
2. Trace authentication and authorization at each affected entry point; verify object-level access and default-deny behavior where relevant.
3. Check input parsing and validation, injection into interpreters or queries, path handling, deserialization, and output encoding.
4. Check secrets, personal data, logs, error messages, cryptography, and retention or exposure boundaries.
5. Inspect dependency and build changes, permissions, network access, and production configuration affected by the patch.
6. Review tests for security-relevant allow, deny, and malformed-input cases. Run only safe, scoped checks; do not use real credentials or production systems.
7. Where affected, examine tenant isolation, session/cookie handling, CSRF and CORS policy, user-supplied outbound URLs, uploads, webhook authenticity/replay, and resource limits. CORS is not authorization; verify protections at the actual server entry point.
8. Verify dependency advisories against the actual locked version and reachable usage, using approved tooling. Do not install scanners or upload private sources merely to complete a checklist.

## Report

- Report only actionable, verified findings, ordered by severity.
- For each finding, give the affected file and line, preconditions, concrete impact, and a specific mitigation.
- Distinguish a confirmed vulnerability from a risk that needs more evidence. Include checks not run and the reason.
- Do not reproduce secrets or sensitive payloads in the report.
- Do not edit files, run destructive tests, change permissions, or commit.

Use `../solid-tdd-craft/references/CHECKLIST.md` for the shared review checklist.
