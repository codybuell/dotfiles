################################################################################
##                                                                            ##
##  Path                                                                      ##
##                                                                            ##
##  Rebuilds PATH with prioritized directories, configures GOPATH and         ##
##  CDPATH for enhanced navigation. Includes Go workspace management.         ##
##                                                                            ##
##  Dependencies: none                                                        ##
##                                                                            ##
################################################################################

# Grab the default system path
SYSTEM_PATH=$PATH

# Clear path to rebuild it cleanly
path=()

# gopath and default gopath (for dynamic gopath support, see cd in functions)
export GOPATH={{ GoPath }}
export DEFGOP=$GOPATH

# Build path using helpers
# NOTE: function only adds path if it exists
path_append "$HOME/Bin"
path_append "$HOME/.shell/bin"
path_append "$HOME/.local/bin"
path_append "/opt/homebrew/bin"
path_append "/usr/local/bin"
path_append "/usr/local/sbin"

# Add Go binary paths
for gopath_entry in ${(s/:/)GOPATH}; do
  path_append "${gopath_entry}/bin"
done

# Restore system paths (typeset -U ensures no duplicates)
for system_dir in ${(s/:/)SYSTEM_PATH}; do
  path_append "$system_dir"
done

# Shortcuts for cd (eg cd myrepo for cd {{ Repos }}/github.com/{{ GitUsername }}/myrepo)
# NOTE: Don't export CDPATH, it can cause problems with scripts
CDPATH=.:~:{{ Repos }}/github.com/{{ GitUsername }}:{{ CDPath }}
