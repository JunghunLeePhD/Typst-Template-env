# Use a lightweight base
FROM debian:bookworm-slim

ARG TYPST_VERSION=v0.12.0
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# 1. Install dependencies, tools, and Zsh
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    git \
    make \
    fontconfig \
    zsh \
    sudo \
    wget \
    vim \
    && \
    # Create the user 'vscode'
    groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && \
    # -----------------------------------------------------------------------
    # ARCHITECTURE DETECTION LOGIC
    # -----------------------------------------------------------------------
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        # Typst uses MUSL for static linking
        TYPST_ARCH="x86_64-unknown-linux-musl"; \
        # Typstyle uses GNU for Debian/Ubuntu compatibility
        TYPSTYLE_ARCH="x86_64-unknown-linux-gnu"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        TYPST_ARCH="aarch64-unknown-linux-musl"; \
        TYPSTYLE_ARCH="aarch64-unknown-linux-gnu"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi \
    && \
    # -----------------------------------------------------------------------
    # INSTALL TYPST (Tarball)
    # -----------------------------------------------------------------------
    echo "Downloading Typst for $TYPST_ARCH..." && \
    curl -L "https://github.com/typst/typst/releases/download/${TYPST_VERSION}/typst-${TYPST_ARCH}.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin "typst-${TYPST_ARCH}/typst" \
    && \
    # -----------------------------------------------------------------------
    # INSTALL TYPSTYLE (Raw Binary)
    # -----------------------------------------------------------------------
    echo "Downloading Typstyle for $TYPSTYLE_ARCH..." && \
    # Note: We download the raw binary directly to /usr/local/bin/typstyle
    curl -L -o /usr/local/bin/typstyle "https://github.com/typstyle-rs/typstyle/releases/latest/download/typstyle-${TYPSTYLE_ARCH}" \
    && chmod +x /usr/local/bin/typstyle \
    && \
    # -----------------------------------------------------------------------
    # CLEANUP
    # -----------------------------------------------------------------------
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    fc-cache -fv

# 2. Configure Zsh for the 'vscode' user
USER $USERNAME
ENV HOME=/home/$USERNAME

# Install Oh My Zsh (Unattended)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Plugins (Autosuggestions & Syntax Highlighting)
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure .zshrc
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="robbyrussell"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# 3. Finalize
USER root
WORKDIR /workspace
CMD ["typst", "--version"]