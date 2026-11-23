# Agent Instructions

For any code change, follow [`skills/solid-tdd-craft/SKILL.md`](skills/solid-tdd-craft/SKILL.md) and its companion skills; its Restrictions are mandatory.

Before editing, apply the [required engineering workflow](skills/solid-tdd-craft/references/WORKFLOW.md). If required guidance cannot be loaded, stop before code changes and report the blocker. Report loading mode, acceptance criteria, verification evidence, and outstanding blockers; instructions do not replace independently enforced CI or approvals.

For any code change, follow the `solid-tdd-craft` skill and its companion skills; its Restrictions are mandatory.

## Required engineering workflow

Before editing, load the entry skill and only the companions required by the task and affected application layers. Use the entry skill's routing table, not file extensions alone; revisit selection if scope changes. Read-only requests remain read-only.

If required guidance cannot be loaded, stop before code changes and report the missing skill or trust prerequisite. Do not bypass host permissions. If the harness permits reading trusted skill files as context instead of native activation, report that mode explicitly; native activation remains not verified. A claimed skill name is not loading evidence.

Acceptance criteria must identify observable behavior, relevant boundaries/failures, preserved contracts, and the checks that prove them. Find existing project commands and applicable accessibility, security, migration, and performance budgets. Ask the owner about missing decisions that block the task; do not invent thresholds or add unrelated infrastructure.

For behavioral changes, demonstrate the expected failing test before implementation, then pass the affected checks and verify the real application path. A setup failure is not a red behavioral test. For documentation-only work, behavioral tests may be not applicable with a reason.

Before claiming completion, report skills and loading evidence/mode, acceptance criteria with verification commands/results, and remaining blockers. Use verified, failed, not run, or not applicable with reasons for checks; mark unobservable activation not verified. Missing required evidence blocks the affected completion/readiness claim. Keep the report proportional to the task.

Do not weaken tests, required CI checks, branch protections, permissions, or human approvals to finish. Instruction text does not enforce tool or merge gates. Use independently configured host controls and required CI checks; high-risk changes need the project's authorized reviewers. No agent may approve its own exception or infer deployment permission from passing tests.
