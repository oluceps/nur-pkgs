# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs }:

# The `lib`, `modules`, and `overlay` names are special
let

  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  system = "x86_64-linux";
  callPackage = pkgs.legacyPackages.${system}.callPackage;
  fenix = (builtins.getFlake (builtins.toString ./.)).inputs.fenix.packages.${system};

in
{
  Graphite-cursors = callPackage ./pkgs/Graphite-cursors { };
  rustplayer = callPackage ./pkgs/RustPlayer { };
  sing-box = callPackage ./pkgs/sing-box { };
  oppo-sans = callPackage ./pkgs/oppo-sans { };
  san-francisco = callPackage ./pkgs/san-francisco { };
  v2ray-plugin = callPackage ./pkgs/v2ray-plugin { };
  plangothic = callPackage ./pkgs/plangothic { };
  maple-font = callPackage ./pkgs/maple-font { };
  # surrealdb = callPackage ./pkgs/surrealdb { };  
  maoken-tangyuan = callPackage ./pkgs/maoken-tangyuan { };
  shadow-tls = callPackage ./pkgs/shadow-tls {inherit fenix; };
  tuic = callPackage ./pkgs/tuic {inherit fenix; };
  techmino = callPackage ./pkgs/techmino { };
  naiveproxy = callPackage ./pkgs/naiveproxy { };
  # ... 

}
   
  

