{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [
    "i2c-dev"
    "kvm-amd"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';

  # Hardware
  hardware.i2c.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
    (networkmanager-l2tp.override { strongswan = pkgs.libreswan; })
  ];
  networking.firewall.checkReversePath = "loose";
  # networking.hosts = {
  #   "10.10.80.90" = [ "kibana.moco.com.np" "zabbix.moco.com.np" ];
  #   "10.10.70.12" = [ "pbs-stag.moco.com.np" ];
  # };

  # Time / Locale
  time.timeZone = "Asia/Kathmandu";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users
  users.users.wakizu = {
    isNormalUser = true;
    description = "wakizu";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "kvm"
      "libvirtd"
      "i2c"
    ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
    linger = true;
  };

  # Security
  security.pam.services.login.fprintAuth = false;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.sudo.rules.auth.fprintd.settings.timeout = 5;
  security.rtkit.enable = true;

  # Environment
  # environment.etc."strongswan.conf".text = ''
  #   charon {
  #     integrity_test = no
  #   }
  # '';
  environment.variables = {
    TERM = "xterm-256color";
  };
  environment.variables.WEBKIT_FORCE_SANDBOX = "0";
  environment.systemPackages = with pkgs; [
    # Core / System tools
    vim
    neovim
    vimPlugins.LazyVim
    wget
    tree
    inetutils
    dig
    usbutils
    pciutils
    openssl
    eza
    bat
    fd
    ripgrep
    fzf
    tmux
    gcc
    go
    gh
    pavucontrol
    ddcutil

    # Desktop & GUI
    trayscale
    freerdp
    openfortivpn
    openfortivpn-webview
    linux-wifi-hotspot
    scrcpy
    gvfs
    kitty
    terminator
    zellij
    winbox4
    winboat
    qbittorrent
    mpv-unwrapped
    spotify
    zoom-us
    ani-cli
    obsidian
    typora
    btop
    imagemagick
    pandoc
    kdePackages.kdenlive

    # Browsers
    chromium
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.helium.defaultPackage.${pkgs.stdenv.hostPlatform.system}

    # Development
    android-studio
    android-studio-tools
    android-tools
    vscode-fhs
    zed-editor
    lazyssh
    antigravity-ide-fhs
    opencode
    claude-code
    terraform
    azure-cli
    kubectl
    nodejs
    pi-coding-agent

    # Office
    libreoffice
    vagrant
    rclone

    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu-sans
  ];

  # Programs
  programs.nix-ld.enable = true;
  programs.virt-manager.enable = true;
  programs.ssh.extraConfig = ''
    Host *
      SetEnv TERM=xterm-256color
  '';
  programs.openvpn3.enable = true;
  programs.localsend.enable = true;
  programs.localsend.openFirewall = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      # ⚠️ Must be empty, otherwise Oh My Zsh will fight with Starship over the prompt.
      theme = "";
      plugins = [
        "git"
        "sudo"
      ];
    };

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      nixconfedit = "sudo vim /etc/nixos/configuration.nix";
      ssh-arch = "bash $HOME/projects/vagrant-arch/ssh-qemu.sh";
      fullupdate = "sudo git -C /etc/nixos add . && sudo nix flake update --flake /etc/nixos && sudo nixos-rebuild switch --flake /etc/nixos";
    };
  };

  programs.starship = {
    enable = true;
    # Optional: your starship.toml settings here
    # settings = { ... };
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Aaditya Pageni";
        email = "pageniaaditya1@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };
  programs.firefox.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Services
  services.strongswan = {
    enable = false;
    # secrets = [ "ipsec.d/ipsec.nm-l2tp.secrets" ];
  };

  services.libreswan = {
    enable = true;
    # Add this configuration string to override the default "drop" policy
    configSetup = ''
      ikev1-policy=accept
    '';
  };
  services.xl2tpd.enable = true;
  services.power-profiles-daemon.enable = true;
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix-550a;
    };
  };
  services.ollama = {
    enable = true;
    package = pkgs.ollama-vulkan;
  };
  services.flatpak.enable = true;
  services.tailscale.enable = true;
  services.gvfs.enable = true;
  services.accounts-daemon.enable = true;
  services.avahi.enable = true;
  services.avahi.openFirewall = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.printing.enable = true;
  services.fwupd.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  services.displayManager.autoLogin.enable = false;
  services.getty.autologinUser = null;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.dbus.enable = true;

  # Systemd
  systemd.tmpfiles.rules = [
    "d /etc/ipsec.d 0700 root root -"
    "L+ /etc/ipsec.secrets - - - - /etc/ipsec.d/ipsec.nm-l2tp.secrets"
  ];
  systemd.services.gnome-remote-desktop = {
    wantedBy = [ "graphical.target" ];
  };

  # Virtualisation
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///session" = {
      domains = [
        {
          active = true;
          restart = false;
          definition = inputs.nixvirt.lib.domain.writeXML {
            name = "archlinux";
            uuid = "d6dfce9b-fb7e-4796-b916-4941e114c7d8";
            type = "kvm";
            memory = {
              count = 4096;
              unit = "MiB";
            };
            vcpu = {
              count = 4;
            };

            os = {
              type = "hvm";
              arch = "x86_64";
              machine = "pc-q35-11.1";
              boot = [
                { dev = "cdrom"; }
                { dev = "hd"; }
              ];
              bootmenu = {
                enable = true;
              };
            };

            features = {
              acpi = { };
              apic = { };
            };

            cpu = {
              mode = "host-passthrough";
              check = "none";
              migratable = true;
            };

            devices = {
              disk = [
                {
                  type = "file";
                  device = "disk";
                  driver = {
                    name = "qemu";
                    type = "qcow2";
                  };
                  source = {
                    file = "/home/wakizu/vms/archlinux.qcow2";
                  };
                  target = {
                    dev = "vda";
                    bus = "virtio";
                  };
                }
                {
                  type = "file";
                  device = "cdrom";
                  driver = {
                    name = "qemu";
                    type = "raw";
                  };
                  source = {
                    file = "/home/wakizu/.cache/archlinux-2026.09.01-x86_64.iso";
                  };
                  target = {
                    dev = "hdc";
                    bus = "sata";
                  };
                  readonly = true;
                }
              ];

              filesystem = [
                {
                  type = "mount";
                  accessmode = "passthrough";
                  driver = {
                    type = "path";
                    name = "qemu";
                  };
                  source = {
                    dir = "/home/wakizu/shared";
                  };
                  target = {
                    dir = "/root";
                  };
                }
              ];

              interface = [
                {
                  type = "network";
                  mac = {
                    address = "52:54:00:6c:08:5a";
                  };
                  source = {
                    network = "default";
                  };
                  model = {
                    type = "e1000e";
                  };
                }
              ];

              input = [
                {
                  type = "tablet";
                  bus = "usb";
                }
                {
                  type = "mouse";
                  bus = "ps2";
                }
                {
                  type = "keyboard";
                  bus = "ps2";
                }
              ];

              graphics = {
                type = "spice";
                listen = {
                  type = "none";
                };
                image = {
                  compression = "off";
                };
                gl = {
                  enable = false;
                };
              };

              sound = {
                model = "ich6";
              };

              audio = {
                id = 1;
                type = "spice";
              };

              video = {
                model = {
                  type = "qxl";
                  ram = 65536;
                  vram = 65536;
                  vgamem = 16384;
                  heads = 1;
                  primary = true;
                  acceleration = {
                    accel3d = false;
                  };
                };
              };
            };
          };
        }
      ];
    };
  };

  # Nixpkgs
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      gdbuspp = prev.gdbuspp.overrideAttrs (old: {
        mesonFlags = (old.mesonFlags or [ ]) ++ [ "-Dwerror=false" ];
      });
    })
  ];
  system.stateVersion = "25.11";
}
