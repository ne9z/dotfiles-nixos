{ pkgs ? import <nixpkgs> { } }:
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.elpaPackages
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.melpaPackages
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.melpaStablePackages
# nix-env -f "<nixpkgs>" -qaP -A emacs.pkgs.orgPackages
let
  emacsWithPackages = (pkgs.emacsPackagesFor pkgs.emacsPgtk).emacsWithPackages;
in emacsWithPackages (epkgs:
  (with epkgs.melpaPackages; [ ]) ++ (with epkgs.melpaPackages; [
    nix-mode # ; nix mode
    cdlatex
    pyim
    pyim-basedict
    notmuch
    magit
    smartparens
  ]) ++ (with epkgs.elpaPackages; [ auctex ]) ++ [ ])
