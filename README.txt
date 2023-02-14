NixOS dotfiles

This repo contains the complete NixOS configuration
running on my laptop.

Features
==================================================

- System configuration managed as part of repo at
  .config/nixos 
- Root on ZFS with multi-disk support
- Immutable root file system at /
- Immutable user home at /home/user
- pure Wayland with Sway Window Manager
- Xserver disabled
- custom Firefox config for better privacy protection
- GNU/Emacs
- GNU/Emacs-based keybinding for programs
- LaTeX support (I major in mathematics)
- Wayland screen sharing with Firefox and WebRTC
- WiFi declaratively managed by NetworkManager
- tmux terminal multiplexer enabled for terminal emulators
- stubby DNS resolver for better privacy
- i2pd, yggdrasil for an open Internet

Usage
==================================================

Install NixOS as described in .config/nixos/inst.sh

Reboot then login as normal user.  Execute "sway".

After launching sway, you will see an empty screen with
the default wallpaper.  Press and hold Super key (the
logo key) on your keyboard to show status bar.  Press
Super+Return to launch foot terminal emulator.  View all
keybindings with:

   e ~/.config/sway/config

If you are new to Emacs, press Backspace, then press t
to read Emacs tutorial.

Launch Firefox with Super+z.
