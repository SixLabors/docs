# SixLabors API docs site

## Prerequisites 
latest [docfx](https://dotnet.github.io/docfx/) version needs to be installed. *[This can be installed via chocolatey](https://dotnet.github.io/docfx/tutorial/docfx_getting_started.html#2-use-docfx-as-a-command-line-tool)*

## Make it work

### How do I build the latest tagged docs
run `build.cmd`/`build.ps1` from the command line. This will checkout that latest tagged commits for each of the repositories and regenerate the site in the `docs` folder.

### How do I build the latest nightly docs
run `build-dev.cmd`/`build-dev.ps1` from the command line. This will checkout that latest commits for each of the repositories and regenerate the site in the `docs` folder.

### How to preview
run `serve.cmd`/`serve.ps1` this rebuilds the site but also runs a dev server at [http://localhost:8080](http://localhost:8080) so you can preview the current state of the docs.

### Updating the docs
To make changes make sure you rebuild (run `build.cmd`) before committing. *TODO: automate this as a build step.*