# Security Policy

## Reporting a vulnerability

Please report vulnerabilities privately. Do not open a public issue.

Use GitHub's [private vulnerability reporting](https://github.com/theprodsde/codingharnes-kg/security/advisories/new) for this repository. Include the affected file or skill, steps to reproduce, and the impact you observed.

You can expect an acknowledgement within 7 days. This is a volunteer-maintained project, so fix timelines depend on severity and maintainer availability.

## Scope

In scope:

- `skill-install.ps1` and `skill-install.sh`: path handling, overwriting or deleting files outside the intended target, unsafe handling of environment overrides.
- Skill, command, and instruction text that would cause an agent to bypass host permissions, trust prompts, or safety rules, or to expose secrets.
- The GitHub Actions workflow in `.github/workflows/`.

Out of scope:

- Behavior of the agent harnesses themselves (Claude Code, GitHub Copilot, Kiro, OpenCode, Hermes Agent). Report those to their vendors.
- Agents ignoring the installed guidance. The skills are instructions, not an enforcement mechanism.

## Supported versions

Only the latest commit on `main` is supported.
