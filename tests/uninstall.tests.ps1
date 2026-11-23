$ErrorActionPreference = "Stop"
$installer = Join-Path $PSScriptRoot "..\skill-install.ps1"
$uninstaller = Join-Path $PSScriptRoot "..\skill-uninstall.ps1"
$homePath = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$originalKiroHome = $env:KIRO_HOME
$originalHermesHome = $env:HERMES_HOME
$originalXdgConfigHome = $env:XDG_CONFIG_HOME
$skills = @("solid-tdd-craft", "tdd-workflow", "solid-design", "clean-code", "code-review", "security-review", "production-readiness", "deployment", "microservices-architecture", "monolithic-architecture", "frontend-development", "backend-development", "database-production", "api-contracts", "authentication-authorization", "dependency-supply-chain", "configuration-secrets", "observability-recovery", "data-privacy-retention")

function Assert-Absent([string[]]$Paths) {
  foreach ($path in $Paths) { if (Test-Path -LiteralPath $path) { throw "Expected removed: $path" } }
}

function Assert-Present([string[]]$Paths) {
  foreach ($path in $Paths) { if (-not (Test-Path -LiteralPath $path)) { throw "Expected kept: $path" } }
}

function Assert-NoSkills([string]$SkillsRoot) {
  foreach ($skill in $skills) { Assert-Absent (Join-Path $SkillsRoot $skill) }
}

function Assert-NoWorkflow([string]$Path) {
  $content = Get-Content -LiteralPath $Path -Raw
  if ($content -and ($content.Contains("## Required engineering workflow") -or $content.Contains("solid-tdd-craft"))) {
    throw "Workflow guidance still present in $Path"
  }
}

function Assert-Rejected([scriptblock]$Action, [string]$Message) {
  $rejected = $false
  try { & $Action } catch { $rejected = $true }
  if (-not $rejected) { throw $Message }
}

try {
  $global = Join-Path $homePath "user home"
  $env:KIRO_HOME = Join-Path $global ".kiro-profile"
  $env:HERMES_HOME = Join-Path $global ".hermes-profile"
  $env:XDG_CONFIG_HOME = Join-Path $global "custom config"
  $xdgOpencode = Join-Path $env:XDG_CONFIG_HOME "opencode"
  $instruction = "For any code change, follow the ``solid-tdd-craft`` skill and its companion skills; its Restrictions are mandatory."

  # Validation happens before any write; nothing installed is a harmless no-op.
  Assert-Rejected { & $uninstaller -Scope Global -HomePath "relative-home" } "Expected a relative HomePath to be rejected."
  Assert-Rejected { & $uninstaller -Scope Global -HomePath $global -Target "ignored" } "Expected a global Target to be rejected."
  Assert-Rejected { & $uninstaller -Scope Global -HomePath $global -Harness bogus } "Expected an unknown harness to be rejected."
  & $uninstaller -Scope Global -HomePath $global
  Assert-Absent $global

  # Global scope.
  $claudeInstructions = Join-Path $global ".claude\CLAUDE.md"
  New-Item -ItemType Directory -Force -Path (Split-Path $claudeInstructions) | Out-Null
  [System.IO.File]::WriteAllText($claudeInstructions, "Existing guidance`r`n$instruction`r`n")
  & $installer -Scope Global -HomePath $global
  foreach ($custom in @((Join-Path $global ".claude\skills\my-own-skill"), (Join-Path $env:HERMES_HOME "skills\my-own-skill"))) {
    New-Item -ItemType Directory -Force -Path $custom | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $custom "SKILL.md"), "mine")
  }
  Add-Content -LiteralPath (Join-Path $xdgOpencode "commands\review.md") -Value "customized"

  & $uninstaller -Scope Global -HomePath $global
  foreach ($root in @((Join-Path $global ".claude\skills"), (Join-Path $global ".copilot\skills"), (Join-Path $env:KIRO_HOME "skills"), (Join-Path $env:HERMES_HOME "skills"), (Join-Path $xdgOpencode "skills"))) {
    Assert-NoSkills $root
  }
  Assert-Present (Join-Path $global ".claude\skills\my-own-skill\SKILL.md"), (Join-Path $env:HERMES_HOME "skills\my-own-skill\SKILL.md")
  Assert-Absent (Join-Path $global ".copilot\skills"), (Join-Path $env:KIRO_HOME "skills"), (Join-Path $xdgOpencode "skills")
  Assert-Present $claudeInstructions
  Assert-NoWorkflow $claudeInstructions
  $claudeText = Get-Content -LiteralPath $claudeInstructions -Raw
  if (-not $claudeText.Contains("Existing guidance`r`n")) { throw "User content or its line endings were not preserved." }
  Assert-Absent (Join-Path $global ".copilot\copilot-instructions.md"), (Join-Path $env:KIRO_HOME "steering\solid-tdd-craft.md"), (Join-Path $xdgOpencode "AGENTS.md")
  Assert-Absent (Join-Path $global ".claude\commands\review.md"), (Join-Path $env:KIRO_HOME "steering\kiro-review.md")
  Assert-Present (Join-Path $xdgOpencode "commands\review.md")
  & $uninstaller -Scope Global -HomePath $global
  Assert-Present $claudeInstructions, (Join-Path $global ".claude\skills\my-own-skill\SKILL.md")

  # Project scope with a pre-existing empty AGENTS.md and unrelated files.
  $project = Join-Path $homePath "project [fixture] with spaces"
  New-Item -ItemType Directory -Force -Path (Join-Path $project ".github") | Out-Null
  [System.IO.File]::WriteAllText((Join-Path $project "AGENTS.md"), "")
  [System.IO.File]::WriteAllText((Join-Path $project ".github\copilot-instructions.md"), "Team rules`n")
  [System.IO.File]::WriteAllText((Join-Path $project "notes.txt"), "keep me")
  & $installer -Target $project
  & $uninstaller -Target $project
  foreach ($root in @(".claude\skills", ".github\skills", ".kiro\skills", ".hermes\skills", ".opencode\skills")) {
    Assert-NoSkills (Join-Path $project $root)
    Assert-Absent (Join-Path $project $root)
  }
  Assert-Present (Join-Path $project "AGENTS.md"), (Join-Path $project "notes.txt"), (Join-Path $project ".github\copilot-instructions.md")
  if ((Get-Item -LiteralPath (Join-Path $project "AGENTS.md")).Length -ne 0) { throw "AGENTS.md should be empty again." }
  if ((Get-Content -LiteralPath (Join-Path $project ".github\copilot-instructions.md") -Raw).Trim() -ne "Team rules") { throw "Team rules were not preserved." }
  Assert-Absent (Join-Path $project "CLAUDE.md"), (Join-Path $project ".kiro\steering\craft.md"), (Join-Path $project ".claude\commands\review.md"), (Join-Path $project ".github\prompts\review.prompt.md"), (Join-Path $project ".opencode\commands\review.md"), (Join-Path $project ".kiro\steering\kiro-review.md")

  # Current-directory default.
  $current = Join-Path $homePath "current project"
  New-Item -ItemType Directory -Path $current | Out-Null
  & $installer -Target $current
  Push-Location -LiteralPath $current
  try { & $uninstaller } finally { Pop-Location }
  Assert-Absent (Join-Path $current "CLAUDE.md"), (Join-Path $current ".claude\skills")

  # Harness selection.
  $selected = Join-Path $homePath "selected project"
  & $installer -Target $selected
  & $uninstaller -Target $selected -Harness kiro
  Assert-Absent (Join-Path $selected ".kiro\skills"), (Join-Path $selected ".kiro\steering\craft.md"), (Join-Path $selected ".kiro\steering\kiro-review.md")
  Assert-Present (Join-Path $selected ".claude\skills\solid-tdd-craft\SKILL.md"), (Join-Path $selected "CLAUDE.md"), (Join-Path $selected ".github\copilot-instructions.md"), (Join-Path $selected ".hermes\skills\solid-tdd-craft\SKILL.md"), (Join-Path $selected "AGENTS.md")
  & $uninstaller -Target $selected -Harness claude, hermes
  Assert-Absent (Join-Path $selected ".claude\skills"), (Join-Path $selected "CLAUDE.md"), (Join-Path $selected ".hermes\skills")
  Assert-Present (Join-Path $selected ".github\skills\solid-tdd-craft\SKILL.md"), (Join-Path $selected "AGENTS.md")
  & $uninstaller -Target $selected -Harness copilot, opencode
  Assert-Absent (Join-Path $selected ".github\skills"), (Join-Path $selected ".github\copilot-instructions.md"), (Join-Path $selected "AGENTS.md"), (Join-Path $selected ".opencode\skills")

  & $installer -Scope Global -HomePath $global
  & $uninstaller -Scope Global -HomePath $global -Harness opencode
  Assert-Absent (Join-Path $xdgOpencode "skills"), (Join-Path $xdgOpencode "AGENTS.md")
  Assert-Present (Join-Path $global ".copilot\skills\solid-tdd-craft\SKILL.md"), (Join-Path $env:KIRO_HOME "skills\solid-tdd-craft\SKILL.md"), (Join-Path $env:HERMES_HOME "skills\solid-tdd-craft\SKILL.md")
  & $uninstaller -Scope Global -HomePath $global
  Assert-Absent (Join-Path $global ".copilot\skills"), (Join-Path $env:KIRO_HOME "skills")

  Write-Host "Uninstaller tests passed."
}
finally {
  if ($null -eq $originalXdgConfigHome) { Remove-Item Env:XDG_CONFIG_HOME -ErrorAction SilentlyContinue } else { $env:XDG_CONFIG_HOME = $originalXdgConfigHome }
  if ($null -eq $originalKiroHome) { Remove-Item Env:KIRO_HOME -ErrorAction SilentlyContinue } else { $env:KIRO_HOME = $originalKiroHome }
  if ($null -eq $originalHermesHome) { Remove-Item Env:HERMES_HOME -ErrorAction SilentlyContinue } else { $env:HERMES_HOME = $originalHermesHome }
  if (Test-Path $homePath) { Remove-Item -LiteralPath $homePath -Recurse -Force }
}
