{ config, pkgs, ... }:
let
  myEmacs = (import ./emacs.nix { inherit pkgs; });
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium dvisvgm dvipng # for preview and export as html
      wrapfig amsmath ulem hyperref capt-of;
    #(setq org-latex-compiler "lualatex")
    #(setq org-preview-latex-default-process 'dvisvgm)
  });
in {
  # DO NOT Let Home Manager install and manage itself.
  # this is done by system
  programs.home-manager.enable = false;
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "user";
  home.homeDirectory = "/home/${config.home.username}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  imports = [ # ./firefox.nix # ./programs.nix ./mail.nix
  ];

  home.packages = with pkgs; [ ];

  gtk = {
    enable = true;
    font = { name = "Noto Sans Display 14"; };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      enable-animations = false;
      document-font-name = "Noto Sans Display 12";
      monospace-font-name = "Source Code Pro 10";
      gtk-key-theme = "Emacs";
      cursor-size = 48;
    };
  };
  programs.emacs = {
    enable = true;
    package = myEmacs;
  };
  services.emacs = {
    enable = true;
    socketActivation.enable = true;
    extraOptions = [ ];
    client = {
      enable = true;
      arguments = [ "--alternate-editor= --create-frame" ];
    };
  };
  programs = {
    mbsync.enable = true;
    msmtp.enable = true;
  };
}
