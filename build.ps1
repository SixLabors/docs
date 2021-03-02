# Ensure all submodules are currently checked out to the latest tag.
git submodule update --init --recursive
Get-ChildItem ./ext -Directory | ForEach-Object {
    $path = $_.FullName

    git -C "$path" fetch --tags
    $lastTag = (git -C "$path" describe --tags $(git -C "$path" rev-list --tags --max-count=1))  | Out-String
    $lastTag = $lastTag.Trim()

    Write-Host "$path => $lastTag"
    git -C "$path" reset --hard "$lastTag" --
    git submodule update --init --recursive
}

# Ensure deterministic builds do not affect submodule build
# TODO: Remove first two values once all projects are updated to latest build props.
$env:CI = $false
$env:GITHUB_ACTIONS = $false

$env:SIXLABORS_TESTING = $true

# https://github.com/dotnet/docfx/issues/1890#issuecomment-316258540
docfx metadata
docfx