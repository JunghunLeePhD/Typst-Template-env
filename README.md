# Typst Template Environment

This repository builds the Docker image used for my Typst projects. It includes:
- **Typst CLI**: Latest version
- **Fonts**: `fonts-nanum` (Korean), `fonts-noto-cjk`, and system fonts.
- **Tools**: `make`, `git`.

## How to use in other Repositories

In your math project's `.devcontainer/devcontainer.json`, use:

```json
{
  "name": "Typst Math Project",
  "image": "ghcr.io/junghunleephd/typst-template-env:latest",
  "customizations": {
    "vscode": {
      "extensions": ["myriad-dreamers.tinymist"]
    }
  }
}