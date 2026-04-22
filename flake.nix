{
  description = "Self-contained NixOS/Home Manager flake for end-4's illogical-impulse Hyprland dots";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:quickshell-mirror/quickshell/7511545ee20664e3b8b8d3322c0ffe7567c56f7a";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rounded-polygon-qmljs = {
      url = "github:end-4/rounded-polygon-qmljs/e31ec4cb4ebf6a46b267f5c42eabf6874916fa16";
      flake = false;
    };

    microtex-src = {
      url = "github:NanoMichael/MicroTeX";
      flake = false;
    };

    breeze-plus-src = {
      url = "github:mjkim0727/breeze-plus";
      flake = false;
    };

    google-sans-flex-src = {
      url = "git+https://github.com/end-4/google-sans-flex?submodules=1";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config.allowUnfree = true;
      };
      nixosModule = import ./modules/nixos { inherit self inputs; };
    in
    {
      overlays.default = final: prev: {
        illogical-impulse = import ./pkgs {
          pkgs = final;
          inherit inputs;
        };
      };

      packages = forAllSystems (system:
        let pkgs = pkgsFor system;
        in lib.filterAttrs (_: value: lib.isDerivation value) pkgs.illogical-impulse // {
          default = pkgs.illogical-impulse.quickshell;
        });

      legacyPackages = forAllSystems (system: (pkgsFor system).illogical-impulse);

      checks = forAllSystems (system:
        import ./checks {
          inherit self inputs system;
          pkgs = pkgsFor system;
        });

      nixosModules = {
        default = nixosModule;
        withHomeManager = { lib, ... }: {
          imports = [
            inputs.home-manager.nixosModules.home-manager
            nixosModule
          ];

          programs.illogical-impulse.homeManager.enable = lib.mkDefault true;
        };
      };

      homeModules.default = import ./modules/home-manager { inherit self inputs; };

      formatter = forAllSystems (system: (pkgsFor system).nixpkgs-fmt);
    };
}
