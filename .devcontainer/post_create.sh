#!/bin/sh

echo "\e[0;32m### Kubectl version ###\e[m"
kubectl version --client

echo "\n\e[0;32m### Terraform version ###\e[m"
terraform version

echo "\n\e[0;32m### Istioctl version ###\e[m"
istioctl version --remote=false

echo "\n\e[0;32m### Helm version ###\e[m"
helm version

echo "\n\e[0;32m### Kyma version ###\e[m"
kyma version

echo "\n\e[0;32m### Modulectl version ###\e[m"
modulectl version

echo "\n\e[0;32m### BTP version ###\e[m"
btp --version
