# Use a lightweight base
FROM debian:bookworm-slim

# Set Typst Version
ARG TYPST_VERSION=v0.12.0

# Install dependencies and tools
# Removed 'fonts-nanum' and 'fonts-noto-cjk'
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    xz-utils \
    git \
    make \
    fontconfig \
    && \
    # Download and install Typst
    curl -L "https://github.com/typst/typst/releases/download/${TYPST_VERSION}/typst-x86_64-unknown-linux-musl.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin typst-x86_64-unknown-linux-musl/typst \
    && \
    # Cleanup to keep image small
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    # Refresh font cache
    fc-cache -fv

# Set default working directory
WORKDIR /workspace

# Verify installation
CMD ["typst", "--version"]