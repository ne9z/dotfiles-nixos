{ config, pkgs, ... }:
let
  myConfig.wlanNetworks = [
    {
      name = "name";
      psk = "psk";
    }
  ];
in {
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
    package = pkgs.firefox;
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
      Preferences = {
        "privacy.resistFingerprinting" = {
          Value = true;
          Status = "locked";
        };
        "webgl.min_capability_mode" = {
          Value = true;
          Status = "locked";
        };
        "apz.gtk.touchpad_pinch.enabled" = {
          Value = false;
          Status = "locked";
        };
        "browser.backspace_action" = {
          Value = 0;
          Status = "locked";
        };
        "browser.display.use_document_fonts" = {
          Value = 0;
          Status = "locked";
        };
        "browser.uidensity" = {
          Value = 1;
          Status = "locked";
        };
        "dom.security.https_only_mode" = {
          Value = true;
          Status = "locked";
        };
        "general.smoothScroll" = {
          Value = false;
          Status = "locked";
        };
        "media.ffmpeg.vaapi.enabled" = {
          Value = true;
          Status = "locked";
        };
        "media.ffvpx.enabled" = {
          Value = false;
          Status = "locked";
        };
        "media.ffmpeg.low-latency.enabled" = {
          Value = true;
          Status = "locked";
        };
        "media.navigator.mediadatadecoder_vpx_enabled" = {
          Value = true;
          Status = "locked";
        };
        "browser.chrome.site_icons" = {
          Value = false;
          Status = "locked";
        };
        "browser.tabs.firefox-view" = {
          Value = false;
          Status = "locked";
        };
        "browser.contentblocking.category" = {
          Value = "strict";
          Status = "locked";
        };
      };
    };
  };
  services.stubby = {
    enable = true;
    settings = {
      # update tls dns servers
      # https://raw.githubusercontent.com/getdnsapi/stubby/master/stubby.yml.example
      resolution_type = "GETDNS_RESOLUTION_STUB";
      # strict mode
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
      listen_addresses = [ "127.0.0.1" "0::1" ];
      idle_timeout = 9000;
      round_robin_upstreams = 1;
      upstream_recursive_servers = [
        {
          address_data = "185.49.141.37";
          tls_auth_name = "getdnsapi.net";
          tls_pubkey_pinset = [{
            digest = "sha256";
            value = "foxZRnIh9gZpWnl+zEiKa0EJ2rdCGroMWm02gaxSc9Q=";
          }];
        }

        ########################### OPTIONAL UPSTREAMS  ###############################
        ###### IPv4 addresses ######
        ## Anycast services ###
        # Quad 9 'secure' service - Filters, does DNSSEC, doesn't send ECS
        {
          address_data = "9.9.9.9";
          tls_auth_name = "dns.quad9.net";
        }
        {
          address_data = "149.112.112.112";
          tls_auth_name = "dns.quad9.net";
        }
        # Quad 9 'secure w/ECS' service - Filters, does DNSSEC, DOES send ECS
        # See the entry for `edns_client_subnet_private` for more details on ECS
        {
          address_data = "9.9.9.11";
          tls_auth_name = "dns11.quad9.net";
        }
        {
          address_data = "149.112.112.11";
          tls_auth_name = "dns11.quad9.net";
        }
        # Quad 9 'insecure' service - No filtering, no DNSSEC, doesn't send ECS
        {
          address_data = "9.9.9.10";
          tls_auth_name = "dns10.quad9.net";
        }
        {
          address_data = "149.112.112.10";
          tls_auth_name = "dns10.quad9.net";
        }
        # Cloudflare 1.1.1.1 and 1.0.0.1
        # (NOTE = recommend reducing idle_timeout to 9000 if using Cloudflare)
        {
          address_data = "1.1.1.1";
          tls_auth_name = "cloudflare-dns.com";
        }
        {
          address_data = "1.0.0.1";
          tls_auth_name = "cloudflare-dns.com";
        }
        # Google
        {
          address_data = "8.8.8.8";
          tls_auth_name = "dns.google";
        }
        {
          address_data = "8.8.4.4";
          tls_auth_name = "dns.google";
        }
        # Adguard Default servers
        {
          address_data = "176.103.130.130";
          tls_auth_name = "dns.adguard.com";
        }
        {
          address_data = "176.103.130.131";
          tls_auth_name = "dns.adguard.com";
        }
        # Comcast
        {
          address_data = "96.113.151.145";
          tls_auth_name = "dot.xfinity.com";
        }
        # dns.neutopia.org
        {
          address_data = "89.234.186.112";
          tls_auth_name = "dns.neutopia.org";
          tls_pubkey_pinset = [{
            digest = "sha256";
            value = "wTeXHM8aczvhRSi0cv2qOXkXInoDU+2C+M8MpRyT3OI=";
          }];
        }
        # Fondation RESTENA (NREN for Luxembourg)
        {
          address_data = "158.64.1.29";
          tls_auth_name = "kaitain.restena.lu";
          tls_pubkey_pinset = [{
            digest = "sha256";
            value = "7ftvIkA+UeN/ktVkovd/7rPZ6mbkhVI7/8HnFJIiLa4=";
          }];
        }
        # NIC Chile

        # Foundation for Applied Privacy 
        {
          address_data = "146.255.56.98";
          tls_auth_name = "dot1.applied-privacy.net";
        }

        ###### Servers that listen on port 443 (IPv4 and IPv6) #######
        ## Test servers ###
        # The getdnsapi.net server
        {
          address_data = "185.49.141.37";
          tls_port = 443;
          tls_auth_name = "getdnsapi.net";
          tls_pubkey_pinset = [{
            digest = "sha256";
            value = "foxZRnIh9gZpWnl+zEiKa0EJ2rdCGroMWm02gaxSc9Q=";
          }];
        }

        # dns.neutopia.org
        {
          address_data = "89.234.186.112";
          tls_port = 443;
          tls_auth_name = "dns.neutopia.org";
          tls_pubkey_pinset = [{
            digest = "sha256";
            value = "wTeXHM8aczvhRSi0cv2qOXkXInoDU+2C+M8MpRyT3OI=";
          }];
        }
      ];
    };
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

        [wifi-security]
        auth-alg=open
        key-mgmt=wpa-eap

        [wifi]
        ssid=eduroam
        mode=infrastructure
        security=802-11-wireless-security

        [802-1x]
        eap=peap
        identity=
        phase2-auth=mschapv2
        password=
        domain-suffix-match=
        anonymous-identity=
        ca-path=
      '';
    };
  };
  networking = {
    openconnect.interfaces = {
    };
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
      "tls://ca1.servers.devices.cwinfo.net:58226"
      "tcp://kusoneko.moe:9002"
      "tls://[2607:5300:201:3100::50a1]:58226"
      "tls://[2a01:4f9:6a:49e7:1068:cf52:a4aa:1]:8443?key=9d0bdac2e339fd57bcc9af5c4d5f2ecd98e724d32d56c239a5cdec580ab0a580"
      "tls://[2a01:4f9:2a:60c::2]:18836"
      "tls://95.216.5.243:18836"
      "tls://94.23.116.184:1944?key=9d0bdac2e339fd57bcc9af5c4d5f2ecd98e724d32d56c239a5cdec580ab0a580"
      "tls://aurora.devices.waren.io:18836"
      "tls://[2a01:4f9:c010:664d::1]:61995"
      "tls://65.21.57.122:61995"
      "tls://fi1.servers.devices.cwinfo.net:61995"
      "tls://51.15.204.214:54321"
      "tls://152.228.216.112:23108"
      "tls://fr2.servers.devices.cwinfo.net:23108"
      "tcp://51.15.204.214:12345"
      "tls://163.172.31.60:12221?key=060f2d49c6a1a2066357ea06e58f5cff8c76a5c0cc513ceb2dab75c900fe183b&sni=jorropo.net"
      "tls://51.255.223.60:54232"
      "tls://cloudberry.fr1.servers.devices.cwinfo.net:54232"
      "tls://[2001:41d0:304:200::ace3]:23108"
      "tls://[2001:41d0:2:c44a:51:255:223:60]:54232"
      "tcp://193.107.20.230:7743"
      "tcp://yggdrasil.su:62486"
      "tls://yggdrasil.su:62586"
      "tls://vpn.ltha.de:443?key=0000006149970f245e6cec43664bce203f2514b60a153e194f31e2b229a1339d"
      "tcp://gutsche.tech:8888"
      "tls://gutsche.tech:8889"
      "tls://[2a01:4f8:13a:19e5:103a:263e:890c:1]:8443?key=4308ccec1a3a9c68c4f376000cf9c7084c1daae4921eb123cd93b6eb96fd8d84"
      "tls://94.23.116.184:1945?key=4308ccec1a3a9c68c4f376000cf9c7084c1daae4921eb123cd93b6eb96fd8d84"
      "tls://de-fsn-1.peer.v4.yggdrasil.chaz6.com:4444"
      "tcp://ygg.mkg20001.io:80"
      "tls://ygg.mkg20001.io:443"
      "tcp://ygg2.mk16.de:1337?key=000000d80a2d7b3126ea65c8c08fc751088c491a5cdd47eff11c86fa1e4644ae"
      "tls://ygg2.mk16.de:1338?key=000000d80a2d7b3126ea65c8c08fc751088c491a5cdd47eff11c86fa1e4644ae"
      "tls://23.137.249.65:443"
      "tcp://ygg-nl.incognet.io:8883"
      "tls://ygg-nl.incognet.io:8884"
      "tls://94.103.82.150:8080"
      "tls://54.37.137.221:11129"
      "tls://[2a03:cfc0:8004::000b:0cf2]:8443?key=4696a1466c69110dfa6060a0be368b1049f1463906a75b815967efa6d374226e"
      "tls://pl1.servers.devices.cwinfo.net:11129"
      "tls://185.165.169.234:8443"
      "tcp://185.165.169.234:8880"
      "tcp://itcom.multed.com:7991"
      "tls://ygg.tomasgl.ru:61944?key=c5e0c28a600c2118e986196a0bbcbda4934d8e9278ceabea48838dc5d8fae576"
      "tcp://ygg.tomasgl.ru:61933?key=c5e0c28a600c2118e986196a0bbcbda4934d8e9278ceabea48838dc5d8fae576"
      "tcp://box.paulll.cc:13337"
      "tls://box.paulll.cc:13338"
      "tcp://srv.itrus.su:7991"
      "tcp://158.101.229.219:17002"
      "tls://158.101.229.219:17001"
      "tcp://[2603:c023:8001:1600:35e0:acde:2c6e:b27f]:17002"
      "tls://[2603:c023:8001:1600:35e0:acde:2c6e:b27f]:17001"
      "tcp://sin.yuetau.net:6642"
      "tls://sin.yuetau.net:6643"
      "tcp://ygg.ace.ctrl-c.liu.se:9998?key=5636b3af4738c3998284c4805d91209cab38921159c66a6f359f3f692af1c908"
      "tls://ygg.ace.ctrl-c.liu.se:9999?key=5636b3af4738c3998284c4805d91209cab38921159c66a6f359f3f692af1c908"
      "tls://185.130.44.194:7040"
      "tls://[2a07:e01:105:444:c634:6bff:feb5:6e28]:7040"
      "tcp://193.111.114.28:8080"
      "tls://193.111.114.28:1443"
      "tls://51.38.64.12:28395"
      "tls://185.175.90.87:43006"
      "tcp://curiosity.tdjs.tech:30003"
      "tls://[2a10:4740:40:0:2222:3f9c:b7cf:1]:43006"
      "tls://uk1.servers.devices.cwinfo.net:28395"
      "tcp://0.ygg.l1qu1d.net:11100?key=0000000998b5ff8c0f1115ce9212f772d0427151f50fe858e6de1d22600f1680"
      "tls://0.ygg.l1qu1d.net:11101?key=0000000998b5ff8c0f1115ce9212f772d0427151f50fe858e6de1d22600f1680"
      "tcp://longseason.1200bps.xyz:13121"
      "tls://longseason.1200bps.xyz:13122"
      "tcp://corn.chowder.land:9002"
      "tls://108.175.10.127:61216"
      "tls://corn.chowder.land:443"
      "tls://tasty.chowder.land:9001"
      "tcp://50.236.201.218:56088"
      "tcp://ygg4.mk16.de:1337?key=0000147df8daa1cce2ad4b1d4b14c60a4c69a991b2dfde4e00ba7e95c36c530b"
      "tcp://supergay.network:9002"
      "tcp://cowboy.supergay.network:9111"
      "tls://ygg4.mk16.de:1338?key=0000147df8daa1cce2ad4b1d4b14c60a4c69a991b2dfde4e00ba7e95c36c530b"
      "tls://ygg4.mk16.de:443?key=0000147df8daa1cce2ad4b1d4b14c60a4c69a991b2dfde4e00ba7e95c36c530b"
      "tcp://tasty.chowder.land:9002"
      "tls://supergay.network:9001"
      "tls://supergay.network:443"
      "tls://102.223.180.74:993"
      "tls://cowboy.supergay.network:443"
      "tls://[2605:9f80:2000:64::2]:7040"
      "tcp://lancis.iscute.moe:49273"
      "tls://167.160.89.98:7040"
      "tcp://zabugor.itrus.su:7991"
      "tls://lancis.iscute.moe:49274"
      "tcp://ygg3.mk16.de:1337?key=000003acdaf2a60e8de2f63c3e63b7e911d02380934f09ee5c83acb758f470c1"
      "tls://ygg3.mk16.de:1338?key=000003acdaf2a60e8de2f63c3e63b7e911d02380934f09ee5c83acb758f470c1"
    ];
  };
}
