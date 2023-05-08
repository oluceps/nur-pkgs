{
  description = "oluceps' flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-gui.url = "github:NixOS/nixpkgs?rev=954a801cbe128e24e78230f711df17da01a5d98c";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    nvfetcher.url = "github:berberman/nvfetcher";
    agenix-rekey.url = "github:oddlama/agenix-rekey";
    resign.url = "github:oluceps/resign";
    nil.url = "github:oxalica/nil";
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-colors.url = "github:misterio77/nix-colors";
    clansty.url = "github:clansty/flake";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nur-pkgs = {
      url = "github:oluceps/nur-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpicker.url = "github:hyprwm/hyprpicker";
    surrealdb.url = "github:surrealdb/surrealdb";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    impermanence.url = "github:nix-community/impermanence";
    clash-meta.url = "github:MetaCubeX/Clash.Meta/Alpha";
    alejandra.url = "github:kamadorueda/alejandra";
    polymc.url = "github:PolyMC/PolyMC";
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    pywmpkg.url = "github:jbuchermn/pywm";
    home-manager.url = "github:nix-community/home-manager";
    helix.url = "github:helix-editor/helix";
    hyprland.url = "github:vaxerski/Hyprland";
    berberman.url = "github:berberman/flakes";
  };

  outputs = { self, ... }@inputs:
    let
      genSystems = inputs.nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];

      genOverlays = map (let m = i: inputs.${i}.overlays; in (i: (m i).default or (m i).${i})); # ugly

      # contentAddressedByDefault = true;
      _pkgs = genSystems (system: import inputs.nixpkgs { inherit system; config = { allowUnfree = true; allowBroken = false; segger-jlink.acceptLicense = true; allowUnsupportedSystem = true; permittedInsecurePackages = [ "python-2.7.18.6" "electron-21.4.0" ]; }; overlays = (import ./overlays.nix { inherit inputs system; }) ++ genOverlays [ "self" "clansty" "fenix" "berberman" "nvfetcher" ] ++ [ inputs.nur.overlay ]; });

      genericImport = p: import p { inherit inputs _pkgs; };
    in
    {
      nixosConfigurations = genericImport ./hosts;

      devShells = genSystems (system: genericImport ./shells.nix);

      apps = genSystems (system: inputs.agenix-rekey.defineApps self _pkgs.${system} { inherit (self.nixosConfigurations) hastur kaambl; });

      overlays.default = final: prev: prev.lib.genAttrs (with builtins;(attrNames (readDir ./pkgs))) (name: final.callPackage (./pkgs + "/${name}") { });

      checks = genSystems (system: with _pkgs.${system}; { pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run { src = lib.cleanSource ./.; hooks = { nixpkgs-fmt.enable = true; }; }; });

    };

}
