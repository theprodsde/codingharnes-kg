[CmdletBinding()]
param(
  [ValidateSet("Project", "Global")]
  [string]$Scope = "Project",
  [ValidateNotNullOrEmpty()]
  [string]$Target = ".",
  [ValidateNotNullOrEmpty()]
  [string]$HomePath = $HOME
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
  $skillRoots = @(
    (Join-Path $HomePath ".claude\skills"),
    (Join-Path $HomePath ".copilot\skills"),
    (Join-Path $kiroHome "skills"),
    (Join-Path $hermesHome "skills"),
    (Join-Path $opencodeHome "skills")
  )
  $instructionPaths = @(
    (Join-Path $HomePath ".claude\CLAUDE.md"),
    (Join-Path $HomePath ".copilot\copilot-instructions.md"),
    (Join-Path $kiroHome "steering\solid-tdd-craft.md"),
    (Join-Path $opencodeHome "AGENTS.md")
  )
  foreach ($root in $skillRoots) { Copy-Skills $root }
  Add-Line $instructionPaths[0] "# User Instructions"
  Add-Line $instructionPaths[1] "# Copilot User Instructions"
  Add-Line $instructionPaths[2] "---`ninclusion: always`n---`n# Engineering Craft"
  Add-Line $instructionPaths[3] "# Global Agent Instructions"
  Copy-Command "claude-review.md" (Join-Path $HomePath ".claude\commands\review.md")
  Copy-Command "opencode-review.md" (Join-Path $opencodeHome "commands\review.md")
  Copy-Command "kiro-review.md" (Join-Path $kiroHome "steering\kiro-review.md")
} else {
  $skillRoots = @(
    (Join-Path $Target ".claude\skills"),
    (Join-Path $Target ".github\skills"),
    (Join-Path $Target ".kiro\skills"),
    (Join-Path $Target ".hermes\skills"),
    (Join-Path $Target ".opencode\skills")
  )
  foreach ($root in $skillRoots) { Copy-Skills $root }
  Add-Line (Join-Path $Target "CLAUDE.md") "# Project Instructions"
  Add-Line (Join-Path $Target ".github\copilot-instructions.md") "# Copilot Instructions"
  Add-Line (Join-Path $Target ".kiro\steering\craft.md") "---`ninclusion: always`n---`n# Engineering Craft"
  Add-Line (Join-Path $Target "AGENTS.md") "# Agent Instructions"
  Copy-Command "claude-review.md" (Join-Path $Target ".claude\commands\review.md")
  Copy-Command "copilot-review.prompt.md" (Join-Path $Target ".github\prompts\review.prompt.md")
  Copy-Command "opencode-review.md" (Join-Path $Target ".opencode\commands\review.md")
  Copy-Command "kiro-review.md" (Join-Path $Target ".kiro\steering\kiro-review.md")
}
