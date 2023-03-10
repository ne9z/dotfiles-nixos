# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, lib, pkgs, modulesPath, ... }:

let
  zfsRoot.partitionScheme = {
    biosBoot = "-part5";
    efiBoot = "-part1";
    swap = "-part4";
    bootPool = "-part2";
    rootPool = "-part3";
  };
  zfsRoot.devNodes =
    "/dev/disk/by-id/"; # MUST have trailing slash! /dev/disk/by-id/
  zfsRoot.bootDevices = (import ./machine.nix).bootDevices;
  zfsRoot.mirroredEfi = "/boot/efis/";
  zfsRoot.myUser = "yc";
  myPass-store =
    pkgs.pass.withExtensions (exts: [ exts.pass-otp exts.pass-import ]);
  mytex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
    # https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/tools/typesetting/tex/texlive/pkgs.nix
      scheme-basic dvisvgm dvipng # for preview and export as html
      latexmk wrapfig amsmath ulem collection-langgerman collection-mathscience
      ### charter font and dependencies
      charter xcharter xcharter-math mathdesign xkeyval ly1
      ###
      hyperref capt-of;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  });
  myemacs = (import ./emacs.nix { inherit pkgs; });
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    <nixpkgs/nixos/modules/profiles/hardened.nix>
    ./userConfig.nix
  ];
  systemd.services.zfs-mount.enable = false;

  environment.systemPackages = with pkgs;
    [
      #   vim
      ## Do not forget to add an editor to edit configuration.nix!
      ## The Nano editor is also installed by default.
      #   wget
    ];

  services.emacs = {
    enable = true;
    package = myemacs;
    defaultEditor = false;
    install = false;
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  networking.domain = "lan";

  # List services that you want to enable:
  console.useXkbConfig = true;
  services.xserver.extraLayouts = {
    "${zfsRoot.myUser}" = {
      description = "${zfsRoot.myUser} layout.";
      languages = [ "eng" ];
      symbolsFile = ./keymap/${zfsRoot.myUser}-symbols;
    };
  };
  services.xserver.layout = "${zfsRoot.myUser}";
  networking.hostName = (import ./machine.nix).hostName;

  # Enable the OpenSSH daemon.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
    };
  };
  security = {
    doas.enable = true;
    sudo.enable = false;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  users.mutableUsers = false;
  hardware.opengl = {
    extraPackages = with pkgs; [ vaapiIntel intel-media-driver ]; # is immature
    enable = true;
  };
  services = {
    blueman.enable = true;
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
      '';
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
    };
    udisks2.enable = true; # for mounting disk images
    gvfs.enable = true;
  };
  nixpkgs.config = { allowUnfree = false; };
  nix.gc = {
    automatic = true;
    options = "--delete-old";
  };
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  environment.variables = {
    XKB_DEFAULT_LAYOUT = "${zfsRoot.myUser}";
    EDITOR = "emacsclient --alternate-editor= --create-frame";
  };

  programs.sway = {
    extraSessionCommands = ''
      # use vulkan for wlroots/sway
      # has bugs
      #export WLR_RENDERER=vulkan
      export MOZ_ENABLE_WAYLAND=1
      export QT_WAYLAND_FORCE_DPI=physical
      export QT_QPA_PLATFORMTHEME=qt5ct
      export QT_QPA_PLATFORM=wayland-egl
      export XCURSOR_THEME=Adwaita
      export _JAVA_AWT_WM_NONREPARENTING=1
      if ! test -f $HOME/.config/sway/config; then
        git -C $HOME reset --hard
        if test -f $HOME/.bash_login; then
          source $HOME/.bash_login
        fi
        home-manager switch
      fi
    '';
    enable = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      foot
      gammastep
      brightnessctl
      fuzzel
      grim
      wpa_supplicant_gui
      w3m
      gsettings-desktop-schemas
      gnome.dconf-editor
      pavucontrol
      mako
      waybar
      wl-clipboard
      qt5ct
      adwaita-qt
      vulkan-validation-layers
    ];
  };
  programs.sway.wrapperFeatures.base = true;
  programs.sway.wrapperFeatures.gtk = true;

  # For Firefox Screensharing with Sway
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  time.timeZone = "Europe/Berlin";

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Source Code Pro" ];
    sansSerif = [ "Noto Sans Display" ];
    serif = [ "Noto Sans Display" ];
  };
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    source-code-pro
  ];

  services.i2pd = {
    enable = true;
    enableIPv4 = true;
    enableIPv6 = true;
    bandwidth = 4096;
    port = 29392;
    proto = {
      http = {
        port = 7071;
        enable = true;
      };
      socksProxy.port = 4447;
      socksProxy.enable = true;
    };
    outTunnels = { };
    floodfill = true;
    inTunnels = { };
  };
  environment.shellAliases = {
    e = "emacsclient --alternate-editor= --create-frame";
    Nsu =
      "cp -r /home/${zfsRoot.myUser}/.config/nixos/ /etc&& nixos-rebuild switch --upgrade";
    Nbu =
      "cp -r /home/${zfsRoot.myUser}/.config/nixos/ /etc&& nixos-rebuild boot --upgrade";
    Ns =
      "cp -r /home/${zfsRoot.myUser}/.config/nixos/ /etc&& nixos-rebuild switch";
    Nb =
      "cp -r /home/${zfsRoot.myUser}/.config/nixos/ /etc&& nixos-rebuild boot";
    tm = "tmux attach-session";
  };

  hardware.opentabletdriver.enable = false;
  programs.htop.enable = true;
  security.lockKernelModules = false;
  services.openssh = {
    #opens firewall ports automatically
    #used to exchange files with phone
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
  networking.firewall.enable = true;
  security.allowSimultaneousMultithreading = true;
  zramSwap.enable = true;
  environment.memoryAllocator.provider = "libc";

  programs.git.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
    "ehci_pci"
    "nvme"
    "uas"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems = {
    "/" = {
      device = "rpool/nixos/empty";
      fsType = "zfs";
      options = [ "X-mount.mkdir" ];
    };

    "/oldroot" = {
      device = "rpool/nixos/root";
      fsType = "zfs";
      options = [ "X-mount.mkdir" ];
      neededForBoot = true;
    };

    "/nix" = {
      device = "/oldroot/nix";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" ];
    };

    "/oldroot/home" = {
      device = "rpool/nixos/home";
      fsType = "zfs";
      options = [ "X-mount.mkdir" ];
    };

    "/etc/nixos" = {
      device = "/oldroot/etc/nixos";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" ];
    };

    "/var/lib" = {
      device = "rpool/nixos/var/lib";
      fsType = "zfs";
      options = [ "X-mount.mkdir" ];
    };

    "/var/log" = {
      device = "rpool/nixos/var/log";
      fsType = "zfs";
      options = [ "X-mount.mkdir" ];
    };

    "/boot" = {
      device = "bpool/nixos/root";
      fsType = "zfs";
      options = [ "X-mount.mkdir" ];
    };

    "/home/${zfsRoot.myUser}/.git" = {
      device = "/oldroot/home/${zfsRoot.myUser}/.git";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" "X-mount.owner=1001" ];
    };

    "/home/${zfsRoot.myUser}/.gnupg" = {
      device = "/oldroot/home/${zfsRoot.myUser}/.gnupg";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" "X-mount.owner=1001" ];
    };

    "/home/${zfsRoot.myUser}/.password-store" = {
      device = "/oldroot/home/${zfsRoot.myUser}/.password-store";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" "X-mount.owner=1001" ];
    };

    "/home/${zfsRoot.myUser}/.ssh" = {
      device = "/oldroot/home/${zfsRoot.myUser}/.ssh";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" "X-mount.owner=1001" ];
    };

    "/home/${zfsRoot.myUser}/Downloads" = {
      device = "/oldroot/home/${zfsRoot.myUser}/Downloads";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" "X-mount.owner=1001" ];
    };

    "/home/${zfsRoot.myUser}/Documents" = {
      device = "/oldroot/home/${zfsRoot.myUser}/Documents";
      fsType = "none";
      options = [ "bind" "X-mount.mkdir" "X-mount.owner=1001" ];
    };

  } // (builtins.listToAttrs (map (diskName: {
    name = zfsRoot.mirroredEfi + diskName + zfsRoot.partitionScheme.efiBoot;
    value = {
      device = zfsRoot.devNodes + diskName + zfsRoot.partitionScheme.efiBoot;
      fsType = "vfat";
      options = [
        "x-systemd.idle-timeout=1min"
        "x-systemd.automount"
        "noauto"
        "nofail"
      ];
    };
  }) zfsRoot.bootDevices));

  users.users."${zfsRoot.myUser}" = {
    description = "given-name family-name";
    isNormalUser = true;
    createHome = true;
    uid = 1001;
    extraGroups = [ "wheel" "libvirtd" "networkmanager" ];
    initialPassword = "test";
    #initialHashedPassword = "";
    packages = with pkgs; [
      gpxsee
      gnome.eog
      yt-dlp
      android-file-transfer
      gnuplot_qt
      auctex
      zathura
      s-tui
      mpv
      transmission-remote-gtk
      virt-manager
      pdftk
      ffmpeg
      tor-browser-bundle-bin
      wf-recorder
      qrencode
      mytex
      ghostscript # ghostscript for preview-latex in emacs
      xournalpp
      xdg-utils
      p7zip
      zip
      isync
      notmuch
      msmtp
      home-manager
      python3
      nixfmt
      # passwords
      myPass-store
    ];
  };
  programs.gnome-disks.enable = true;
  swapDevices = (map (diskName: {
    device = zfsRoot.devNodes + diskName + zfsRoot.partitionScheme.swap;
    discardPolicy = "both";
    randomEncryption = {
      enable = true;
      allowDiscards = true;
    };
  }) zfsRoot.bootDevices);

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.networkmanager.enable = true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "abcd1234";
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.efi.efiSysMountPoint = with builtins;
    (zfsRoot.mirroredEfi + (head zfsRoot.bootDevices)
      + zfsRoot.partitionScheme.efiBoot);
  boot.zfs.devNodes = zfsRoot.devNodes;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.zfsSupport = true;
  boot.loader.grub.extraInstallCommands = with builtins;
    (toString (map (diskName:
      "cp -r " + config.boot.loader.efi.efiSysMountPoint + "/EFI" + " "
      + zfsRoot.mirroredEfi + diskName + zfsRoot.partitionScheme.efiBoot + "\n")
      (tail zfsRoot.bootDevices)));
  boot.loader.grub.devices =
    (map (diskName: zfsRoot.devNodes + diskName) zfsRoot.bootDevices);
  boot.initrd.postDeviceCommands = ''
    if ! grep -q zfs_no_rollback /proc/cmdline; then
      zpool import -N rpool
      zfs rollback -r rpool/nixos/empty@start
      zpool export -a
    fi
  '';
}

