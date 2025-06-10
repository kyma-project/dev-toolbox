##@ General
.DEFAULT_GOAL=help
.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: on-cluster
on-cluster: ## Run dev-toolbox on the cluster.
	kubectl apply -f hack/resources.yaml
	kubectl wait --for=condition=ContainersReady --timeout=60s pod/dev-toolbox
	kubectl exec -it dev-toolbox -- bash

.PHONY: generate-local-devcontainer
generate-local-devcontainer: ## generate .devcontainer with local Dockerfile
	mkdir -p ./.devcontainer
	sed -e 's/"image".*/"build": {\n        "dockerfile": "..\/Dockerfile"\n    },/' hack/devcontainer.json  > ./.devcontainer/devcontainer.json
