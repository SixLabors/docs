# SixLabors API docs site

## Prerequisites 
latest [docfx](https://dotnet.github.io/docfx/) version needs to be installed. *[This can be installed via chocolatey](https://dotnet.github.io/docfx/tutorial/docfx_getting_started.html#2-use-docfx-as-a-command-line-tool)*

## Make it work
### How to update
To pull in the latest source of a project you have to navigate into the `ext` folder and checkout the required revision (by default these should always be pointing to the latest tagged full release)

### How build
run `docfx` from the command line. This will regenerate the site in the `docs` folder.

### How to preview
run `docfx --serve` this rebuilds the site but also runs a dev server at [http://localhost:8080](http://localhost:8080) so you can preview the current state of the docs.

### Updating the docs

to be confirmed