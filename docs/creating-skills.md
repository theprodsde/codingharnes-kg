# Creating a skill

A skill is a folder with a `SKILL.md` file in it. The agent reads the file's short description to decide when the skill applies, then loads the full text when it needs it. This repository follows the [Agent Skills format](https://github.com/agentskills/agentskills), so the same folder works in every supported harness.

This guide takes about 15 minutes. You need Git, a text editor, and at least one harness installed (Claude Code, GitHub Copilot, Kiro, OpenCode, or Hermes Agent).

## 1. Get the repository

Fork the repository on GitHub, then clone your fork:

```bash
git clone https://github.com/<your-username>/codingharnes-kg.git
cd codingharnes-kg
git checkout -b add-my-skill
```

## 2. Create the folder and file

Pick a short, lowercase, hyphenated ID, for example `commit-messages`. The folder name and the `name` field must match exactly; the installer tests check this.

```text
skills/
  commit-messages/
    SKILL.md
```

## 3. Write `SKILL.md`

```markdown
---
name: commit-messages
description: Write clear Git commit messages. Use when committing changes or reviewing commit history.
---

# Commit Messages

Follow `../solid-tdd-craft/SKILL.md` and its Restrictions.

## Rules

- Start the subject with an imperative verb ("Add", "Fix"), under 72 characters.
- Explain why in the body when the reason is not obvious from the diff.
- One logical change per commit.

## Verification

- Run `git log -1` and check the subject against the rules above.
```

Tips for a good skill:

- **Description.** Say what the skill does and when to use it. This one sentence decides whether the agent picks the skill up, so name the situations ("when committing", "for database migrations").
- **Rules.** Write instructions the agent can act on and check. "Keep functions under 40 lines" works better than "write clean code".
- **Verification.** End with how to prove the work is done: a command, a test, or an observable result.
- **Size.** Keep `SKILL.md` focused. Put long checklists in a `references/` subfolder and link to them, as `skills/solid-tdd-craft/` does.

## 4. Install it into a scratch project

Use a throwaway folder so you don't touch real projects.

Windows PowerShell:

```powershell
mkdir $env:TEMP\skill-test
.\skill-install.ps1 -Target $env:TEMP\skill-test
```

Linux, macOS, or WSL:

```bash
mkdir -p /tmp/skill-test
bash ./skill-install.sh --project /tmp/skill-test
```

The installer copies every skill, including your new one, into each harness's project folder, such as `.claude/skills/commit-messages/SKILL.md`.

## 5. Test it in your harness

Open the scratch folder in your harness and start a **new** session. Then:

1. Check that the skill is discovered. In Claude Code or Kiro, type `/` and look for `commit-messages`. In Copilot CLI, run `/skills list`.
2. Ask for it by name: `Use the commit-messages skill to write a commit message for this change.`
3. Ask without naming it, with a request that matches the description: `Commit these changes.` Note whether the harness picked the skill up by itself. Automatic selection varies by harness, so record what you saw rather than assuming.

If the skill isn't found, check the folder name matches `name:`, the frontmatter starts and ends with `---`, and that you started a new session.

## 6. Run the tests and open a pull request

The installer tests check a fixed list of skill IDs. Add your ID to the `skills=(...)` list in `tests/install.tests.sh` and to the matching list in `tests/install.tests.ps1`, then run:

```powershell
.\tests\install.tests.ps1
```

```bash
bash ./tests/install.tests.sh
```

Also add your skill to the table in `README.md`, to the routing table in `skills/solid-tdd-craft/SKILL.md` if the entry skill should route to it, and a line to `CHANGELOG.md` under `Unreleased`.

In the pull request, say which harness and version you tested with and whether it was found by name, automatically, or both. See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full checklist.

## Keeping a skill only for yourself

You don't have to contribute a skill to use it. Put the folder in your harness's user-level skills directory (see the table in [Installation](installation.md#install-on-this-machine)), or in your own project's skills folder, and start a new session.
