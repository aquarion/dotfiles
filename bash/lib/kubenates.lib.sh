function kc {
  # Switch to a Kubernetes context
  # Usage: kc <context-name>
  if [ -z "$1" ]; then
    echo "Kubernetes context switcher"
    echo "Usage: kc <context-name>"
    return 1
  fi
  if ! command -v yq &>/dev/null; then
    echo "yq is not installed. Please install it to use this function."
    return 1
  fi
  context=$(cat ~/.kube/config | yq .contexts[].name | grep -i $1)
  if [ -z "$context" ]; then
    echo "No context found for $1"
    return 1
  fi
  kubectl config use-context $context
  if [ $? -ne 0 ]; then
    echo "Failed to switch context to $context"
    return 1
  fi
}

alias k=kubectl
# alias kc="kubectl config use-context"
