# dev-toolbox

[![REUSE status](https://api.reuse.software/badge/github.com/kyma-project/dev-toolbox)](https://api.reuse.software/info/github.com/kyma-project/dev-toolbox)

The `dev-toolbox` project contains the most useful binaries in one image. It is a Debian-based image that can be used, for example, as a script executor inside a cluster or base image for [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers).

The image collects the most useful tools in one place from several areas, like:

- integrations:
  - kubectl & krew
  - tofu
  - istioctl
  - helm
  - kyma-cli
  - modulectl
  - btp-cli
- networking
  - curl
  - wget
  - telnet
  - tcpdump
- files transformations
  - yq
  - jq
  - unzip
  - make
  - cmake

## Usage

> [!NOTE]
> Because `dev-toolbox` is in an early development state, we would suggest using the latest built image that contains all fixes and smaller improvements:

```text
europe-docker.pkg.dev/kyma-project/prod/dev-toolbox:main
```

To run a local container, use the following command:

```bash
docker run -it --rm europe-docker.pkg.dev/kyma-project/prod/dev-toolbox:main
```

If you are looking for a way to run `dev-toolbox` inside the cluster, apply the required resources:

```bash
kubectl apply -f https://raw.githubusercontent.com/kyma-project/dev-toolbox/refs/heads/main/hack/resources.yaml
```

For integration of `dev-toolbox` with the [devcontainers](https://code.visualstudio.com/docs/devcontainers/containers), use [the following configuration](https://raw.githubusercontent.com/kyma-project/dev-toolbox/refs/heads/main/hack/devcontainer.json).

## Contributing
<!--- mandatory section - do not change this! --->

See the [Contributing Rules](CONTRIBUTING.md).

## Code of Conduct
<!--- mandatory section - do not change this! --->

See the [Code of Conduct](CODE_OF_CONDUCT.md) document.

## Licensing
<!--- mandatory section - do not change this! --->

See the [license](./LICENSE) file.
