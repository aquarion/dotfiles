#!/bin/bash
# kubenates.lib.sh - A library for managing Kubernetes contexts and configurations
function kc {
  # Switch to a Kubernetes context
  # Usage: kc <context-name>
  if ! command -v yq &>/dev/null; then
    echo "yq is not installed. Please install it to use this function."
    return 1
  fi
  if [ -z "$1" ]; then
    echo "Kubernetes context switcher"
    echo "Usage: kc <context-name>"
    echo Available contexts:
    cat ~/.kube/config | yq -r .contexts[].name
    echo "Or kc -x to unsertand the current context"
    return 1
  fi
  if [ "$1" == "-x" ]; then
    kubectl config unset current-context
    return 0
  fi
  context=$(cat ~/.kube/config | yq -r .contexts[].name | grep -i "$1")
  if [ -z "$context" ]; then
    echo "No context found for $1"
    return 1
  fi
  kubectl config use-context "$context"
  if [ $? -ne 0 ]; then
    echo "Failed to switch context to $context"
    return 1
  fi
}

alias k=kubectl
# alias kc="kubectl config use-context"
