# Contributing

Thanks for helping improve these skills. By participating you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Where things live

| Path | Purpose |
|---|---|
| `skills/<skill-id>/SKILL.md` | Canonical source for each skill. Edit these. |
| `commands/` | Review command templates the installers copy per harness. |
| `skill-install.ps1`, `skill-install.sh` | Installers for Windows PowerShell and Bash. |
| `skill-uninstall.ps1`, `skill-uninstall.sh` | Uninstallers that reverse the installers. |
| `tests/` | Installer integration tests for both shells. |
| `docs/` | Installation, usage, quality controls, and verification guides. |
| `.versions/` | Historical snapshots. Not installed; do not edit. |
| `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `.kiro/steering/craft.md` | Instructions for agents working on this repository. Tracked. |
| `.claude/`, `.hermes/`, `.opencode/`, `.kiro/skills/`, `.github/skills/`, `.github/prompts/` | Created when you run the installer on this repository. Git ignores them; never commit them. |

New here? Start with an issue labeled [`good first issue`](https://github.com/theprodsde/codingharnes-kg/labels/good%20first%20issue). These guides walk through the two most common contributions:

- [Creating a skill](docs/creating-skills.md): write a `SKILL.md` and try it in your own harness.
- [Adding a harness](docs/adding-a-harness.md): teach both installers about a new agent tool.

## Changing a skill

1. Edit `skills/<skill-id>/SKILL.md`. The folder name must match the `name` field in the frontmatter, and the `description` should say when to use the skill.
2. If you add or remove a skill, update the skills table in `README.md`, the routing table in `skills/solid-tdd-craft/SKILL.md`, and the skill count in the docs and tests.
3. To try your change in a harness, install into this repository or a scratch project and start a new session:

   ```powershell
   .\skill-install.ps1 -Target .
   ```

   ```bash
   bash ./skill-install.sh --project .
   ```

   The installed copies in this repository are ignored by Git, so only your source change shows up in `git status`.

4. Add a line under `Unreleased` in [CHANGELOG.md](CHANGELOG.md).

## Running the tests

Windows PowerShell:

```powershell
.\tests\install.tests.ps1
.\tests\uninstall.tests.ps1
```

Linux or WSL Bash:

```bash
bash -n ./skill-install.sh ./skill-uninstall.sh ./tests/install.tests.sh ./tests/uninstall.tests.sh
bash ./tests/install.tests.sh
bash ./tests/uninstall.tests.sh
```

The tests use temporary directories and do not touch your real harness profiles. CI runs both suites on every push and pull request.

## Pull requests

- Keep each pull request to one purpose.
- Add or update a test when you change installer behavior.
- Do not weaken tests, CI checks, or the Restrictions in `solid-tdd-craft` to make a change pass.
- Shell scripts must keep LF line endings. `.gitattributes` enforces this.
- Explain what you verified and what you could not. The skills ask agents for the same honesty.

## Reporting problems

Use the issue templates for bugs and feature requests. Report security problems privately as described in [SECURITY.md](SECURITY.md).
