# Ensure all submodules are checked out with the latest master. (Useful for docs development.)
git submodule update --init --recursive

# Enable the following lines should there be any issues.
# git submodule foreach git rm --cached -r .
# git submodule foreach git reset --hard origin/master

git submodule foreach git pull -f origin master --recurse-submodules

# Ensure deterministic builds do not affect submodule build
# TODO: Remove first two values once all projects are updated to latest build props.
$env:CI = $false
$env:GITHUB_ACTIONS = $false

$env:SIXLABORS_TESTING = $true

docfx