# Local customization that won't be overridden by vagrant provision
{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (eclipses.eclipseWithPlugins {
       eclipse = eclipses.eclipse-sdk-452;
       plugins = [ ];
     })
    firefox
    oh-my-zsh
    zsh-completions
    zsh
    # geany
  ];

  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/
  '';
  programs.zsh.shellAliases = {
    la = " ls -alh";
    ls = " ls --color=tty";
    ll ='ls -lh';
    duh = " du -h --max-depth=1";
    df = " df -h";
    ag = "ag --color-line-number=3";
    vim = "nvim";
    build = "./build/build.sh";
    see = "./bin/check_role.sh";
    heyaml = "./bin/eyaml.sh $@";
    fixlint = "./bin/fix-lint.sh";
    nixreb = "sudo nixos-rebuild switch";
    ldir = "ls -ladh (.*|*)(/,@)";
    lfile = "ls -lah *(.)";
  };
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";
}
