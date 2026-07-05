{ pkgs, username, ... }: {
  users = {
    mutableUsers = false;
    users = {
      david = {
        description = "david";
        isNormalUser = true;
        group = "david";
        extraGroups = [ "wheel" ];
        hashedPassword = "$6$wUVayqcmzjSreXYS$zv573uVuGT2Bfg1vOKgSDfz8jIrD9HW8F0aFesjnPtlfRQhZ28aKXOjbGkzk2SNh8aE6c3BhnDCDhqPOWx2fA0";
        shell = pkgs.zsh;
      };
    };

    groups.david = { };
  };

  programs.zsh.enable = true;
  programs.tmux.enable = true;
  virtualisation.docker.enable = true;

  nix.settings.use-xdg-base-directories = true;
  nixpkgs.config.allowUnfree = true;

  systemd.tmpfiles.rules = [ "d /home/${username}/Developer 0755 ${username} ${username} - -" ];
}
