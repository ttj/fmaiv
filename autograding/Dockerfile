# FMAIV autograding image — the single container every Classroom assignment
# runs its grading job inside. Superset of day04/Dockerfile: adds Lean (elan),
# Python+pytest, smvis (verivital), and NuSMV (Day 2 model checking).
#
# Every tool here is open source / freely redistributable, so this image is
# meant to be PUBLIC at ghcr.io/ttj/fmaiv-autograde — that lets every
# student repo pull it with no secrets and no registry-access config. (nuXmv
# is license-gated and lives only in the separate teaching Docker, not here.)
#
# Build context is THIS directory (autograding/). No vendored binaries needed.
#
# Local build:
#     cd autograding
#     docker build -t ghcr.io/ttj/fmaiv-autograde:latest .

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Pin every tool so a grade is reproducible months later.
ARG CBMC_VERSION=6.9.0
ARG SAW_VERSION=1.5
ARG CLANG_VERSION=15
ARG LEAN_VERSION=v4.29.0

# ---------------------------------------------------------------------------
# Base OS packages: build tools, clang/LLVM for SAW, Z3, Python, smvis deps.
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        wget \
        git \
        unzip \
        less \
        z3 \
        python3 \
        python3-pip \
        python3-venv \
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

# ---------------------------------------------------------------------------
# CBMC — upstream .deb (Day 4 Track A).
# ---------------------------------------------------------------------------
RUN curl -L -o /tmp/cbmc.deb \
        "https://github.com/diffblue/cbmc/releases/download/cbmc-${CBMC_VERSION}/ubuntu-24.04-cbmc-${CBMC_VERSION}-Linux.deb" \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/cbmc.deb \
    && rm /tmp/cbmc.deb && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# SAW (with-solvers) — bundles Cryptol + every SMT solver (Day 4 Track B).
# ---------------------------------------------------------------------------
RUN curl -L -o /tmp/saw.tar.gz \
        "https://github.com/GaloisInc/saw-script/releases/download/v${SAW_VERSION}/saw-${SAW_VERSION}-ubuntu-24.04-X64-with-solvers.tar.gz" \
    && mkdir -p /opt/saw \
    && tar -xzf /tmp/saw.tar.gz -C /opt/saw --strip-components=1 \
    && rm /tmp/saw.tar.gz
ENV PATH="/opt/saw/bin:${PATH}"

# ---------------------------------------------------------------------------
# Lean 4 via elan, with the course toolchain preinstalled so the common
# `lake build` does not pay the toolchain download on every student push
# (Day 3). Installed under /opt/elan, world-readable.
# ---------------------------------------------------------------------------
ENV ELAN_HOME=/opt/elan \
    PATH="/opt/elan/bin:${PATH}"
RUN curl -sSfL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -o /tmp/elan-init.sh \
    && sh /tmp/elan-init.sh -y --default-toolchain "leanprover/lean4:${LEAN_VERSION}" \
    && rm /tmp/elan-init.sh \
    && chmod -R a+rX /opt/elan

# ---------------------------------------------------------------------------
# Python grading deps + smvis (the verivital SMV tool, Day 2), installed
# editable from /opt/smvis. The Day 2 grader (smvis-grade) calls NuSMV
# directly. PEP 668: use --break-system-packages.
# ---------------------------------------------------------------------------
RUN pip install --no-cache-dir --break-system-packages \
        pytest z3-solver \
    && git clone --depth 1 https://github.com/verivital/smvis.git /opt/smvis \
    && pip install --no-cache-dir --break-system-packages -e /opt/smvis

# ---------------------------------------------------------------------------
# NuSMV — Day 2 model checker. Open source (LGPL), freely redistributable, so
# this image can be PUBLIC (no license-gated binary, no registry-access dance).
# Same SMV language and "is true/false" output as nuXmv on our finite-state
# models. (nuXmv stays in the separate teaching Docker for class use.)
# ---------------------------------------------------------------------------
RUN curl -L -o /tmp/nusmv.tar.gz "https://nusmv.fbk.eu/distrib/NuSMV-2.6.0-linux64.tar.gz" \
    && mkdir -p /opt/nusmv \
    && tar -xzf /tmp/nusmv.tar.gz -C /opt/nusmv --strip-components=1 \
    && ln -sf /opt/nusmv/bin/NuSMV /usr/local/bin/NuSMV \
    && rm /tmp/nusmv.tar.gz \
    && NuSMV -help >/dev/null 2>&1 || true

# ---------------------------------------------------------------------------
# Grading helper scripts on PATH.
# ---------------------------------------------------------------------------
COPY scripts/ /usr/local/lib/fmaiv-grading/
RUN chmod +x /usr/local/lib/fmaiv-grading/*.sh \
    && for s in /usr/local/lib/fmaiv-grading/*.sh; do \
         ln -sf "$s" "/usr/local/bin/$(basename "$s" .sh)"; \
       done

# ---------------------------------------------------------------------------
# Build-time sanity check: every tool answers.
# ---------------------------------------------------------------------------
RUN cbmc --version \
    && cryptol --version | head -1 \
    && saw --version | head -1 \
    && clang --version | head -1 \
    && z3 --version \
    && lean --version \
    && ( NuSMV -help >/dev/null 2>&1 && echo "NuSMV OK" || echo "NuSMV present" ) \
    && python3 -c "import smvis, pytest, z3; print('python grading deps OK')"

WORKDIR /work
CMD ["/bin/bash"]
