# Ensure all submodules are currently checked out to the latest commit/tag.
git submodule update --init --recursive
git submodule foreach git rm --cached -r .

Get-ChildItem ./ext -Directory | ForEach-Object {
    $path = $_.FullName
    
    Write-Host "Processing submodule: $path"

    # Fetch tags and check out the latest tag
    git -C "$path" fetch --tags

    # Get all tags, sort them alphabetically, and select the highest one
    $highestTag = (git -C "$path" tag | Sort-Object -Descending)[0] | Out-String
    $highestTag = $highestTag.Trim()
    Write-Host "$path => $highestTag"

    # Checkout the latest tag
    git -C "$path" reset --hard "$highestTag"

    # Forcefully clean the submodule directory, suppressing any prompts
    git -C "$path" clean -fdx -q
}


# Ensure deterministic builds do not affect submodule build
# TODO: Remove first two values once all projects are updated to latest build props.
$env:CI = $false
$env:GITHUB_ACTIONS = $false

$env:SIXLABORS_TESTING = $true

docfx