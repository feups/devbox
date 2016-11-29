{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./local-configuration.nix
    ];

  boot.loader.timeout = 2;
  # Use GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # remove the fsck that runs at startup. It will always fail to run, stopping
  # your boot until you press *.
  boot.initrd.checkJournalingFS = false;

  networking.enableIPv6 = false;

  nix.extraOptions = ''
    gc-keep-outputs = true
    gc-keep-derivations = true
  '';
  nix.gc.automatic = true;

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "be-latin1";
    defaultLocale = "en_US.UTF-8";
  } ;

  time.timeZone = "Europe/Amsterdam";

  services.dbus.enable = true;
  services.ntp.enable = false;
  services.openssh.enable = true;
  services.openssh.allowSFTP = false;
  services.openssh.passwordAuthentication = false;
  services.dnsmasq.enable = true;
  services.dnsmasq.extraConfig = ''
    server = /cicd/127.0.0.1#5354
  '';


  services.xserver = {
    enable = true;
    layout = "be";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.default = "xmonad";
    xkbOptions = "caps:escape";
    desktopManager.default = "none";
    displayManager = {
      lightdm = {
        enable = true;
        autoLogin.user= "vagrant";
        autoLogin.enable= true;
      };
      sessionCommands = ''
        ${pkgs.xlibs.xsetroot}/bin/xsetroot -cursor_name left_ptr
        ${pkgs.feh}/bin/feh --bg-scale "$HOME/.wallpaper.jpg"
      '';
    };
  };
  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--insecure-registry docker.cirb.lan --insecure-registry docker.sandbox.srv.cirb.lan";

  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.source-code-pro ];
  };

  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.en
    aspellDicts.fr
    autojump
    bundix
    cabal2nix
    chromium
    dnsmasq
    docker
    findutils
    firefox
    gitFull
    go2nix
    gnupg
    gnumake
    haskellPackages.shake
    haskellPackages.xmobar
    htop
    iputils
    jq
    maven
    mr
    nettools
    neovim
    netcat
    nix-repl
    nfs-utils
    nodejs
    rsync
    parallel
    python
    shellcheck
    silver-searcher
    stalonetray
    tmux
    tree
    unzip
    rxvt_unicode-with-plugins
    vcsh
    wget
    which
    xsel
    zeal
    zip
  ];

  # Creates a "vagrant" users with password-less sudo access
  users = {
    extraGroups = [ { name = "vagrant"; } { name = "vboxsf"; } ];
    extraUsers  = [
      # Try to avoid ask password
      { name = "root"; password = "vagrant"; }
      {
        description     = "Vagrant User";
        name            = "vagrant";
        group           = "vagrant";
        extraGroups     = [ "users" "vboxsf" "wheel" "docker" ];
        password        = "vagrant";
        home            = "/home/vagrant";
        createHome      = true;
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
        ];
      }
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  security.sudo.configFile =
    ''
      Defaults:root,%wheel env_keep+=LOCALE_ARCHIVE
      Defaults:root,%wheel env_keep+=NIX_PATH
      Defaults:root,%wheel env_keep+=TERMINFO_DIRS
      Defaults env_keep+=SSH_AUTH_SOCK
      Defaults lecture = never
      root   ALL=(ALL) SETENV: ALL
      %wheel ALL=(ALL) NOPASSWD: ALL, SETENV: ALL
    '';

  programs.bash.enableCompletion = true;

  programs.bash.shellAliases = {
    la = " ls -alh";
    ls = " ls --color=tty";
    du = " du -h";
    df = " df -h";
    ag = "ag --color-line-number=2";
    vim = "nvim";
    build = "./build/build.sh";
    see = "./bin/check_role.sh";
    fixlint = "./bin/fix-lint.sh";
  };

  programs.bash.interactiveShellInit = ''
    shopt -s autocd
    shopt -s histappend

    export HISTCONTROL=ignoreboth

    #. $(autojump-share)/autojump.bash
  '';

  system.stateVersion = "16.09";

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = super:
      let self = super.pkgs;
      puppetdb-dns = self.buildGoPackage rec {
        name = "puppetdb-dns-${version}";
        version = "20161124-${self.stdenv.lib.strings.substring 0 7 rev}";
        rev = "073c226ec6f81d4fb6554a478780e26d90016e4e";
        goPackagePath = "github.com/jfroche/puppetdb-dns";
        src = self.fetchgit {
          inherit rev;
          url = "https://github.com/jfroche/puppetdb-dns";
          sha256 = "1y0l8248skh0wl1qhzhz27qzlcya6l4l9zb0b20jz8p66zzfpsx5";
        };
        goDeps = /etc/puppetdb-dns/deps.nix;
      };
      in { inherit puppetdb-dns; };
  };
  systemd.services.puppetdb-dns = {
    description = "Puppetdb DNS service";
    after = [ "network.target" "systemd-dnsmasq.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.puppetdb-dns}/bin/puppetdb-dns -conf /etc/cicd/puppetdb-dns/dns.conf
    '';
  };

  systemd.tmpfiles.rules = [ "d /tmp 1777 root root 10d" ];
}
