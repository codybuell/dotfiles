################################################################################
##                                                                            ##
##  DirEnv                                                                    ##
##                                                                            ##
##  Automatic loading of directory specific environments as configured        ##
##  in `.envrc` files.                                                        ##
##                                                                            ##
##  Dependencies: direnv                                                      ##
##                                                                            ##
################################################################################

# for performance, disable all logging
export DIRENV_LOG_FORMAT=

eval "$(direnv hook zsh)"
