## What and why

<!-- One purpose per pull request. -->

## Verification

<!-- Commands you ran and results. Say what you could not verify. -->

- [ ] `tests/install.tests.ps1` (Windows) or `tests/install.tests.sh` (Bash) passes for installer changes
- [ ] Skill folder name matches the `name` in its frontmatter
- [ ] Skills table, routing table, and counts updated if a skill was added or removed
- [ ] No installer-generated copies committed (`.claude/`, `.github/skills/`, and so on)
- [ ] `CHANGELOG.md` updated under `Unreleased`
- [ ] No tests, CI checks, or Restrictions were weakened
