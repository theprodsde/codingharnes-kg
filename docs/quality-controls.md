# Quality controls and production workflow

How to define acceptance criteria, enforce checks outside the agent, and apply the skills to production work.

## Selection and quality controls

The shared [required engineering workflow](../skills/solid-tdd-craft/references/WORKFLOW.md) is included in installed always-on files and linked from the entry skill. It requires loading the entry skill and affected companions before edits, observable acceptance criteria, test-first behavioral changes, and an evidence-based completion report. Missing required guidance or verification must be reported as a blocker, not silently skipped. It distinguishes native skill activation from permitted reading of trusted files as context.

These instructions strengthen the baseline but cannot intercept tool calls. No portable cross-harness hook API is assumed or installed. To enforce loading in a particular harness, its owner must configure supported routing/pre-edit controls to require the entry skill, route companions by task and affected layers, and reject edits if loading fails. Verify this using the [harness acceptance scenarios](verification.md#harness-acceptance-scenarios). If a harness offers no enforceable control, use explicit prompts and report selection as instruction-driven, not guaranteed.

### Define the acceptance contract

Before implementation, identify the following in the task or existing project documentation. Do not create a new configuration system just to fill this table.

| Required information | Example of the evidence to require |
|---|---|
| Scope and behavior | Real screen/API/job, observable success and failure outcomes, preserved contracts and permissions. |
| Affected layers and skills | Entry skill plus relevant frontend/backend/database and specialized companions; reevaluate when scope changes. |
| Verification | Canonical build/type/lint/test commands; a test that exercises the actual changed application path. |
| Applicable budgets | Project-approved accessibility targets, migration limits, and performance workloads/thresholds; missing required decisions go to the owner. |
| Approval and completion | Required CI checks, responsible reviewers, exact results and blockers; no self-approved exceptions or implied deployment permission. |

Use this compact completion format; unavailable evidence must remain explicit:

```text
Skills: [selected skills; native loading evidence or trusted file-context mode]
Criteria: [observable outcome -> test/check]
Verification: [command, environment/source state, result]
Blockers: [missing evidence/decisions/approvals and required follow-up, or none]
```

Use `verified`, `failed`, `not run`, or `not applicable` with reasons for checks. Mark native activation `not verified` when it cannot be observed. A truthful report is necessary but is not independent proof: compare it with tool activity, test output, and CI results.

### Enforce checks outside the agent

This repository includes [Validate skills](../.github/workflows/validate.yml), which runs the Windows PowerShell and Linux Bash installer suites on pushes, pull requests, merge queues, and manual dispatch. It uses a pinned checkout action, read-only repository permissions, no retained checkout credentials, and bounded hosted jobs. The tests validate the installed skills and workflow guidance, including upgrading existing files and avoiding duplicates. They do not certify skill selection or application quality. Hosted execution remains unverified until this workflow is committed to a GitHub repository and actually runs.

An authorized repository owner must separately configure a branch ruleset/protection to require the emitted `Installer / Windows` and `Installer / Linux` checks before merging. Confirm the exact check names from a real run. Require appropriate human approval, including responsible domain owners for high-risk changes and changes to tests/workflows/skill restrictions; restrict bypass permissions according to project policy. The installer does not modify remote settings or invent reviewer identities. A workflow file alone does not block merging.

For an application consuming these skills, retain and require **its own** build/type/lint/tests and relevant security, integration, accessibility, migration, and performance gates. This repository's installer CI is not a substitute. Installers intentionally do not copy CI workflows into consuming applications or override their pipeline. Agents must not edit those gates merely to obtain a passing result; approved changes to the gates themselves still need independent review.

| Control | Current state |
|---|---|
| Required loading and evidence instructions | Implemented in the shared workflow and both installers; instruction-level only. |
| Installer integration tests | Passed locally on Windows PowerShell and Ubuntu Bash through WSL. |
| GitHub Actions workflow | Added; hosted run not verified. |
| Required checks / protected branches / human review | Owner configuration required; not enabled by these files. |
| Enforced native routing / pre-edit hooks | Harness-specific configuration and testing required; not installed. |
| Cross-harness behavior | Not verified; run the [acceptance scenarios](verification.md#harness-acceptance-scenarios) later. |


## Production workflow

Start with `solid-tdd-craft` and its Restrictions. Use `tdd-workflow` for behavioral changes, `frontend-development` for UI work, `backend-development` for server/API/worker work, the architecture skills when choosing application boundaries, `database-production` for persistent-data changes (including ORM changes), `code-review` and `security-review` for read-only reviews, and `production-readiness` plus `deployment` before a release. For full-stack work, select every affected layer and verify the real integrated path; a new helper or component is not delivered unless the application uses it.

Load the six specialized skills only when their area changes: `api-contracts`, `authentication-authorization`, `dependency-supply-chain`, `configuration-secrets`, `observability-recovery`, and `data-privacy-retention`. Each defines prerequisites, explicit Restrictions, and verification gates. They do not grant tool permissions, authorize live-system access, or replace host safety rules. Unknown policy decisions must go to the authorized owner, and missing required evidence remains a blocker; agents must not waive gates or weaken safeguards to finish a task.

The skills are engineering guidance, not automatic enforcement or a guarantee of production quality. Define project-specific supported runtimes/browsers, accessibility targets, API contracts, performance budgets, service objectives, data retention, and recovery objectives in existing project documentation. Agents should discover these requirements, not invent thresholds or add infrastructure by default.

For each requested outcome, require a trace from the real entry point to the observable result and its verification evidence. Imports, isolated helper tests, and mocked success do not establish that a feature is integrated. Check affected registration, callers, feature-flag states, and persisted or rendered outcomes. Explicitly requested scaffolding must be labeled incomplete, not production-ready.

Apply checks proportionately: documentation-only changes do not need invented behavioral tests, and unrelated operational rehearsals are not required for every UI edit. Relevant risks still need evidence, including user/tenant cache isolation, ambiguous write outcomes, transaction retries, migration postconditions, and build-time versus runtime configuration when those areas change. Keep evidence tied to the tested source/artifact and configuration.

Run the project's required tests, static checks, and CI gates. Record acceptance criteria, exact commands/results, relevant manual or integration evidence, and remaining blockers. Missing required evidence blocks a readiness conclusion; "no review findings" is not release approval. Local implementation does not authorize deployment or production-data access. These skills do not replace operational rehearsals, release approvals, or human review.

After changing this canonical skills tree, rerun the appropriate installer for each project or user profile that should receive the updates; existing installed copies do not automatically synchronize. Review generated changes before committing and start a new session if needed for discovery. Do not update unrelated profiles or trust settings implicitly.
