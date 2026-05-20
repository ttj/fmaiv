# Day 4 — Program and high-assurance verification
#
# A self-contained image with CBMC, Cryptol, and SAW preinstalled.
# Participants on Windows/macOS/Linux all run the same container, so
# tool versions match the assignment text exactly.
#
# Build:
#     docker build -t fmaiv-day04 .
#
# Run (mounts the current directory at /work so host edits show up live):
#     docker run --rm -it -v "$(pwd)":/work fmaiv-day04
#
# See README.md for full per-OS instructions.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Pinned versions. Bump together so the LLVM bitcode SAW sees stays compatible.
ARG CBMC_VERSION=6.9.0
ARG SAW_VERSION=1.5
ARG CLANG_VERSION=15

# Base tools + clang/LLVM for SAW's bitcode pipeline.
# clang-15 is the latest version with bitcode SAW 1.5 reliably parses.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        wget \
        git \
        less \
        nano \
        vim \
        z3 \
        libgmp10 \
        libnuma1 \
        libtinfo6 \
        libffi8 \
        zlib1g \
        clang-${CLANG_VERSION} \
        llvm-${CLANG_VERSION} \
    && ln -sf /usr/bin/clang-${CLANG_VERSION} /usr/local/bin/clang \
    && ln -sf /usr/bin/clang++-${CLANG_VERSION} /usr/local/bin/clang++ \
    && ln -sf /usr/bin/llvm-config-${CLANG_VERSION} /usr/local/bin/llvm-config \
    && rm -rf /var/lib/apt/lists/*

# CBMC: install from the upstream .deb (matches the version in slides/assignments).
RUN curl -L -o /tmp/cbmc.deb \
        "https://github.com/diffblue/cbmc/releases/download/cbmc-${CBMC_VERSION}/ubuntu-24.04-cbmc-${CBMC_VERSION}-Linux.deb" \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/cbmc.deb \
    && rm /tmp/cbmc.deb \
    && rm -rf /var/lib/apt/lists/*

# SAW (with-solvers): bundles cryptol + every supported SMT solver.
# Extracted to /opt/saw; binaries added to PATH.
RUN curl -L -o /tmp/saw.tar.gz \
        "https://github.com/GaloisInc/saw-script/releases/download/v${SAW_VERSION}/saw-${SAW_VERSION}-ubuntu-24.04-X64-with-solvers.tar.gz" \
    && mkdir -p /opt/saw \
    && tar -xzf /tmp/saw.tar.gz -C /opt/saw --strip-components=1 \
    && rm /tmp/saw.tar.gz
ENV PATH="/opt/saw/bin:${PATH}"

# Sanity-check every tool at build time so we fail fast if a download/install
# regressed. Each line should print a version banner.
RUN cbmc --version \
    && cryptol --version | head -2 \
    && saw --version | head -2 \
    && clang --version | head -1 \
    && z3 --version

# Default working directory; users bind-mount their host folder here.
WORKDIR /work

# Drop into a shell so participants can run the commands from assignments/day04.md
# directly. Override with `docker run ... <command>` if you want one-shot use.
CMD ["/bin/bash"]
