{
  pkgs,
  config,
  username,
  local,
  dotfiles,
  ...
}:
{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.shellAliases = {
    vim = "nvim";
    vi = "nvim";
  };

  # users.users.<name>.packages nixos native way
  home.packages = with pkgs; [
    nodejs_24

    neovim
    tree-sitter
    luarocks
    lua5_1
    cargo
    fzf

    pnpm
  ];

  home.file = {
    nvim = {
      source = "${dotfiles}/stow/nvim/dot-config/nvim";
      target = ".config/nvim";
      recursive = true;
    };
    zshrc = {
      source = "${dotfiles}/stow/zsh/dot-config/zsh/.zshrc";
      target = ".config/zsh/.zshrc";
    };
    zsh-themes = {
      source = "${dotfiles}/stow/zsh/dot-config/zsh/themes";
      target = ".config/zsh/themes";
      recursive = true;
    };
    # without this the sessionVariables will never be sourced
    zprofile = {
      text = ''
        for f in /etc/profiles/per-user/$LOGNAME/etc/profile.d/*.sh; do
          [ -r "$f" ] && source "$f"
        done
      '';
      target = ".config/zsh/.zprofile";
    };
    zsh-env = {
      source = "${dotfiles}/stow/zsh/dot-zshenv";
      target = ".zshenv";
    };
    tmux = {
      source = "${dotfiles}/stow/tmux/.config/tmux";
      target = ".config/tmux";
      recursive = true;
    };
    tmux-sessionizer = {
      source = "${dotfiles}/stow/tmux-sessionizer/dot-local/bin/tmux-sessionizer";
      target = ".local/bin/tmux-sessionizer";
    };
  };

  # if this is not enabled the sessionVariables are not set
  #programs.bash.enable = true;
  #programs.zsh.enable = true;

  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/main-27042025.pub";
      format = "ssh";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "${local.git_username}";
        email = "${local.git_email}";
      };

      commit = {
        gpgsign = true;
      };

      core = {
        editor = "nvim";
      };

      color = {
        ui = "auto";
      };

      rebase = {
        autosquash = true;
      };

      merge = {
        tool = "nvimdiff";
      };

      mergetool = {
        prompt = false;
        keepbackup = false;
      };

      mergetool = {
        "nvimdiff" = {
          layout = "LOCAL,BASE,REMOTE / MERGED";
        };
      };
    };
  };

  # tells home manager to assume xdg for nix paths
  # works with nix.settings.use-xdg-base-directories
  nix.assumeXdg = true;

  # tells home manager to prefer use of xdg
  home.preferXdgDirectories = true;
  xdg.enable = true;

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    desktop = null;
    download = null;
    music = null;
    package = null;
    pictures = null;
    projects = null;
    publicShare = null;
    templates = null;
    videos = null;
    extraConfig = {
      DEVELOPER = "${config.home.homeDirectory}/Developer";
    };
  };

  services.syncthing = {
    enable = true;

    settings = {
      devices = {
        lain = {
          addresses = [
            "tcp://127.0.0.1:22001"
          ];
          id = "BNVQGDW-DBWVHY6-TXVEIY4-C3Q7WG2-CKOJKSF-C72FQRH-DCGG2TS-3F6CEQB";
        };
      };
      folders = {
        "${config.xdg.userDirs.documents}/obsidian" = {
          devices = [
            "lain"
          ];
          id = "obsidian";
        };
      };
      gui = {
        enabled = false;
      };
      options = {
        relaysEnabled = false;
        urAccepted = -1;
      };
    };
  };

  systemd.user.services.syncthing-ssh-tunnel = {
    Unit = {
      Description = "Syncthing SSH tunnel";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh -N -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -L 22001:localhost:22000 -R 22002:localhost:22000 ${local.syncthing_tunnel_username}@${local.syncthing_tunnel_ip} -i ~/.ssh/main-27042025";
      Restart = "always";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.stateVersion = "25.11";
}
