{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; {
    basePackages = pkgs.buildEnv {
      name = "base-packages";
      paths = [
        # ack                           # recursive grep like search
        # antibody                      # package management for zsh
        # asciinema                     # terminal session recorder
        # bc                            # gnu software calculator
        # coreutils                     # gnu utility toolkit
        # direnv                        # dynamic folder based environments
        # ffmpeg                        # audio video swiss army knife
        # git                           # distributed version control
        # jq                            # query utility for json
        # kitty                         # fast lightweight terminal
        # lua                           # the lua programming language
        # neovim                        # modern vim derivative
        # pcalc                         # cli programming calculator
        # ripgrep                       # recursive grep like search
        # silver-searcher               # ag, ack and ripgrep alternative
        # tmux                          # terminal multiplexer
        # wget                          # curl alternative
      ];
      pathsToLink = [ "/share" "/bin" "/Applications" ];
    };
    osxPackages = pkgs.buildEnv {
      name = "osx-packages";
      paths = [
        # mas                           # mac app store package manager
        # terminal-notifier             # send osx notifications via terminal
        # reattach-to-user-namespace    # reattach tmux etc to user namespace
      ];
      pathsToLink = [ "/share" "/bin" "/Applications" ];
    };
    linuxPackages = pkgs.buildEnv {
      name = "linux-packages";
      paths = [
        # xclip                         # xclipboard access via terminal
      ];
      pathsToLink = [ "/share" "/bin" ];
    };
  };
}
