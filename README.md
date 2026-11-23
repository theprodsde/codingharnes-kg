# SOLID · TDD · Clean Code Craft

[![Validate skills](https://github.com/theprodsde/codingharnes-kg/actions/workflows/validate.yml/badge.svg)](https://github.com/theprodsde/codingharnes-kg/actions/workflows/validate.yml)
[![Latest release](https://img.shields.io/github/v/release/theprodsde/codingharnes-kg)](https://github.com/theprodsde/codingharnes-kg/releases/latest)
[![good first issues](https://img.shields.io/github/issues/theprodsde/codingharnes-kg/good%20first%20issue)](https://github.com/theprodsde/codingharnes-kg/labels/good%20first%20issue)

Portable Agent Skills for test-first engineering, architecture, frontend and backend development, code review, deployment, and production readiness. Install them per project or across your user profile for Claude Code, GitHub Copilot, Kiro, OpenCode, and Hermes Agent.

## Quick start

Clone this repository, then run an installer from its root. Keep the installer beside the skills/ and commands/ directories.

**Install into a project** (skills, always-on instructions, and review commands):

`powershell
.\skill-install.ps1 -Target "C:\work\my-project"
`

`bash
bash ./skill-install.sh --project /path/to/my-project
`

**Install for your user account** (all supported harnesses at once):

`powershell
.\skill-install.ps1 -Scope Global
`

`bash
bash ./skill-install.sh --global
`

Prefer a download? Get the `.zip` or `.tar.gz` from the [latest release](https://github.com/theprodsde/codingharnes-kg/releases/latest), extract it, and run the same commands from the extracted folder.

Then start a new session in your harness. Matching skill and review-command files are overwritten, so review existing files first. See [Installation](docs/installation.md) for prerequisites, paths, and overrides.

**Choose harnesses.** By default the installers cover all five harnesses. To limit a run, name them with --harness (Bash, comma-separated or repeated) or -Harness (PowerShell): `claude`, `copilot`, `kiro`, `opencode`, `hermes`.

```powershell
.\skill-install.ps1 -Target . -Harness kiro, claude
```

**Uninstall.** `skill-uninstall.ps1` and `skill-uninstall.sh` take the same scope, target, and harness options and remove what the installers added. See [Installation](docs/installation.md#uninstall).

```powershell
.\skill-uninstall.ps1 -Target "C:\work\my-project"
.\skill-uninstall.ps1 -Scope Global -Harness kiro
```

## Supported harnesses

| Harness | Project skills | User-level skills |
|---|---|---|
| Claude Code | .claude/skills/ | ~/.claude/skills/ |
| GitHub Copilot | .github/skills/ | ~/.copilot/skills/ |
| Kiro | .kiro/skills/ | ~/.kiro/skills/ |
| OpenCode | .opencode/skills/ | ~/.config/opencode/skills/ |
| Hermes Agent | .hermes/skills/ (requires hermes skills trust) | ~/.hermes/skills/ |

## Skills
| Skill | What it covers / when to use it |
|---|---|
| `solid-tdd-craft` | Entry point; shared engineering rules and links to focused skills. |
| `tdd-workflow` | Turn requirements into acceptance tests; use red-green-refactor and verify results. |
| `solid-design` | Design responsibilities, dependencies, interfaces, and SOLID boundaries. |
| `clean-code` | Improve names, reduce complexity, and keep changes maintainable. |
| `code-review` | Read-only review for correctness, regressions, tests, and maintainability. |
| `security-review` | Read-only security assessment of trust boundaries, data handling, and exposed operations. |
| `production-readiness` | Assess compatibility, production impact, release gates, operations, and recovery. |
| `deployment` | Plan safe rollouts, runtime configuration, health checks, monitoring, and rollback/recovery. |
| `microservices-architecture` | Assess service boundaries, contracts, data ownership, resilience, and distributed-systems tradeoffs. |
| `monolithic-architecture` | Design modular monoliths and decide when evidence justifies service extraction. |
| `frontend-development` | Build UI with accessibility, responsive behavior, safe client-side patterns, performance, and tests. |
| `backend-development` | Build APIs, server logic, workers, and integrations with explicit contracts, authorization, concurrency safety, reliability, and tests. |
| `database-production` | Develop and change production databases: schemas, queries, migrations, backups, security, and operations. |
| `api-contracts` | Preserve API/event compatibility, validate transport contracts, and verify affected consumers. |
| `authentication-authorization` | Enforce identity, session, object/tenant permissions, and verified allow/deny behavior. |
| `dependency-supply-chain` | Control packages, lockfiles, build sources, permissions, advisories, and license/provenance gates. |
| `configuration-secrets` | Validate configuration, prevent secret exposure, and plan safe rotation and mixed-version rollout. |
| `observability-recovery` | Verify telemetry, alert ownership, health signals, runbooks, and operational recovery evidence. |
| `data-privacy-retention` | Minimize sensitive data and verify approved access, sharing, retention, deletion, and restore reconciliation. |

Every source skill lives at `skills/<skill-id>/SKILL.md`, and its folder name matches the `name` field in its frontmatter. The installers copy only this canonical tree. `.versions/` contains historical snapshots and is not installed.

## Documentation

- [Installation](docs/installation.md): prerequisites, project and global install, path overrides, GitHub-hosted Copilot agents.
- [Using the skills](docs/usage.md): invoking skills in each harness and prompt templates.
- [Quality controls and production workflow](docs/quality-controls.md): acceptance criteria, external enforcement, release workflow.
- [Verification](docs/verification.md): installer tests and manual harness acceptance scenarios.
- [Creating a skill](docs/creating-skills.md): write your own skill and test it in your harness.
- [Adding a harness](docs/adding-a-harness.md): add installer support for another agent tool.
- [Changelog](CHANGELOG.md): what changed in each release.
- [Required engineering workflow](skills/solid-tdd-craft/references/WORKFLOW.md): the shared rules installed into always-on instruction files.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to change a skill and run the tests. Report vulnerabilities as described in [SECURITY.md](SECURITY.md).

These skills are engineering guidance. They do not enforce behavior, grant permissions, or guarantee production quality. Keep your own CI and human review in place.