FROM debian:bookworm-slim

ARG ISTIO_VERSION=1.26.1

RUN apt update

RUN apt install --yes --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    jq \
    yq \
    gnupg \
    lsb-release \
    telnet \
    tcpdump \
    openssl

# Install kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

RUN apt update && apt install --yes --no-install-recommends kubectl && \
    kubectl version --client

# Install krew
# https://krew.sigs.k8s.io/docs/user-guide/setup/install/
RUN set -x; TMPDIR="$(mktemp -d)"; cd ${TMPDIR} && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew && \
    rm -r ${TMPDIR}

ENV PATH="$PATH:/root/.krew/bin"

RUN kubectl krew install ctx
RUN kubectl krew install ns
RUN kubectl krew install oidc-login

# Install terraform
# https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

RUN apt update && apt install --yes --no-install-recommends terraform && \
    terraform version

# Install istioctl
# https://istio.io/latest/docs/setup/getting-started/#download
RUN ISTIO_VERSION=${ISTIO_VERSION} curl -L https://istio.io/downloadIstio | sh - && \
    mv istio-${ISTIO_VERSION}/bin/istioctl /usr/local/bin/ && \
    rm -rf istio-${ISTIO_VERSION} && \
    istioctl version --remote=false

# Install helm
# https://helm.sh/docs/intro/install/#from-apt-debianubuntu
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt update && apt install --yes --no-install-recommends helm && \
    helm version

# Install kyma cli
# https://kyma-project.io/#/cli/user/README?id=install-kyma-cli
RUN curl -sL "https://raw.githubusercontent.com/kyma-project/cli/refs/heads/main/hack/install_cli_latest.sh" | sh - && \
    kyma version

# Install modulectl
# https://github.com/kyma-project/modulectl?tab=readme-ov-file#installation
RUN OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64//' -e 's/amd64//' -e 's/arm64/-arm/' -e 's/aarch64/-arm/')" && \
    curl -L "https://github.com/kyma-project/modulectl/releases/latest/download/modulectl-${OS}${ARCH}" -o /usr/local/bin/modulectl && \
    chmod +x /usr/local/bin/modulectl && \
    modulectl version

# Install btp-cli
# https://github.com/kyma-project/terraform-module/blob/main/.github/actions/force-delete-sap-btp-subaccount/action.yaml#L31-L34
RUN TMPDIR="$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')" && \
    curl -L "https://tools.hana.ondemand.com/additional/btp-cli-${OS}-${ARCH}-latest.tar.gz" --cookie "eula_3_2_agreed=tools.hana.ondemand.com/developer-license-3_2.txt" -o "${TMPDIR}/btp.tar.gz" && \
    ls -ls ${TMPDIR} && \
    tar -zxf ${TMPDIR}/btp.tar.gz --strip-components=1 -C /usr/local/bin && \
    rm -f ${TMPDIR}/btp.tar.gz && \
    btp --version

# TODO: bumblebee
# TODO: think about installing packages in expected versions (not latest ones)