# Contributing

Thanks for helping improve these skills. By participating you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Where things live

| Path | Purpose |
|---|---|
| `skills/<skill-id>/SKILL.md` | Canonical source for each skill. Edit these. |
| `commands/` | Review command templates the installers copy per harness. |
| `skill-install.ps1`, `skill-install.sh` | Installers for Windows PowerShell and Bash. |
| `tests/` | Installer integration tests for both shells. |
| `docs/` | Installation, usage, quality controls, and verification guides. |
| `.versions/` | Historical snapshots. Not installed; do not edit. |
| `.github/skills/`, `.kiro/`, `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md` | Copies produced by running the installer on this repository. Do not edit by hand. |

## Changing a skill

1. Edit `skills/<skill-id>/SKILL.md`. The folder name must match the `name` field in the frontmatter, and the `description` should say when to use the skill.
2. If you add or remove a skill, update the skills table in `README.md`, the routing table in `skills/solid-tdd-craft/SKILL.md`, and the skill count in the docs and tests.
3. Regenerate the installed copies from the repository root:

   ```powershell
   .\skill-install.ps1 -Target .
   ```

   ```bash
   bash ./skill-install.sh --project .
   ```

4. Review the generated diff and commit it together with the source change.

## Running the tests

Windows PowerShell:

```powershell
.\tests\install.tests.ps1
```

Linux or WSL Bash:

```bash
bash -n ./skill-install.sh ./tests/install.tests.sh
bash ./tests/install.tests.sh
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
