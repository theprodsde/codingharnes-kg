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
$knownLines = New-Object 'System.Collections.Generic.HashSet[string]'
foreach ($line in $workflowLines) {
  $bare = $line.TrimEnd("`r")
  if ($bare.Trim().Length -gt 0) { [void]$knownLines.Add($bare) }
}
$skillNames = @(Get-ChildItem -LiteralPath (Join-Path $src "skills") -Directory | ForEach-Object { $_.Name })

function Test-Harness([string]$Name) {
  return ($Harness.Count -eq 0 -or $Harness -contains $Name)
}

# Removes only the skill folders this repository ships, then the skills folder if it is empty.
function Remove-Skills([string]$SkillsRoot) {
  foreach ($name in $skillNames) {
    $path = Join-Path $SkillsRoot $name
    if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
  }
  if ((Test-Path -LiteralPath $SkillsRoot) -and -not (Get-ChildItem -LiteralPath $SkillsRoot -Force | Select-Object -First 1)) {
    Remove-Item -LiteralPath $SkillsRoot -Force
  }
  Write-Host "Skills <- $SkillsRoot"
}

# Reverses Add-Line: drops each workflow line (and the blank line the installer put before it).
# Deletes the file when only the installer's header remains; otherwise keeps the rest untouched.
function Remove-Lines([string]$Path, [string]$Header) {
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Write-Host "Always-on (not found) -> $Path"; return }
  $content = [System.IO.File]::ReadAllText($Path)
  $kept = New-Object 'System.Collections.Generic.List[string]'
  $held = $null
  $changed = $false
  foreach ($chunk in [regex]::Split($content, '(?<=\n)')) {
    if ($chunk.Length -eq 0) { continue }
    $bare = $chunk.TrimEnd("`r", "`n")
    if ($bare.Length -eq 0) {
      if ($null -ne $held) { $kept.Add($held) }
      $held = $chunk
    } elseif ($knownLines.Contains($bare)) {
      $held = $null
      $changed = $true
    } else {
      if ($null -ne $held) { $kept.Add($held); $held = $null }
      $kept.Add($chunk)
    }
  }
  if ($null -ne $held) { $kept.Add($held) }
  if (-not $changed) { Write-Host "Always-on (unchanged) -> $Path"; return }

  $result = -join $kept
  $remaining = @($result -split "`r?`n" | Where-Object { $_.Trim().Length -gt 0 })
  $expected = @($Header -split "`n" | Where-Object { $_.Trim().Length -gt 0 })
  if (($remaining -join "`n") -ceq ($expected -join "`n")) {
    Remove-Item -LiteralPath $Path -Force
    Write-Host "Always-on removed -> $Path"
  } else {
    [System.IO.File]::WriteAllText($Path, $result, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "Always-on cleaned -> $Path"
  }
}

# Removes a review command only when it still matches the shipped copy.
function Remove-Command([string]$SourceName, [string]$Destination) {
  if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) { Write-Host "Command (not found) -> $Destination"; return }
  $shipped = Join-Path $src "commands\$SourceName"
  if ((Get-FileHash -LiteralPath $shipped).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash) {
    Remove-Item -LiteralPath $Destination -Force
    Write-Host "Command removed -> $Destination"
  } else {
    Write-Host "Command kept (modified) -> $Destination"
  }
}

if ($Scope -eq "Global") {
  if (Test-Harness "claude") {
    Remove-Skills (Join-Path $HomePath ".claude\skills")
    Remove-Lines (Join-Path $HomePath ".claude\CLAUDE.md") "# User Instructions"
    Remove-Command "claude-review.md" (Join-Path $HomePath ".claude\commands\review.md")
  }
  if (Test-Harness "copilot") {
    Remove-Skills (Join-Path $HomePath ".copilot\skills")
    Remove-Lines (Join-Path $HomePath ".copilot\copilot-instructions.md") "# Copilot User Instructions"
  }
  if (Test-Harness "kiro") {
    Remove-Skills (Join-Path $kiroHome "skills")
    Remove-Lines (Join-Path $kiroHome "steering\solid-tdd-craft.md") "---`ninclusion: always`n---`n# Engineering Craft"
    Remove-Command "kiro-review.md" (Join-Path $kiroHome "steering\kiro-review.md")
  }
  if (Test-Harness "hermes") {
    Remove-Skills (Join-Path $hermesHome "skills")
  }
  if (Test-Harness "opencode") {
    Remove-Skills (Join-Path $opencodeHome "skills")
    Remove-Lines (Join-Path $opencodeHome "AGENTS.md") "# Global Agent Instructions"
    Remove-Command "opencode-review.md" (Join-Path $opencodeHome "commands\review.md")
  }
} else {
  if (Test-Harness "claude") {
    Remove-Skills (Join-Path $Target ".claude\skills")
    Remove-Lines (Join-Path $Target "CLAUDE.md") "# Project Instructions"
    Remove-Command "claude-review.md" (Join-Path $Target ".claude\commands\review.md")
  }
  if (Test-Harness "copilot") {
    Remove-Skills (Join-Path $Target ".github\skills")
    Remove-Lines (Join-Path $Target ".github\copilot-instructions.md") "# Copilot Instructions"
    Remove-Command "copilot-review.prompt.md" (Join-Path $Target ".github\prompts\review.prompt.md")
  }
  if (Test-Harness "kiro") {
    Remove-Skills (Join-Path $Target ".kiro\skills")
    Remove-Lines (Join-Path $Target ".kiro\steering\craft.md") "---`ninclusion: always`n---`n# Engineering Craft"
    Remove-Command "kiro-review.md" (Join-Path $Target ".kiro\steering\kiro-review.md")
  }
  if (Test-Harness "hermes") {
    Remove-Skills (Join-Path $Target ".hermes\skills")
  }
  if (Test-Harness "opencode") {
    Remove-Skills (Join-Path $Target ".opencode\skills")
    Remove-Lines (Join-Path $Target "AGENTS.md") "# Agent Instructions"
    Remove-Command "opencode-review.md" (Join-Path $Target ".opencode\commands\review.md")
  }
}
