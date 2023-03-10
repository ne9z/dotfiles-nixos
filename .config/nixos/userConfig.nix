{ config, pkgs, ... }:
let
  myConfig.wlanNetworks = [{
    name = "name";
    psk = "psk";
  }];
  myConfig.uniPass = (if (builtins.pathExists /home/yc/.config/tubpass) then
    (builtins.readFile /home/yc/.config/tubpass)
  else
    "");
in {

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      # latest successful build see here
      # https://hydra.nix-community.org/job/emacs-overlay/stable/emacsPgtk
      url =
        "https://github.com/nix-community/emacs-overlay/archive/8f8c03401b8ce5c6a98790dd2ec4add9db5ef633.tar.gz";
    }))
  ];
  nix = {
    settings = {
      substituters =
        [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "emacs";
    newSession = true;
    secureSocket = true;
    extraConfig = ''
      unbind C-b
      set -g prefix f7
      bind -N "Send the prefix key through to the application" \
        f7 send-prefix

      bind-key -T prefix t new-session
    '';
  };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-esr;
    policies = {
      "3rdparty" = {
        Extensions = {
          "uBlock0@raymondhill.net" = {
            adminSettings = {
              advancedUserEnabled = true;
              dynamicFilteringString = ''
                behind-the-scene * * noop
                behind-the-scene * inline-script noop
                behind-the-scene * 1p-script noop
                behind-the-scene * 3p-script noop
                behind-the-scene * 3p-frame noop
                behind-the-scene * image noop
                behind-the-scene * 3p noop'';
              hostnameSwitchesString = ''
                no-large-media: behind-the-scene false
                no-csp-reports: * true
                no-scripting: * true
                no-scripting: isis.tu-berlin.de false
                no-scripting: moseskonto.tu-berlin.de false
                no-scripting: meet.jit.si false'';
            };
          };
        };
      };
      # captive portal enabled for connecting to free wifi
      CaptivePortal = true;
      DisableBuiltinPDFViewer = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableFormHistory = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayMenuBar = "never";
      DNSOverHTTPS = { Enabled = false; };
      EncryptedMediaExtensions = { Enabled = false; };
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          installation_mode = "force_installed";
          install_url =
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        };
      };
      FirefoxHome = {
        SponsoredTopSites = false;
        Pocket = false;
        SponsoredPocket = false;
      };
      HardwareAcceleration = true;
      Homepage = { StartPage = "none"; };
      NetworkPrediction = false;
      NewTabPage = false;
      NoDefaultBookmarks = false;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      PDFjs = { Enabled = false; };
      Permissions = {
        Location = { BlockNewRequests = true; };
        Notifications = { BlockNewRequests = true; };
      };
      PictureInPicture = { Enabled = false; };
      PopupBlocking = { Default = false; };
      PromptForDownloadLocation = true;
      SanitizeOnShutdown = true;
      SearchSuggestEnabled = false;
      ShowHomeButton = true;
      UserMessaging = {
        WhatsNew = false;
        SkipOnboarding = true;
      };
    };
  };
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];
      max_clients = 250;
      # https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      server_names = [
        "dns0"
        "scaleway-fr"
        "google"
        "google-ipv6"
        "cloudflare"
        "dct-de1"
        "dns.digitalsize.net"
        "dns.digitalsize.net-ipv6"
        "dns.watch"
        "dns.watch-ipv6"
        "dnscrypt-de-blahdns-ipv4"
        "dnscrypt-de-blahdns-ipv6"
        "doh.ffmuc.net"
        "doh.ffmuc.net-v6"
        "he"
        "dnsforge.de"
        "bortzmeyer"
        "bortzmeyer-ipv6"
        "circl-doh"
        "circl-doh-ipv6"
        "cloudflare-ipv6"
        "dns.digitale-gesellschaft.ch-ipv6"
        "dns.digitale-gesellschaft.ch"
      ];
      ipv4_servers = true;
      ipv6_servers = false;
      dnscrypt_servers = true;
      doh_servers = true;
      odoh_servers = false;
      require_dnssec = false;
      require_nolog = true;
      require_nofilter = true;
      disabled_server_names = [ ];
      force_tcp = false;
      http3 = false;
      timeout = 5000;
      keepalive = 30;
      cert_refresh_delay = 240;
      bootstrap_resolvers = [ "9.9.9.11:53" "8.8.8.8:53" ];
      ignore_system_dns = true;
      netprobe_timeout = 60;
      netprobe_address = "9.9.9.9:53";
      log_files_max_size = 10;
      log_files_max_age = 7;
      log_files_max_backups = 1;
      block_ipv6 = false;
      block_unqualified = true;
      block_undelegated = true;
      reject_ttl = 10;
      cache = true;
      cache_size = 4096;
      cache_min_ttl = 2400;
      cache_max_ttl = 86400;
      cache_neg_min_ttl = 60;
      cache_neg_max_ttl = 600;
      sources.public-resolvers = {
        urls = [
          "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md"
          "https://ipv6.download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "public-resolvers.md";
        minisign_key =
          "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
      sources.relays = {
        urls = [
          "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
          "https://ipv6.download.dnscrypt.info/resolvers-list/v3/relays.md"
        ];
        cache_file = "relays.md";
        minisign_key =
          "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
      query_log.file = "query.log";
      query_log.format = "tsv";
      anonymized_dns.skip_incompatible = false;
      broken_implementations.fragments_blocked = [
        "cisco"
        "cisco-ipv6"
        "cisco-familyshield"
        "cisco-familyshield-ipv6"
        "cleanbrowsing-adult"
        "cleanbrowsing-adult-ipv6"
        "cleanbrowsing-family"
        "cleanbrowsing-family-ipv6"
        "cleanbrowsing-security"
        "cleanbrowsing-security-ipv6"
      ];
    };
    upstreamDefaults = false;
  };
  networking.nameservers = [ "::1" ];
  environment.etc = (builtins.listToAttrs (map (wlanName: {
    name = "NetworkManager/system-connections/${wlanName.name}.nmconnection";
    value = {
      enable = true;
      #networkmanager demands secure permission
      mode = "0600";
      text = ''
        [connection]
        id=${wlanName.name}
        type=wifi

        [wifi]
        mode=infrastructure
        ssid=${wlanName.name}

        [wifi-security]
        auth-alg=open
        key-mgmt=wpa-psk
        psk=${wlanName.psk}
      '';
    };
  }) myConfig.wlanNetworks)) // {
    "NetworkManager/system-connections/eduroam.nmconnection" = {
      enable = true;
      mode = "0600";
      text = ''
        [connection]
        id=eduroam
        type=wifi

        [wifi]
        mode=infrastructure
        ssid=eduroam

        [wifi-security]
        auth-alg=open
        key-mgmt=wpa-eap

        [802-1x]
        eap=peap;
        identity=user@tu-berlin.de
        password=
        phase2-auth=mschapv2
      '';
    };
  };
  programs.gnupg.agent = {
    enable = true;
    # must use graphical pinentry, else would mess up terminal
    pinentryFlavor = "qt";
  };
  networking = {
    openconnect.interfaces = { };
    networkmanager = {
      enable = true;
      wifi = { macAddress = "random"; };
    };
  };
  services.yggdrasil = {
    enable = true;
    openMulticastPort = false;
    settings.Peers = [
      #curl https://publicpeers.neilalexander.dev/ | grep "<td id='status'>online</td><td id='reliability'>reliable</td>" | sed "s|</td><td id='version'>.*|\"|" | sed "s|<td id='address'>|\"|" > peers
      "tls://192.99.145.61:58226"
      "tls://[2607:5300:201:3100::50a1]:58226"
      "tls://[2a01:4f9:2a:60c::2]:18836"
      "tls://95.216.5.243:18836"
      "tls://[2a01:4f9:6a:49e7:1068:cf52:a4aa:1]:8443?key=9d0bdac2e339fd57bcc9af5c4d5f2ecd98e724d32d56c239a5cdec580ab0a580"
      "tls://94.23.116.184:1944?key=9d0bdac2e339fd57bcc9af5c4d5f2ecd98e724d32d56c239a5cdec580ab0a580"
      "tls://[2a01:4f9:c010:664d::1]:61995"
      "tls://65.21.57.122:61995"
      "tls://152.228.216.112:23108"
      "tls://51.15.204.214:54321"
      "tcp://51.15.204.214:12345"
      "tls://51.255.223.60:54232"
      "tls://[2001:41d0:304:200::ace3]:23108"
      "tls://[2001:41d0:2:c44a:51:255:223:60]:54232"
      "tcp://193.107.20.230:7743"
      "tls://94.23.116.184:1945?key=4308ccec1a3a9c68c4f376000cf9c7084c1daae4921eb123cd93b6eb96fd8d84"
      "tls://[2a01:4f8:13a:19e5:103a:263e:890c:1]:8443?key=4308ccec1a3a9c68c4f376000cf9c7084c1daae4921eb123cd93b6eb96fd8d84"
      "tls://23.137.249.65:443"
      "tls://94.103.82.150:8080"
      "tls://54.37.137.221:11129"
      "tls://[2a03:cfc0:8004::000b:0cf2]:8443?key=4696a1466c69110dfa6060a0be368b1049f1463906a75b815967efa6d374226e"
      "tls://185.165.169.234:8443"
      "tcp://185.165.169.234:8880"
      "tcp://77.37.218.131:12402"
      "tcp://[2a00:b700::a:279]:12402"
      "tcp://45.95.202.21:12403"
      "tcp://45.147.200.202:12402"
      "tcp://[2a09:5302:ffff::992]:12403"
      "tls://[2a00:b700::a:279]:443"
      "tls://45.95.202.21:443"
      "tls://[2a09:5302:ffff::992]:443"
      "tls://77.37.218.131:443"
      "tls://45.147.200.202:443"
      "tls://45.95.202.91:65535"
      "tls://[2a09:5302:ffff::aca]:65535"
      "tls://185.103.109.63:65535"
      "tls://[2a09:5302:ffff::ac9]:65535"
      "tls://158.101.229.219:17001"
      "tcp://158.101.229.219:17002"
      "tcp://[2603:c023:8001:1600:35e0:acde:2c6e:b27f]:17002"
      "tls://[2603:c023:8001:1600:35e0:acde:2c6e:b27f]:17001"
      "tls://185.130.44.194:7040"
      "tls://[2a07:e01:105:444:c634:6bff:feb5:6e28]:7040"
      "tcp://193.111.114.28:8080"
      "tls://193.111.114.28:1443"
      "tls://185.175.90.87:43006"
      "tls://51.38.64.12:28395"
      "tls://[2a10:4740:40:0:2222:3f9c:b7cf:1]:43006"
      "tls://108.175.10.127:61216"
      "tcp://50.236.201.218:56088"
      "tls://102.223.180.74:993"
      "tls://[2605:9f80:2000:64::2]:7040"
      "tls://167.160.89.98:7040"
    ];
  };
}
