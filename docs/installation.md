# Installation

How to install the skills for a single project, for your user profile, or for GitHub-hosted Copilot agents.

## Installer prerequisites

Keep `skill-install.ps1` and `skill-install.sh` (and the matching `skill-uninstall` scripts) beside the complete `skills/` and `commands/` directories. They resolve these sources relative to the script, so they can be invoked from another working directory. Download/extract the complete repository, not just the installer.

- **Windows:** use `skill-install.ps1` with Windows PowerShell 5.1 or later. No administrator rights are needed for writable project/user directories.
- **Linux:** use `bash skill-install.sh` with Bash and standard `cp`, `mkdir`, `dirname`, and `grep` utilities. Do not invoke it with `sh`. Shell files must retain LF line endings; `.gitattributes` enforces this for Git checkouts.
- **WSL:** global installation targets the Linux user's home, not the Windows harness profiles. Use PowerShell to install for Windows-native harnesses.
- **Git Bash:** use POSIX paths such as `/c/Users/name/project`, including environment overrides. This environment is not part of the verified test matrix in [Verification](verification.md).

Both installers copy a baseline for all five harnesses; they do not detect or install harness executables, change permissions, grant project trust, or guarantee skill activation. Review existing files before installation: matching skill and review-command files are overwritten; unrelated files are not removed. Instruction files retain their content and receive missing paragraphs from the shared [required engineering workflow](../skills/solid-tdd-craft/references/WORKFLOW.md) without duplicating unchanged guidance. Existing installations with only the original guidance line are upgraded on rerun. Previously installed or manually customized instructions are not removed; review any conflicting older guidance yourself. Installation is not transactional; after a permission or filesystem failure, correct the reported issue and rerun.

## Install for a project

Run from the repository root:

```powershell
.\skill-install.ps1 -Target .
```

```bash
bash ./skill-install.sh --project .
```

Project scope is the default. Skills are copied to each harness's project skill directory. The installer also adds or updates always-on instruction files and review command files.

For a different project, pass its path as `-Target "C:\work\my project"` in PowerShell or `--project "/home/name/my project"` in Bash. With no target, the current working directory is used, not the installer's directory. Project mode ignores global profile overrides and does not require `HOME` in Bash.

Hermes project skills are copied to `.hermes/skills/`. Hermes intentionally requires an explicit trust step before it loads project skills. Review the files first, then from the project root run:

```bash
hermes skills trust
```

This trust step is not automated: it changes a security boundary. See the [Hermes Agent skills documentation](https://hermesagent.nousresearch.com/docs/user-guide/features/skills/) for trust and skill-management details.

The `.github/prompts/review.prompt.md` file is for VS Code's Local harness. In Copilot agent mode, invoke the installed `code-review` skill.

## Install on this machine

Install all 19 skills and user-level instructions for the current operating-system account (not every account on the device):

```powershell
.\skill-install.ps1 -Scope Global
```

```bash
bash ./skill-install.sh --global
```

| Harness | Skills | Always-on instructions |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `~/.claude/CLAUDE.md` |
| GitHub Copilot | `~/.copilot/skills/` | `~/.copilot/copilot-instructions.md` |
| Kiro | `~/.kiro/skills/` | `~/.kiro/steering/solid-tdd-craft.md` |
| OpenCode | `~/.config/opencode/skills/` | `~/.config/opencode/AGENTS.md` |
| Hermes Agent | `${HERMES_HOME:-~/.hermes}/skills/` | Not applicable |

These paths are the installer's defaults. The `SKILL.md` files are copied into a folder named for each skill ID. The installer's project mode is useful when a team needs checked-in, repository-specific copies instead of personal skills.

The global command installs to all supported harnesses in one run. To install manually for only one harness, copy the **contents** of the repository's `skills/` directory into that harness's user-level skills directory from the table above. Keep the full folder structure (`<skill-id>/SKILL.md`), because the core skill links to its companion skills.

For Hermes, set `HERMES_HOME` to an absolute path before global installation to use a custom profile. For example:

```powershell
$env:HERMES_HOME = "D:\HermesProfile"
.\skill-install.ps1 -Scope Global
```

```bash
HERMES_HOME="$HOME/.hermes" bash ./skill-install.sh --global
```

Hermes global skills are available to the profile; project skills still require `hermes skills trust`. Do not trust an unfamiliar repository or skill without reviewing it. Project skills may be committed with the project; machine-wide skills remain under your user profile. Restart or open a new session if a harness does not discover newly installed skills.

The global installer also adds review commands for Claude Code, Kiro, and OpenCode. It honors nonempty `KIRO_HOME`, `HERMES_HOME`, and `XDG_CONFIG_HOME` overrides; OpenCode is installed under `$XDG_CONFIG_HOME/opencode`, defaulting to `~/.config/opencode`. Set the same profile environment when starting the harness. Empty or unset overrides use the defaults above.

Global paths must be absolute and are validated before files are written. PowerShell accepts Windows drive/UNC paths and `-HomePath <path>` for a custom home or isolated tests. Explicit profile overrides still take precedence over `-HomePath`; clear or redirect all three overrides when testing. Bash requires absolute POSIX paths and a nonempty absolute `HOME` for global installation. Global scope does not accept a project target; unknown options and extra target arguments are errors. Run `bash ./skill-install.sh --help` or `Get-Help .\skill-install.ps1` for command syntax.


## Choose harnesses

By default both installers act on all five harnesses. Pass `--harness` (Bash) or `-Harness` (PowerShell) to limit a run to some of them. Valid names are `claude`, `copilot`, `kiro`, `opencode`, and `hermes`. Bash accepts a comma-separated list or repeated flags, and PowerShell accepts a list. Unknown names are rejected before any file is written.

```powershell
.\skill-install.ps1 -Target . -Harness kiro, claude
.\skill-install.ps1 -Scope Global -Harness copilot
```

```bash
bash ./skill-install.sh --project . --harness kiro,claude
bash ./skill-install.sh --global --harness copilot
```

Each harness owns these files: Claude Code (`.claude/skills`, `CLAUDE.md`, `.claude/commands/review.md`), GitHub Copilot (`.github/skills`, `.github/copilot-instructions.md`, `.github/prompts/review.prompt.md`), Kiro (`.kiro/skills`, `.kiro/steering/craft.md`, `.kiro/steering/kiro-review.md`), OpenCode (`.opencode/skills`, `AGENTS.md`, `.opencode/commands/review.md`), and Hermes Agent (`.hermes/skills`). Global scope uses the paths in the table above. `AGENTS.md` is assigned to OpenCode even though other tools may read it.

## Uninstall

`skill-uninstall.ps1` and `skill-uninstall.sh` reverse an installation. They take the same scope, target, `--harness`/`-Harness`, and path-override options as the installers, and they run from the same repository checkout because they read the shipped `skills/`, `commands/`, and workflow files to know what to remove.

```powershell
.\skill-uninstall.ps1 -Target .
.\skill-uninstall.ps1 -Scope Global
.\skill-uninstall.ps1 -Scope Global -Harness kiro
```

```bash
bash ./skill-uninstall.sh --project .
bash ./skill-uninstall.sh --global
bash ./skill-uninstall.sh --global --harness kiro
```

What is removed:

- **Skills:** only the skill folders this repository ships (for example `solid-tdd-craft`), including any edits inside them. Other skills in the same directory are kept. The skills directory is deleted only if it ends up empty.
- **Instruction files:** every line of the shared [required engineering workflow](../skills/solid-tdd-craft/references/WORKFLOW.md), plus the blank line the installer added before it. This also removes an identical line you wrote yourself. The file is deleted only if nothing but the installer's header remains; otherwise your other content and its line endings are kept.
- **Review commands:** a command file is deleted only if it still matches the shipped copy. A customized file is kept and reported as `Command kept (modified)`.

Missing files are skipped, so repeated runs are harmless. The uninstallers do not remove empty parent folders such as `.claude/`, undo `hermes skills trust`, or touch anything outside the paths above. Project-scoped files you committed remain in Git history; review `git status` before committing the removal. Do not run the uninstaller from this repository's checkout against itself unless you want to remove its installed copies (`AGENTS.md`, `CLAUDE.md`, and `.kiro/steering/craft.md` are tracked here).

## GitHub Copilot and GitHub-hosted agents

The machine-wide install puts personal skills in `~/.copilot/skills/`, for local Copilot surfaces that support personal skills. A local home-directory install is not available to GitHub-hosted cloud agents. To share skills with a repository or make them available to GitHub-hosted Copilot agents, run the project installer from that repository's root and commit `.github/skills/` and `.github/copilot-instructions.md`:

```powershell
& "C:\path\to\solid-tdd-craft\skill-install.ps1" -Target .
```

```bash
bash /path/to/solid-tdd-craft/skill-install.sh .
```

Review the generated files before committing. For skills from other GitHub repositories, GitHub CLI also provides `gh skill search`, `gh skill preview`, and `gh skill install` (public preview; check `gh skill --help` for the installed version). Preview unfamiliar skills before installing or enabling their tools.

Official guides: [GitHub Copilot Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills), [Claude Code Skills](https://code.claude.com/docs/en/skills), [Kiro Agent Skills](https://kiro.dev/docs/skills/), [OpenCode Skills](https://opencode.ai/docs/skills/), and [Hermes Agent Skills](https://hermesagent.nousresearch.com/docs/user-guide/features/skills/).

On Windows, a device policy may block unsigned PowerShell scripts. If that happens, use the Bash installer from Git Bash if available, or follow your administrator's approved script-signing policy; do not change the machine's execution policy just to run the installer.


For project-scoped setup, review and commit the generated instruction and skill files with the project. For machine-wide setup, files remain under your user profile.
