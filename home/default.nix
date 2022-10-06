{ inputs, system, ... }:


let
  homeProfile = ./home.nix;
in
{
  home-manager = {
    useGlobalPkgs = true;
    # useUserPackages = true;
    users.riro = {
      imports = [
        homeProfile
        inputs.hyprland.homeManagerModules.default
        ../modules/hyprland
        #        
      ];

    };

    extraSpecialArgs = { inherit inputs system; };
  };

}