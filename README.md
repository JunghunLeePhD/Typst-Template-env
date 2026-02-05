# Typst Environment Docker Image

This repository hosts the **Dockerfile** and build configuration for my standardized Typst development environment.

It automatically builds and publishes a public Docker image to the **GitHub Container Registry (GHCR)** whenever changes are pushed to `main`.
This image is designed to be consumed by my private Typst projects to ensure a consistent, zero-configuration, and offline-capable environment.

## 📦 Image Details

- **Registry:** `ghcr.io`
- **Image Name:** `ghcr.io/junghunleephd/typst-template-env:main`
- **Base:** Debian Bookworm Slim

### Included Tools
The image is optimized for modern mathematical writing and offline usage:
- **Core:** `typst` (CLI Compiler), `git`, `make`, `curl`, `unzip`, `openssh-client`
- **Formatting:** `typstyle` (Opinionated formatter installed globally)
- **Offline Extensions:**
    - **Tinymist:** The `.vsix` extension file is pre-downloaded and baked into the image, allowing VS Code to install it without an internet connection.
- **Shell:** `zsh` with Oh My Zsh (pre-configured for productivity).

## 🚀 Usage

**Do not clone this repository to write papers.**
Instead, use the [Typst-Template](https://github.com/JunghunLeePhD/Typst-Template) repository,
which is pre-configured to pull this image automatically.

If you need to pull this image manually:
```bash
docker pull ghcr.io/junghunleephd/typst-template-env:main
```

## **🛠 Maintenance**

To add new system tools or update Typst versions:

1. Edit the `Dockerfile`.


2. Push to `main`.


3. The **Publish Dev Container Image** workflow will automatically rebuild and update the image on GHCR.
