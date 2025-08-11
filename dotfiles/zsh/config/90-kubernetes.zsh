################################################################################
##                                                                            ##
##  Kubernetes                                                                ##
##                                                                            ##
##  Configuration and tooling for Kubernetes development.                     ##
##                                                                            ##
##  Dependencies: kubectl (optional)                                          ##
##                                                                            ##
################################################################################

########################
#  Context Management  #
########################

# Set the default kube context if present
local default_kube_config="$HOME/.kube/config"
if [[ -f "$default_kube_config" ]]; then
  export KUBECONFIG="$default_kube_config"
fi

# Additional contexts should be in ~/.kube/contexts/
local custom_contexts_dir="$HOME/.kube/contexts"
[[ ! -d "$custom_contexts_dir" ]] && mkdir -p "$custom_contexts_dir"

# Add custom context files to KUBECONFIG (if any exist)
local context_files=("$custom_contexts_dir"/*.yml(N))
if (( ${#context_files[@]} > 0 )); then
  for context_file in "${context_files[@]}"; do
    export KUBECONFIG="$context_file:${KUBECONFIG:-}"
  done
fi

###################
#  Completions    #
###################

# Kubectl (lazy-load completions on first use)
if [[ -n "${commands[kubectl]:-}" ]] && [[ -z "${__BUELL[KUBECTL_COMPLETION_LOADED]:-}" ]]; then
  local kubectl_completion_cache="${__BUELL[ZSH_CONFIG_DIR]}/cache/kubectl_completion.zsh"

  # Generate cached completion if missing or kubectl is newer
  if [[ ! -f "$kubectl_completion_cache" ]] || [[ "${commands[kubectl]}" -nt "$kubectl_completion_cache" ]]; then
    mkdir -p "${__BUELL[ZSH_CONFIG_DIR]}/cache"
    kubectl completion zsh > "$kubectl_completion_cache" 2>/dev/null
  fi

  # Lazy-load from cache
  kubectl() {
    if [[ -z "${__BUELL[KUBECTL_COMPLETION_LOADED]:-}" ]]; then
      if [[ -r "$kubectl_completion_cache" ]]; then
        source "$kubectl_completion_cache"
      else
        # Fallback to live generation if cache fails
        source <(command kubectl completion zsh)
      fi
      __BUELL[KUBECTL_COMPLETION_LOADED]=1
    fi

    unfunction kubectl
    command kubectl "$@"
  }
fi
