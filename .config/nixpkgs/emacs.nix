{ pkgs ? import <nixpkgs> { } }:
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.elpaPackages
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.melpaPackages
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.melpaStablePackages
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.orgPackages
let emacsWithPackages = (pkgs.emacsPackagesFor pkgs.emacs).emacsWithPackages;
in emacsWithPackages (epkgs:
  (with epkgs.melpaPackages; [ ]) ++ (with epkgs.melpaPackages; [
    nix-mode # ; nix mode
    cdlatex
    notmuch
    use-package
    smartparens
    magit
    pyim
    pyim-basedict
  ]) ++ (with epkgs.elpaPackages; [ ace-window avy ivy swiper auctex ]) ++ [ ])
