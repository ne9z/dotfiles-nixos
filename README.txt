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
- dnscrypt2-proxy DNS resolver for better privacy
- i2pd, yggdrasil for an open Internet

Usage
==================================================

Download NixOS live media at

  https://nixos.org/download.html#download-nixos

then boot computer from the live media.

Connect to the internet, then clone this repo to /root/

Install NixOS as described in .config/nixos/inst.sh

Reboot then login as normal user.  Default encryption
password is "poolpass", user name is "user" and password
is "test".

Configure network with

  nmtui

After establishing internet connection, execute "sway".

After launching sway, you will see an empty screen with
the default wallpaper.  Press and hold Super key (the
logo key) on your keyboard to show status bar.  Press
Super+Return (press and hold Super, then press and
release Return, then release Super) to launch foot
terminal emulator.  View all keybindings with:

   e ~/.config/sway/config # press return

If you are new to Emacs, press and release Backspace,
then press t to read Emacs tutorial.

Launch Firefox with Super+z.

Appendix: Connecting to a network with Captive Portal
==================================================

Sometimes we might need to connect to a public wireless
network with captive portal: the user is either required
to enter credentials or agreeing to a Usage Agreement
before internet access is granted.  The method is
usually hijacking HTTP requests or DNS requests to
redirect to the captive portal page.

Problem: the config documented in this repo enables
HTTPS-only mode for Firefox and DNS-over-TLS is enforced
by the local dnscrypt2-proxy DNS resolver.  We need to
temporarily workaround these security measures in order
to access captive portal page.

Step 1.
Connect to a public WiFi network using `nmtui'

Step 2.
Show the default DNS server on this public network, with

    nmcli connection show _SSID_NAME_ | grep IP4
    # output
    IP4.DNS[1]:      130.149.7.7
    IP4.DNS[2]:      192.129.31.50


Step 3.
Prepend one of the default DNS servers to
/etc/resolv.conf:

    nano /etc/resolv.conf
    # add to the beginning of this file
    nameserver 130.149.7.7
    # redirect DNS query to dnscrypt2-proxy
    nameserver ::1

Step 4.
Launch Firefox and visit:

    http://detectportal.firefox.com/canonical.html

You should be automatically redirected to the Captive
Portal page provided by the public network.  Follow
on-screen instructions to continue.  Enable JavaScript
if necessary. 
