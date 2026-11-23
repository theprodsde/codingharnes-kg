# Using the skills

How to invoke skills in each harness and write prompts that give useful results.

## Use the skills in each harness

Skills are discovered from their descriptions and may activate automatically. To choose one explicitly, use the harness's skill picker/slash command when available, or name the skill in your request. Start a new chat after a global install if the harness does not discover the new skills.

**Automatic selection is possible, not guaranteed.** The harness must support skills, discover the installed directory, enable the feature, and satisfy its trust/permission requirements. Normally descriptions help the agent select a skill and its full instructions are loaded when needed; installation does not mean every skill is loaded on every prompt. The installed always-on guidance directs code changes to `solid-tdd-craft` on surfaces that load that instruction file; it does not override host rules or prove compliance.

**For predictable use, name the entry skill and the task.** Ask it to select only relevant companions; there is no need to list all 19. For high-risk work, name the affected domain skills too. Natural-language skill names are more portable than slash syntax, which depends on the harness/version. Neither naming a skill nor an agent saying it used one proves activation: check the harness's skill/tool activity when available and the resulting verification evidence.

| Harness | How to use a skill |
|---|---|
| Claude Code | Type `/` plus the skill ID, for example `/tdd-workflow`, or ask Claude to use that skill. Skills may also activate automatically when relevant. |
| GitHub Copilot | In Copilot Chat, ask `Use the frontend-development skill ...` or use the skill picker if available. In Copilot CLI, use `/skills list` to check discovery and `/skills info SKILL-ID` for details when supported by the installed version. |
| Kiro | Type `/` and select a skill, such as `/database-production`; Kiro can also activate skills automatically from the request. |
| OpenCode | Skills are advertised to the agent and loaded when relevant. Ask directly, for example: `Use the deployment skill to review this rollout plan.` |
| Hermes Agent | Ask Hermes to use a named skill, for example: `Use database-production to review this migration.` Project skills require the [trust step](installation.md#install-for-a-project). |

Example request that works across harnesses:

```text
Use the database-production skill to review this migration for compatibility,
locking, query impact, and recovery. Do not run production commands.
```

### Prompting for useful results

Include the desired behavior, scope, acceptance criteria, constraints, and known verification commands or their documentation location. Specify **implement**, **investigate**, or **review only**. Replace bracketed placeholders below; do not leave the agent to invent product policy or performance targets.

**Feature or bug fix:**

```text
Use solid-tdd-craft and select the relevant companion skills.
Implement [behavior] in [existing screen/API/job].
Acceptance criteria: [observable success, boundary, and failure outcomes].
Preserve [existing contracts/permissions]; reuse the project's patterns.
Find the canonical checks in [project documentation/CI]. Use test-first
changes and verify the real application path, not just an isolated helper.
Report skills used, changed behavior, exact checks/results, and blockers.
Do not deploy or access production data.
```

For full-stack work, explicitly add `frontend-development`, `backend-development`, and `database-production` when all three layers are affected. Add specialized skills only for affected contracts, access, configuration, dependencies, telemetry, or data lifecycle.

**Performance investigation before optimization:**

```text
Use solid-tdd-craft, production-readiness, and the relevant layer skills.
Investigate [slow journey/query/operation]. Do not change code yet.
The approved budget and workload are [criteria or documentation location].
Use existing profiling/benchmark tools. Establish a comparable baseline,
identify the bottleneck, and propose the smallest evidence-backed change.
Load testing is permitted only against [isolated target] within [rate,
concurrency, duration, and stop limits]; if unspecified, do not run load tests.
Report measurements, limitations, and any missing acceptance decisions.
```

**Read-only review:**

```text
Use code-review and relevant domain companions. Review [diff/base/scope]
against [intended behavior]. Do not edit files or install dependencies.
Report verified issues with locations and impact; list evidence gaps
separately. No findings does not mean production approval.
```

If a skill is not found, check its discovery listing/settings and effective project/profile path, required trust, and the full companion folder structure. Check for stale or duplicate project/user installations using the harness's precedence rules; do not assume they merge. Reinstall only the intended scope and start a new session as needed. If discovery is still unavailable, report that limitation; reading a trusted file as context is not proof of native skill activation. Do not bypass host trust or permission controls.
