function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath,

        [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    & git -C $RepositoryPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed in $RepositoryPath"
    }
}

# Ensure all submodules are initialized, including nested submodules used by dependencies.
Invoke-Git $PSScriptRoot submodule sync --recursive
Invoke-Git $PSScriptRoot submodule foreach --recursive git reset --hard
Invoke-Git $PSScriptRoot submodule foreach --recursive git clean -ffdx
Invoke-Git $PSScriptRoot submodule update --init --recursive

# Ensure all top-level dependency submodules are checked out to the latest remote commit
# without leaving stale untracked files from previous checkouts behind.
Get-ChildItem (Join-Path $PSScriptRoot 'ext') -Directory | ForEach-Object {
    $path = $_.FullName

    Write-Host "Updating submodule: $path"

    Invoke-Git $path fetch origin --tags --prune

    $defaultRef = (& git -C $path symbolic-ref refs/remotes/origin/HEAD).Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to determine the default branch for $path"
    }

    $defaultBranch = $defaultRef -replace '^refs/remotes/origin/', ''

    # Clean before and after the reset so older generated files cannot survive a branch move.
    Invoke-Git $path clean -ffdx
    Invoke-Git $path reset --hard "origin/$defaultBranch"
    Invoke-Git $path clean -ffdx

    # Bring nested submodules to the commits referenced by the updated parent checkout,
    # then clean their working trees too.
    Invoke-Git $path submodule sync --recursive
    Invoke-Git $path submodule update --init --recursive
    Invoke-Git $path submodule foreach --recursive git reset --hard
    Invoke-Git $path submodule foreach --recursive git clean -ffdx
    Invoke-Git $path submodule update --init --recursive
}

# Ensure deterministic builds do not affect submodule build
# TODO: Remove first two values once all projects are updated to latest build props.
$env:CI = $false
$env:GITHUB_ACTIONS = $false

$env:SIXLABORS_TESTING = $true

docfx
