# Ensure all submodules are checked out, but do not look for latest tags. (Useful for docs development.)
git submodule update --init

Get-ChildItem ./ext -Directory | ForEach-Object {
    $path = $_.FullName
    git -C "$path" fetch
}

docfx