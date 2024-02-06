{ self, inputs, ... }: {
  flake =
    let lib = inputs.nixpkgs.lib.extend self.overlays.lib; in
    {
      nixosConfigurations = {
        nodens = lib.nixosSystem
          {
            pkgs = import inputs.nixpkgs {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
              overlays = (import ../../overlays.nix inputs)
                ++
                (lib.genOverlays [
                  "self"
                  "fenix"
                  "EHfive"
                  "nuenv"
                  "agenix-rekey"
                  "nixyDomains"
                  "nixpkgs-wayland"
                ]);
            };
            specialArgs = lib.base // {
              inherit lib; # weird
              user = "elen";
            };
            modules = [
              ./hardware.nix
              ./network.nix
              ./rekey.nix
              ./spec.nix
              ../../age.nix
              ../../packages.nix
              ../../misc.nix
              ../../users.nix
            ]
            ++ lib.sharedModules ++ [
              inputs.factorio-manager.nixosModules.default
            ];

          };
      };
    };
}