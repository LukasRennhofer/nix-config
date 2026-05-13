# nix-config by Lukas Rennhofer (lukas-rennhofer.com)

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  networking.hostName = "lukasr-nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable i3
  services.xserver = {
    enable = true;
    dpi = 144;

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3blocks #if you are planning on using i3blocks over i3status
        polybar
     ];
    };
  };

  services.displayManager.defaultSession = "none+i3";

  programs.i3lock.enable = true; #default i3 screen locker

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "at";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lukasr = {
    isNormalUser = true;
    description = "Lukas Rennhofer";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Zsh Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 20000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
      "HIST_REDUCE_BLANKS"
      "SHARE_HISTORY"
      "AUTO_CD"
      "INTERACTIVE_COMMENTS"
    ];

    interactiveShellInit = ''
      bindkey -e
      eval "$(starship init zsh)"
      export EDITOR=vim
      export VISUAL=vim
      export LESS='-R'
      export PATH="$HOME/.local/bin:$PATH"
    '';

    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      edit = "sudo -e";
      update = "sudo nixos-rebuild switch";
      ".." = "cd ..";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$username$hostname$directory$git_branch$git_status$cmd_duration$character";

      username = {
        style_user = "bold fg:#d8dee9";
        style_root = "bold fg:#bf616a";
        format = "[$user]($style) ";
      };

      hostname = {
        ssh_only = false;
        format = "[@$hostname]($style) ";
        style = "bold fg:#88c0d0";
      };

      directory = {
        style = "bold fg:#5e81ac";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      git_branch = {
        symbol = " ";
        style = "bold fg:#88c0d0";
      };

      git_status = {
        style = "bold fg:#e0af68";
      };

      cmd_duration = {
        format = "[took $duration]($style) ";
        style = "fg:#4c566a";
      };

      character = {
        success_symbol = "[❯](bold fg:#88c0d0)";
        error_symbol = "[❯](bold fg:#bf616a)";
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Terminal Stuff
    vim
    neovim
    kitty
    fastfetch
    btop
    starship

    # Development
    vscode
    git
    gnumake
    cmake
    gcc
    docker

    # Office
    libreoffice-qt
    obsidian
    discord

    # Audio Stuff
    pulseaudio
    pavucontrol
    alsa-utils

    feh # for setting wallpapers
    rofi # for application launching

    # Dolphin
    kdePackages.qtsvg
    kdePackages.dolphin

    networkmanagerapplet
    networkmanager_dmenu
    networkmanager
    # System Stuff
    acpi
    gawk
    gnugrep
    coreutils
    procps
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
    # Set up resource limits
    daemon.settings = {
      experimental = true;
      default-address-pools = [
        {
          base = "172.30.0.0/16";
          size = 24;
        }
      ];
    };
  };

  system.stateVersion = "25.11"; # Did you read the comment?
}
