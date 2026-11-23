$ErrorActionPreference = "Stop"
$installer = Join-Path $PSScriptRoot "..\skill-install.ps1"
$homePath = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
$originalKiroHome = $env:KIRO_HOME
$originalHermesHome = $env:HERMES_HOME
$originalXdgConfigHome = $env:XDG_CONFIG_HOME

function Assert-Exists([string]$Path) {
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Expected path to exist: $Path"
  }
}

function Assert-Contains([string]$Path, [string]$Text) {
  $content = Get-Content -LiteralPath $Path -Raw
  if (-not $content.Contains($Text)) {
    throw "Expected '$Path' to contain '$Text'."
  }
}

function Assert-Workflow([string]$Path) {
  foreach ($text in @("## Required engineering workflow", "stop before code changes", "Acceptance criteria", "not verified", "Do not weaken")) {
    Assert-Contains $Path $text
  }
  $count = (Select-String -LiteralPath $Path -SimpleMatch "## Required engineering workflow" | Measure-Object).Count
  if ($count -ne 1) { throw "Expected exactly one engineering workflow in $Path" }
}

function Assert-SkillSet([string]$SkillsRoot) {
  foreach ($skill in @("solid-tdd-craft", "tdd-workflow", "solid-design", "clean-code", "code-review", "security-review", "production-readiness", "deployment", "microservices-architecture", "monolithic-architecture", "frontend-development", "backend-development", "database-production", "api-contracts", "authentication-authorization", "dependency-supply-chain", "configuration-secrets", "observability-recovery", "data-privacy-retention")) {
    $skillFile = Join-Path $SkillsRoot "$skill\SKILL.md"
    Assert-Exists $skillFile
    if ((Get-Content -LiteralPath $skillFile -Raw) -notmatch "(?m)^name: $([regex]::Escape($skill))\r?$") {
      throw "Skill ID does not match its directory: $skillFile"
    }
  }
  Assert-Exists (Join-Path $SkillsRoot "solid-tdd-craft\references\CHECKLIST.md")
  Assert-Exists (Join-Path $SkillsRoot "solid-tdd-craft\references\WORKFLOW.md")
}

try {
  $project = Join-Path $homePath "project [fixture] with spaces"
  New-Item -ItemType Directory -Force -Path $project | Out-Null
  [System.IO.File]::WriteAllText((Join-Path $project "AGENTS.md"), "")
  & $installer -Target $project
  & $installer -Target $project
  foreach ($path in @("AGENTS.md", "CLAUDE.md", ".github\copilot-instructions.md", ".kiro\steering\craft.md")) {
    Assert-Workflow (Join-Path $project $path)
  }
  Assert-Contains (Join-Path $project "AGENTS.md") "solid-tdd-craft"
  Assert-SkillSet (Join-Path $project ".claude\skills")
  Assert-SkillSet (Join-Path $project ".github\skills")
  Assert-SkillSet (Join-Path $project ".kiro\skills")
  Assert-SkillSet (Join-Path $project ".opencode\skills")
  Assert-SkillSet (Join-Path $project ".hermes\skills")
  Assert-Exists (Join-Path $project ".github\copilot-instructions.md")
  Assert-Exists (Join-Path $project ".claude\commands\review.md")

  $currentProject = Join-Path $homePath "current project"
  New-Item -ItemType Directory -Path $currentProject | Out-Null
  $processDirectory = [Environment]::CurrentDirectory
  Push-Location -LiteralPath $currentProject
  try {
    [Environment]::CurrentDirectory = $homePath
    & $installer
    Assert-Contains (Join-Path $currentProject "AGENTS.md") "solid-tdd-craft"
    Assert-SkillSet (Join-Path $currentProject ".github\skills")
    if (Test-Path -LiteralPath (Join-Path $homePath "CLAUDE.md")) {
      throw "Instructions must be written in the PowerShell location, not the process directory."
    }
  } finally {
    [Environment]::CurrentDirectory = $processDirectory
    Pop-Location
  }

  $global = Join-Path $homePath "user home"
  $env:XDG_CONFIG_HOME = Join-Path $global "custom config"
  $env:HERMES_HOME = Join-Path $global ".hermes-profile"
  $env:KIRO_HOME = "relative-kiro-home"
  $rejectedRelativeKiroHome = $false
  try {
    & $installer -Scope Global -HomePath $global
  } catch {
    $rejectedRelativeKiroHome = $_.Exception.Message.Contains("absolute path")
  }
  if (-not $rejectedRelativeKiroHome) {
    throw "Expected a relative KIRO_HOME to be rejected."
  }

  $env:KIRO_HOME = Join-Path $global ".kiro"
  $env:HERMES_HOME = "relative-hermes-home"
  $rejectedRelativeHermesHome = $false
  try {
    & $installer -Scope Global -HomePath $global
  } catch {
    $rejectedRelativeHermesHome = $_.Exception.Message.Contains("HERMES_HOME must be an absolute path")
  }
  if (-not $rejectedRelativeHermesHome) {
    throw "Expected a relative HERMES_HOME to be rejected."
  }

  $env:HERMES_HOME = "C:relative-hermes-home"
  $rejectedDriveRelativeHermesHome = $false
  try {
    & $installer -Scope Global -HomePath $global
  } catch {
    $rejectedDriveRelativeHermesHome = $_.Exception.Message.Contains("HERMES_HOME must be an absolute path")
  }
  if (-not $rejectedDriveRelativeHermesHome) {
    throw "Expected a drive-relative HERMES_HOME to be rejected."
  }
  if (Test-Path -LiteralPath $global) { throw "Invalid configuration must be rejected before writing files." }

  $env:KIRO_HOME = Join-Path $global ".kiro"
  $env:HERMES_HOME = Join-Path $global ".hermes-profile"
  $claudeInstructions = Join-Path $global ".claude\CLAUDE.md"
  New-Item -ItemType Directory -Force -Path (Split-Path $claudeInstructions) | Out-Null
  $line = "For any code change, follow the ``solid-tdd-craft`` skill and its companion skills; its Restrictions are mandatory."
  [System.IO.File]::WriteAllText($claudeInstructions, "Existing personal guidance`r`n$line`r`n")

  & $installer -Scope Global -HomePath $global
  Assert-SkillSet (Join-Path $global ".claude\skills")
  Assert-SkillSet (Join-Path $global ".copilot\skills")
  Assert-SkillSet (Join-Path $global ".kiro\skills")
  Assert-SkillSet (Join-Path $env:XDG_CONFIG_HOME "opencode\skills")
  Assert-SkillSet (Join-Path $global ".hermes-profile\skills")
  Assert-Contains $claudeInstructions "Existing personal guidance"
  Assert-Contains $claudeInstructions "solid-tdd-craft"
  Assert-Exists (Join-Path $global ".copilot\copilot-instructions.md")
  Assert-Exists (Join-Path $global ".kiro\steering\solid-tdd-craft.md")
  Assert-Exists (Join-Path $env:XDG_CONFIG_HOME "opencode\AGENTS.md")
  Assert-Exists (Join-Path $env:XDG_CONFIG_HOME "opencode\commands\review.md")

  & $installer -Scope Global -HomePath $global
  $instructionCount = (Select-String -Path $claudeInstructions -SimpleMatch "solid-tdd-craft" | Measure-Object).Count
  if ($instructionCount -ne 1) {
    throw "Expected a single global instruction entry after repeated installation."
  }
  foreach ($path in @($claudeInstructions, (Join-Path $global ".copilot\copilot-instructions.md"), (Join-Path $global ".kiro\steering\solid-tdd-craft.md"), (Join-Path $env:XDG_CONFIG_HOME "opencode\AGENTS.md"))) {
    Assert-Workflow $path
  }

  $env:XDG_CONFIG_HOME = "relative-config"
  $rejectedRelativeConfig = $false
  try {
    & $installer -Scope Global -HomePath $global
  } catch {
    $rejectedRelativeConfig = $_.Exception.Message.Contains("XDG_CONFIG_HOME must be an absolute path")
  }
  if (-not $rejectedRelativeConfig) { throw "Expected a relative XDG_CONFIG_HOME to be rejected." }

  Remove-Item Env:KIRO_HOME, Env:HERMES_HOME, Env:XDG_CONFIG_HOME -ErrorAction SilentlyContinue
  & $installer -Scope Global -HomePath (Join-Path $homePath "defaults")
  Assert-SkillSet (Join-Path $homePath "defaults\.config\opencode\skills")
  Assert-SkillSet (Join-Path $homePath "defaults\.kiro\skills")
  Assert-SkillSet (Join-Path $homePath "defaults\.hermes\skills")

  # Harness selection: only the named harnesses are installed; no selection installs all.
  $selected = Join-Path $homePath "selected project"
  New-Item -ItemType Directory -Force -Path $selected | Out-Null
  & $installer -Target $selected -Harness kiro
  Assert-SkillSet (Join-Path $selected ".kiro\skills")
  Assert-Exists (Join-Path $selected ".kiro\steering\craft.md")
  foreach ($name in @(".claude", ".github", ".hermes", ".opencode", "CLAUDE.md", "AGENTS.md")) {
    if (Test-Path -LiteralPath (Join-Path $selected $name)) { throw "Unexpected $name after selecting kiro." }
  }
  & $installer -Target $selected -Harness claude, hermes
  Assert-SkillSet (Join-Path $selected ".claude\skills")
  Assert-SkillSet (Join-Path $selected ".hermes\skills")
  Assert-Exists (Join-Path $selected "CLAUDE.md")
  if (Test-Path -LiteralPath (Join-Path $selected ".github")) { throw "Unexpected .github after selecting claude and hermes." }

  $selectedHome = Join-Path $homePath "selected-home"
  & $installer -Scope Global -HomePath $selectedHome -Harness copilot
  Assert-SkillSet (Join-Path $selectedHome ".copilot\skills")
  foreach ($name in @(".claude", ".kiro", ".hermes", ".config")) {
    if (Test-Path -LiteralPath (Join-Path $selectedHome $name)) { throw "Unexpected $name after selecting copilot." }
  }

  $rejectedHarness = $false
  try { & $installer -Target (Join-Path $homePath "bad-harness") -Harness bogus } catch { $rejectedHarness = $true }
  if (-not $rejectedHarness) { throw "Expected an unknown harness to be rejected." }
  if (Test-Path -LiteralPath (Join-Path $homePath "bad-harness")) { throw "Rejected harness must not write files." }

  Write-Host "Installer tests passed."
}
finally {
  if ($null -eq $originalXdgConfigHome) {
    Remove-Item Env:XDG_CONFIG_HOME -ErrorAction SilentlyContinue
  } else {
    $env:XDG_CONFIG_HOME = $originalXdgConfigHome
  }
  if ($null -eq $originalKiroHome) {
    Remove-Item Env:KIRO_HOME -ErrorAction SilentlyContinue
  } else {
    $env:KIRO_HOME = $originalKiroHome
  }
  if ($null -eq $originalHermesHome) {
    Remove-Item Env:HERMES_HOME -ErrorAction SilentlyContinue
  } else {
    $env:HERMES_HOME = $originalHermesHome
  }
  if (Test-Path $homePath) {
    Remove-Item -LiteralPath $homePath -Recurse -Force
  }
}
