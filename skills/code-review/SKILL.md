---
name: code-review
description: Perform a read-only review of code changes for correctness, regressions, tests, SOLID design, maintainability, and restrictions.
---

# Code Review

Review only the requested scope. Read changed files and relevant tests; verify each finding in the code. Do not edit files, run formatters, or commit.

Use `../solid-tdd-craft/SKILL.md` for shared Restrictions, not as an instruction to implement fixes. Establish the comparison base and intended behavior first; trace affected callers and integration boundaries, including unchanged code needed to validate a finding.

Check in this order:

1. **Correctness:** boundary and failure handling, regressions, and security-sensitive behavior.
2. **Tests:** behavior-focused coverage; no checks weakened or skipped to hide failures and no accidentally committed focused tests. Verify that changed expectations follow approved behavior changes and preserve unaffected regressions; report when tests were not run.
3. **Design:** SOLID, contracts, cohesion, and dependency direction; use `../solid-design/SKILL.md` where needed.
4. **Security:** use `../security-review/SKILL.md` for security-focused requests or changes with material security impact.
5. **Maintainability:** naming, complexity, and project style; use `../clean-code/SKILL.md` where needed.
6. **Production impact:** compatibility, migration, configuration, and recovery concerns when the patch changes production behavior; use `../production-readiness/SKILL.md` for release assessments.
7. **Restrictions:** hard-coded secrets, disabled checks, unapproved API/schema/dependency changes, and unrelated edits.
8. **Integration:** new routes, components, jobs, helpers, and configuration are wired into the application. Check meaningful boundary, concurrent, duplicate, cancellation, and recovery behavior when affected; use frontend, backend, or database companions for the relevant domain.
9. **Specialized gates:** use `../api-contracts/SKILL.md`, `../authentication-authorization/SKILL.md`, `../dependency-supply-chain/SKILL.md`, `../configuration-secrets/SKILL.md`, `../observability-recovery/SKILL.md`, or `../data-privacy-retention/SKILL.md` only for the areas affected by the patch. Their implementation guidance does not authorize review edits or live checks.
10. **Delivery evidence:** connect each requested outcome to the reachable implementation and a meaningful assertion. Check that mocks do not bypass changed routing, registration, or persistence. Verify affected flag states and intended consumers; do not infer integration from an import, new file, or passing helper test alone. Distinguish intentionally requested scaffolding from an incomplete delivered feature.

Report only verified issues, ordered by severity, with file and line references and a concrete fix. If there are no findings, say what was checked and identify any verification not performed. Do not invent line numbers or claim unrun tests passed.

For each finding, state the triggering condition and observable impact, not just a style preference. Separate blocking correctness/compatibility issues from optional suggestions and evidence gaps. Do not demand speculative abstractions or enforce warning line counts as defects. Run only authorized, scoped checks with isolated fixtures; tests can write generated files even during a read-only review, so avoid commands that mutate tracked files or external systems. "No findings" is not a release approval.

Use `../solid-tdd-craft/references/CHECKLIST.md` for the detailed smell catalogue. Keep the response concise.

## Restrictions

- Do not approve unspecified permission, privacy, breaking-contract, or recovery-policy decisions on behalf of an owner; identify the unresolved decision.
- Do not execute dependency installs, credential inspection, live-data queries, deployments, or operational experiments to complete a read-only review.
- Do not change files or checks to resolve findings unless the user requests implementation. Missing required evidence is an evidence gap/blocker, not proof of a defect or a passing gate.
