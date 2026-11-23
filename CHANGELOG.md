# Changelog

All notable changes to this project are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- `skill-uninstall.ps1` and `skill-uninstall.sh`: remove the skills, workflow instructions, and review commands the installers add, for project or global scope.
- `--harness` (Bash) and `-Harness` (PowerShell) on the installers and uninstallers to act on selected harnesses (`claude`, `copilot`, `kiro`, `opencode`, `hermes`). Without it, all harnesses are used as before.
- Uninstaller tests for both shells, run in CI and the release workflow.
## [0.1.0] - 2026-11-23

First public release.

### Added

- 19 Agent Skills under `skills/`, with `solid-tdd-craft` as the entry point and a shared required engineering workflow.
- Installers for Windows PowerShell (`skill-install.ps1`) and Bash (`skill-install.sh`), with project and global scope, for Claude Code, GitHub Copilot, Kiro, OpenCode, and Hermes Agent.
- Review commands for Claude Code, GitHub Copilot, Kiro, and OpenCode.
- Installer integration tests and a GitHub Actions workflow running them on Windows and Linux.
- Release workflow that packages the skills and installers as `.zip` and `.tar.gz` archives.
- Documentation: installation, usage, quality controls, verification, creating a skill, and adding a harness.
- Contributing guide, security policy, code of conduct, and issue and pull request templates.

[Unreleased]: https://github.com/theprodsde/codingharnes-kg/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/theprodsde/codingharnes-kg/releases/tag/v0.1.0
