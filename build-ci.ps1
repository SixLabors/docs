# Ensure deterministic builds do not affect submodule build
# TODO: Remove first two values once all projects are updated to latest build props.
$env:CI = $false
$env:GITHUB_ACTIONS = $false

$env:SIXLABORS_TESTING = $true

docfx