# ensure all submodules are currently checked out to the latest tag
git submodule update --init
Get-ChildItem ./ext -Directory | ForEach-Object {
    $path = $_.FullName

    git -C "$path" fetch
    $lastTag = (git -C "$path" describe --abbrev=0 --tags )  | Out-String
    $lastTag = $lastTag.Trim()

    Write-Host "$path => $lastTag"
    git -C "$path" reset --hard "$lastTag" --
}

docfx