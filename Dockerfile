FROM --platform=$BUILDPLATFORM alpine:3.22.0

ARG ISTIO_VERSION=1.26.1
ARG TARGETOS
ARG TARGETARCH

COPY ./scripts/* /usr/bin/

RUN apk update

RUN apk add --no-cache \
    gcompat \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    jq \
    yq \
    gnupg \
    lsb-release-minimal  \
    inetutils-telnet \
    tcpdump \
    openssl \
    openssh-client-default \
    unzip \
    procps \
    libxext-dev \
    libxrender-dev \
    libxtst-dev \
    libxi-dev \
    freetype-dev \
    make \
    cmake \
    opentofu \
    kubectl \
    helm

# Install krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
RUN set -x; TMPDIR="$(mktemp -d)"; cd ${TMPDIR} && \
    KREW="krew-${TARGETOS}_${TARGETARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew && \
    rm -r ${TMPDIR}

ENV PATH="$PATH:/root/.krew/bin"

RUN kubectl krew install ctx
RUN kubectl krew install ns
RUN kubectl krew install oidc-login

# Install istioctl
# https://istio.io/latest/docs/setup/getting-started/#download
RUN ISTIO_VERSION=${ISTIO_VERSION} curl -L https://istio.io/downloadIstio | sh - && \
    mv istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/ && \
    rm -rf istio-${ISTIO_VERSION} && \
    istioctl version --remote=false

# Install kyma cli
# https://kyma-project.io/#/cli/user/README?id=install-kyma-cli
RUN curl -sL "https://raw.githubusercontent.com/kyma-project/cli/refs/heads/main/hack/install_cli_latest.sh" | sh - && \
    kyma version

# Install modulectl
# https://github.com/kyma-project/modulectl?tab=readme-ov-file#installation
RUN VERSION_SUFFIX="$(uname -m | sed -e 's/amd64//' -e 's/x86_64//' -e 's/arm64/-arm/' -e 's/aarch64/-arm/')" && \
    curl -Lv "https://github.com/kyma-project/modulectl/releases/latest/download/modulectl-${TARGETOS}${VERSION_SUFFIX}" -o /usr/local/bin/modulectl && \
    chmod +x /usr/local/bin/modulectl && \
    modulectl version

# Install btp-cli
# https://github.com/kyma-project/terraform-module/blob/main/.github/actions/force-delete-sap-btp-subaccount/action.yaml#L31-L34
RUN TMPDIR="$(mktemp -d)" && \
    curl -L "https://tools.hana.ondemand.com/additional/btp-cli-${TARGETOS}-${TARGETARCH}-latest.tar.gz" --cookie "eula_3_2_agreed=tools.hana.ondemand.com/developer-license-3_2.txt" -o "${TMPDIR}/btp.tar.gz" && \
    ls -ls ${TMPDIR} && \
    tar -zxf ${TMPDIR}/btp.tar.gz --strip-components=1 -C /usr/local/bin && \
    rm -f ${TMPDIR}/btp.tar.gz && \
    btp --version

# Upgrade all packages and clean up
RUN apk upgrade --no-cache

# TODO: think about installing packages in expected versions (not latest ones)
