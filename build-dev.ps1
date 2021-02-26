# Ensure all submodules are checked out with the latest master. (Useful for docs development.)
git submodule update --init --recursive
git submodule foreach git pull origin master --recurse-submodules

# Ensure deterministic builds do not affect submodule build
# TODO: Remove this once all projects are updated to latest build props.
$env:CI = $false

docfx