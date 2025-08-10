################################################################################
##                                                                            ##
##  Kubernetes                                                                ##
##                                                                            ##
################################################################################

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
