# Use a lightweight base
FROM debian:bookworm-slim

ARG TYPST_VERSION=v0.12.0
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# 1. Install dependencies (ADDED: unzip)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils git make fontconfig zsh sudo wget vim \
    unzip \
    && \
    groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && \
    # -----------------------------------------------------------------------
    # ARCHITECTURE DETECTION
    # -----------------------------------------------------------------------
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        TYPST_ARCH="x86_64-unknown-linux-musl"; \
        TYPSTYLE_ARCH="x86_64-unknown-linux-gnu"; \
        VSIX_PLATFORM="linux-x64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        TYPST_ARCH="aarch64-unknown-linux-musl"; \
        TYPSTYLE_ARCH="aarch64-unknown-linux-gnu"; \
        VSIX_PLATFORM="linux-arm64"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi \
    && \
    # -----------------------------------------------------------------------
    # INSTALL TYPST
    # -----------------------------------------------------------------------
    echo "Downloading Typst for $TYPST_ARCH..." && \
    curl -L "https://github.com/typst/typst/releases/download/${TYPST_VERSION}/typst-${TYPST_ARCH}.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin "typst-${TYPST_ARCH}/typst" \
    && \
    # -----------------------------------------------------------------------
    # INSTALL TYPSTYLE
    # -----------------------------------------------------------------------
    echo "Downloading Typstyle for $TYPSTYLE_ARCH..." && \
    curl -L -o /usr/local/bin/typstyle "https://github.com/typstyle-rs/typstyle/releases/latest/download/typstyle-${TYPSTYLE_ARCH}" \
    && chmod +x /usr/local/bin/typstyle \
    && \
    # -----------------------------------------------------------------------
    # PREPARE OFFLINE EXTENSION (UNZIP STRATEGY)
    # -----------------------------------------------------------------------
    echo "Downloading Tinymist VSIX for $VSIX_PLATFORM..." && \
    # Create a staging directory
    mkdir -p /usr/local/share/vscode-tinymist && \
    # Download VSIX to temp location
    curl -L -o /tmp/tinymist.vsix \
        "https://github.com/Myriad-Dreamin/tinymist/releases/latest/download/tinymist-${VSIX_PLATFORM}.vsix" \
    && \
    # Unzip the VSIX (it's just a zip file)
    # The actual extension content is inside a folder named 'extension' in the zip
    unzip -q /tmp/tinymist.vsix "extension/*" -d /tmp/tinymist_extracted && \
    # Move the inner content to our clean staging folder
    mv /tmp/tinymist_extracted/extension/* /usr/local/share/vscode-tinymist/ && \
    # Cleanup
    rm -rf /tmp/tinymist.vsix /tmp/tinymist_extracted \
    && \
    # -----------------------------------------------------------------------
    # CLEANUP
    # -----------------------------------------------------------------------
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    fc-cache -fv

# 2. Configure Zsh
USER $USERNAME
ENV HOME=/home/$USERNAME

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="robbyrussell"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

USER root
WORKDIR /workspace
CMD ["typst", "--version"]