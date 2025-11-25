# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
    sha256 = "026rvynmzmpigax9f8gy9z67lsl6dhzv2p6s8wz4w06v3gjvspm1";
  };
in
{
  imports =
    [ 
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Ignore lid close when plugged in
  services.logind = {
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitch = "suspend";
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };


  # Automatically clean
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than +3";  # Keep last 3 generations, delete older
  };
  nix.settings.auto-optimise-store = true;

  # Define a user account.
  users.users.millankumar = {
    isNormalUser = true;
    description = "Millan Kumar";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [];
  };
  # Home manager
  home-manager.users.millankumar = { ... }: {
    # bash
    programs.bash = {
      enable = true;
      profileExtra = ''
        if [[ $(tty) == /dev/tty1 ]]; then
          cmatrix
        fi
      '';
      shellAliases = {
        ls = "eza -al";
        snrsf = "sudo nixos-rebuild switch --flake .";
      };
    };
    # helix
    programs.helix = {
      enable = true;

      # Main Helix settings (from config.toml)
      settings = {
        theme = "rose_pine_moon_trans";
        editor = {
          true-color = true;
          cursorline = true;
          auto-format = false;
          idle-timeout = 0;
          completion-trigger-len = 1;
          end-of-line-diagnostics = "hint";
          rulers = [80];
          bufferline = "always";

          statusline = {
            left = ["mode" "spinner" "version-control"];
            center = ["file-name" "read-only-indicator" "file-modification-indicator"];
            right = [
              "diagnostics" "selections" "register"
              "position" "position-percentage"
              "file-encoding" "file-type"
            ];
            separator = "|";
            mode = {
              normal = "NORMAL";
              insert = "INSERT";
              select = "SELECT";
            };
          };

          lsp.display-messages = true;

          indent-guides = {
            render = true;
            character = "▏";
            skip-levels = 1;
          };

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          soft-wrap.enable = true;

          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "warning";
          };
        };

        # Keybindings
        keys = {
          normal = {
            "C-q" = ":buffer-close";
            "C-j" = ["move_visual_line_down" "scroll_down"];
            "C-k" = ["move_visual_line_up" "scroll_up"];

            # " " = {
            #   "S-e" = "file_explorer";
            #   "e" = "file_explorer_in_current_buffer_directory";
            # };
          };
        };
      };

      # Language configuration (from languages.toml)
      languages = {
        language = [
          {
            name = "java";
            indent = { tab-width = 4; unit = " "; };
          }
          {
            name = "python";
            language-servers = [ { name = "python-lsp"; } ];
          }
          {
            name = "c";
            indent = { tab-width = 2; unit = "  "; };
          }
        ];

        language-server = {
          python-lsp = {
            command = "pyright-langserver";
            args = ["--stdio"];
            config = "";
          };
        };
      };

      # Custom themes
      themes.rose_pine_moon_trans = {
        inherits = "rose_pine_moon";
        ui.background = { };
      };
    };
    # git/gh
    programs.git = {
      enable = true;
      userName = "<name>";
      userEmail = "<email>";
      signing = {
        key = "<key>";
        signByDefault = true;
      };
    };
    programs.gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
      };
    };
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      # pinentryPackage = pkgs.pinentry-curses; # or another suitable pinentry
    };
    

    # You should not change this value, even if you update Home Manager. If you do 
    # want to update the value, then make sure to first check the Home Manager 
    # release notes. 
    home.stateVersion = "24.05"; # Please read the comment before changing. 
  };
  home-manager.backupFileExtension = "backup";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Nix
    nixfmt-rfc-style

    # Editors
    vim
    helix

    # Code
    git
    gcc
    rustup
    nodejs
    elixir
    erlang
    go

    # Tools
    # wget
    eza
    cmatrix
    htop

    # Services
    cockpit
    docker
    # sysinfoWeb
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22   # ssh
    3000 # MultiBoard
    3003 # WhippleHillPlus
    3004 # TranscriberPlus
    3005 # ollama-webui
    3011 # Ollama
    7032 # sysinfo-web
    9090 # cockpit
  ];
  networking.firewall.allowedUDPPorts = [
    22   # ssh
    3000 # MultiBoard
    3003 # WhippleHillPlus
    3004 # TranscriberPlus
    3005 # ollama-webui
    3011 # Ollama
    7032 # sysinfo-web
    9090 # cockpit
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Autologin so cmatrix can be started
  services.getty.autologinUser = "millankumar";
  # Cockpit
  services.cockpit = {
    enable = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };
    allowed-origins = [ "*" ];
  };
  # Ollama
  services.ollama = {
    enable = true;
    port = 3011;
    loadModels = [
      "qwen3:0.6b"
      "deepseek-r1:1.5b"
      "deepseek-r1:7b"
      "gemma3:4b"
      "qwen3-vl:8b"
    ];
  };
  # ollama open-webui
  services.open-webui = {
    enable = true;
    port = 3005;
    host = "0.0.0.0";
    environment = {
      OLLAMA_API_BASE_URL = "http://127.0.0.1:3011";
    };
  };
  # Docker
  virtualisation.docker = {
    enable = true;
  };
  # TranscriberPlus
  systemd.services.TranscriberPlus = {
    description = "Start TranscriberPlus";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment="PATH=/run/current-system/sw/bin:/usr/bin:/bin";
      ExecStart = "/home/millankumar/code/TranscriberPlus/run.sh";
      Type = "simple";
      Restart = "always";
      Requires = [ "docker.service" ];
      After = [ "docker.service" ];
    };
  };
  # MultiBoard
  systemd.services.MultiBoard = {
    description = "Start MultiBoard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment="PATH=/run/current-system/sw/bin:/usr/bin:/bin";
      ExecStart = "/home/millankumar/code/MultiBoard/run.sh";
      Type = "simple";
      Restart = "always";
    };
  };
  # sysinfo-web
  systemd.services.sysinfo-web = {
    description = "Start sysinfo-web";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/home/millankumar/.cargo/bin/sysinfo-web 0.0.0.0:7032";
      Type = "simple";
      Restart = "always";
    };
  };
  # ImageConvertBot
  systemd.services.ImageConvertBot = {
    description = "Start ImageConvertBot";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment="PATH=/run/current-system/sw/bin:/usr/bin:/bin";
      ExecStart = "/home/millankumar/code/ImageConvertBot/run.sh";
      Type = "simple";
      Restart = "always";
      Requires = [ "docker.service" ];
      After = [ "docker.service" ];
    };
  };
  # NPC
  systemd.services.NPC = {
    description = "Start NPC";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment="PATH=/run/current-system/sw/bin:/usr/bin:/bin";
      ExecStart = "/home/millankumar/code/NPC/run.sh";
      Type = "simple";
      Restart = "always";
    };
  };
  # WhippleHillPlus
  systemd.services.WhippleHillPlus = {
    description = "Start WhippleHillPlus";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment="PATH=/run/current-system/sw/bin:/usr/bin:/bin";
      ExecStart = "/home/millankumar/code/WhippleHillPlus/run.sh";
      Type = "simple";
      Restart = "always";
    };
  };
  # ollama-webui
  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  #     open-webui = {
  #       image = "ghcr.io/open-webui/open-webui:main";
  #       ports = ["3005:8080"];
  #       extraOptions = [
  #         "--add-host=host.docker.internal:host-gateway"
  #         # "--restart=always"
  #       ];
  #       volumes = [
  #         "open-webui:/app/backend/data"
  #       ];
  #       environment = {
  #         OLLAMA_API_BASE_URL = "http://127.0.0.1:3011";
  #       };
  #     };
  #   };
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
