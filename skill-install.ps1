[CmdletBinding()]
param(
  [ValidateSet("Project", "Global")]
  [string]$Scope = "Project",
  [ValidateNotNullOrEmpty()]
  [string]$Target = ".",
  [ValidateNotNullOrEmpty()]
  [string]$HomePath = $HOME,
  [ValidateSet("claude", "copilot", "kiro", "opencode", "hermes")]
  [string[]]$Harness = @()
)

$ErrorActionPreference = "Stop"
$src = $PSScriptRoot

function Test-AbsolutePath([string]$Path) {
  if ([System.IO.Path]::DirectorySeparatorChar -eq '/') {
    return [System.IO.Path]::IsPathRooted($Path)
  }
  return ($Path -match '^[A-Za-z]:[\\/]' -or $Path -match '^(\\\\|//)[^\\/]+[\\/][^\\/]+')
}

if ($Scope -eq "Global") {
  if ($PSBoundParameters.ContainsKey("Target")) { throw "Global scope does not accept a project Target." }
  if (-not (Test-AbsolutePath $HomePath)) { throw "HomePath must be an absolute path." }
  $kiroHome = if ($env:KIRO_HOME) { $env:KIRO_HOME } else { Join-Path $HomePath ".kiro" }
  $hermesHome = if ($env:HERMES_HOME) { $env:HERMES_HOME } else { Join-Path $HomePath ".hermes" }
  $configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HomePath ".config" }
  foreach ($entry in @(@("KIRO_HOME", $kiroHome), @("HERMES_HOME", $hermesHome), @("XDG_CONFIG_HOME", $configHome))) {
    if (-not (Test-AbsolutePath $entry[1])) { throw "$($entry[0]) must be an absolute path when set." }
  }
  $opencodeHome = Join-Path $configHome "opencode"
} else {
  $Target = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Target)
}

$workflowLines = @(Get-Content -LiteralPath (Join-Path $src "skills\solid-tdd-craft\references\WORKFLOW.md"))
if (-not ($workflowLines -match '\S')) { throw "Required engineering workflow is empty." }

function Test-Harness([string]$Name) {
  return ($Harness.Count -eq 0 -or $Harness -contains $Name)
}

function Copy-Skills([string]$SkillsRoot) {
  New-Item -ItemType Directory -Force -Path $SkillsRoot | Out-Null
  Get-ChildItem -LiteralPath (Join-Path $src "skills") | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $SkillsRoot -Recurse -Force
  }
  Write-Host "Skills -> $SkillsRoot"
}

function Add-Line([string]$Path, [string]$Header) {
  New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
  if (-not (Test-Path -LiteralPath $Path)) {
    [System.IO.File]::WriteAllText($Path, "$Header`n", (New-Object System.Text.UTF8Encoding($false)))
  }
  $content = Get-Content -LiteralPath $Path -Raw
  foreach ($line in $workflowLines) {
    if ($line.Trim().Length -eq 0) { continue }
    if ($null -eq $content -or -not $content.Contains($line)) { Add-Content -LiteralPath $Path -Value "`n$line" }
  }
  Write-Host "Always-on -> $Path"
}

function Copy-Command([string]$SourceName, [string]$Destination) {
  New-Item -ItemType Directory -Force -Path (Split-Path $Destination) | Out-Null
  Copy-Item -LiteralPath (Join-Path $src "commands\$SourceName") -Destination $Destination -Force
  Write-Host "Command -> $Destination"
}

if ($Scope -eq "Global") {
  if (Test-Harness "claude") {
    Copy-Skills (Join-Path $HomePath ".claude\skills")
    Add-Line (Join-Path $HomePath ".claude\CLAUDE.md") "# User Instructions"
    Copy-Command "claude-review.md" (Join-Path $HomePath ".claude\commands\review.md")
  }
  if (Test-Harness "copilot") {
    Copy-Skills (Join-Path $HomePath ".copilot\skills")
    Add-Line (Join-Path $HomePath ".copilot\copilot-instructions.md") "# Copilot User Instructions"
  }
  if (Test-Harness "kiro") {
    Copy-Skills (Join-Path $kiroHome "skills")
    Add-Line (Join-Path $kiroHome "steering\solid-tdd-craft.md") "---`ninclusion: always`n---`n# Engineering Craft"
    Copy-Command "kiro-review.md" (Join-Path $kiroHome "steering\kiro-review.md")
  }
  if (Test-Harness "hermes") {
    Copy-Skills (Join-Path $hermesHome "skills")
  }
  if (Test-Harness "opencode") {
    Copy-Skills (Join-Path $opencodeHome "skills")
    Add-Line (Join-Path $opencodeHome "AGENTS.md") "# Global Agent Instructions"
    Copy-Command "opencode-review.md" (Join-Path $opencodeHome "commands\review.md")
  }
} else {
  if (Test-Harness "claude") {
    Copy-Skills (Join-Path $Target ".claude\skills")
    Add-Line (Join-Path $Target "CLAUDE.md") "# Project Instructions"
    Copy-Command "claude-review.md" (Join-Path $Target ".claude\commands\review.md")
  }
  if (Test-Harness "copilot") {
    Copy-Skills (Join-Path $Target ".github\skills")
    Add-Line (Join-Path $Target ".github\copilot-instructions.md") "# Copilot Instructions"
    Copy-Command "copilot-review.prompt.md" (Join-Path $Target ".github\prompts\review.prompt.md")
  }
  if (Test-Harness "kiro") {
    Copy-Skills (Join-Path $Target ".kiro\skills")
    Add-Line (Join-Path $Target ".kiro\steering\craft.md") "---`ninclusion: always`n---`n# Engineering Craft"
    Copy-Command "kiro-review.md" (Join-Path $Target ".kiro\steering\kiro-review.md")
  }
  if (Test-Harness "hermes") {
    Copy-Skills (Join-Path $Target ".hermes\skills")
  }
  if (Test-Harness "opencode") {
    Copy-Skills (Join-Path $Target ".opencode\skills")
    Add-Line (Join-Path $Target "AGENTS.md") "# Agent Instructions"
    Copy-Command "opencode-review.md" (Join-Path $Target ".opencode\commands\review.md")
  }
}