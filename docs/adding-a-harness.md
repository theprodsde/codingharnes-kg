# Adding a harness

A harness is an AI coding tool that loads these skills, such as Claude Code or Kiro. Adding one means teaching both installers where that tool looks for skills and instructions, then proving it works.

Open issues for new harnesses are labeled [`harness`](https://github.com/theprodsde/codingharnes-kg/labels/harness). Comment on one before you start so two people don't do the same work.

## 1. Research the harness

From the tool's **official documentation** (not blog posts), find and link in your pull request:

| Question | Example for Kiro |
|---|---|
| Does it support `SKILL.md` skill folders? | Yes |
| Project skills directory | `.kiro/skills/` |
| User-level skills directory, and any override variable | `~/.kiro/skills/`, `KIRO_HOME` |
| Always-on instruction file, if any | `.kiro/steering/craft.md` with `inclusion: always` frontmatter |
| Custom command or prompt file, if any | `.kiro/steering/kiro-review.md` |
| Any trust or approval step before project skills load | None (Hermes requires `hermes skills trust`) |

If the tool reads `AGENTS.md` for instructions, the installer already writes that file in project mode, so you may only need a skills directory.

If the tool has no skill support, say so in the issue. Rules-only tools need a different design, and that should be agreed before writing code.

## 2. Change the installers and uninstallers

Each script has one block for project scope and one for global scope, grouped by harness. Add the harness name to the allowed list (`HARNESS_NAMES` in the Bash scripts, the `-Harness` `ValidateSet` in the PowerShell scripts), then add a block guarded by `has_harness <name>` (Bash) or `Test-Harness <name>` (PowerShell) in both scopes of all four scripts:

- `skill-install.sh`: add an `install_skills "$TARGET/.<tool>/skills"` line in the project block and an `install_skills "$HOME_PATH/..."` line in the global block. Use `add_line` for an instruction file and `copy_command` for a command file.
- `skill-install.ps1`: add `Copy-Skills`, and `Add-Line` or `Copy-Command` calls as needed, inside a `Test-Harness` block.
- `skill-uninstall.sh` and `skill-uninstall.ps1`: mirror the installer with `remove_skills`/`Remove-Skills`, `remove_lines`/`Remove-Lines`, and `remove_command`/`Remove-Command`, using the same paths and headers.

If the tool supports a home-directory override variable, validate it as an absolute path the same way `KIRO_HOME` is handled.

## 3. Update the tests

In `tests/install.tests.*` and `tests/uninstall.tests.*`, add assertions that the new skills directory receives the full skill set after both a project and a global install, that it is removed by the uninstaller, and that `--harness`/`-Harness` selects it alone. Copy the existing checks for another harness. Run both suites; CI runs them on Windows and Linux.

## 4. Update the docs

- The harness tables in `README.md` and `docs/installation.md`.
- How to invoke a skill in that tool, in `docs/usage.md`.
- A row in the cross-harness status table in `docs/verification.md`, marked `Not verified` until someone runs the scenarios.
- Add the new folders to `.gitignore`, so installing into this repository doesn't create untracked files.
- A line in `CHANGELOG.md` under `Unreleased`.

## 5. Prove it works

Install into a scratch project, open it in the tool, and start a new session. Record in the pull request:

- Tool name and version, and your OS.
- Whether `solid-tdd-craft` and `tdd-workflow` show up in the tool's skill list.
- The result of asking `Use the tdd-workflow skill to add a test for <small function>.`

A screenshot or a short transcript is enough. If something didn't work, say so; a partial result with honest notes is still useful.
