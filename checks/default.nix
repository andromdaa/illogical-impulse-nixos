{ self, inputs, system, pkgs }:

let
  nixosEval = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.withHomeManager
      {
        programs.illogical-impulse = {
          enable = true;
          user = "alice";
        };

        users.users.alice = {
          isNormalUser = true;
          home = "/home/alice";
        };

        boot.loader.grub.enable = false;
        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
        };
        system.stateVersion = "25.11";
      }
    ];
  };

  nixosSystemOnlyEval = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      self.nixosModules.default
      {
        programs.illogical-impulse.enable = true;

        boot.loader.grub.enable = false;
        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
        };
        system.stateVersion = "25.11";
      }
    ];
  };

  homeEval = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      self.homeModules.default
      {
        home = {
          username = "alice";
          homeDirectory = "/home/alice";
          stateVersion = "25.11";
        };

        programs.illogical-impulse.enable = true;
      }
    ];
  };
in
{
  nixos-module-eval =
    assert nixosEval.config.system.build.toplevel.name != "";
    pkgs.runCommand "illogical-impulse-nixos-module-eval" { } ''
      echo ok > "$out"
    '';

  nixos-system-only-module-eval =
    assert nixosSystemOnlyEval.config.system.build.toplevel.name != "";
    pkgs.runCommand "illogical-impulse-nixos-system-only-module-eval" { } ''
      echo ok > "$out"
    '';

  home-module-eval =
    assert homeEval.activationPackage.name != "";
    pkgs.runCommand "illogical-impulse-home-module-eval" { } ''
      echo ok > "$out"
    '';

  dotfiles-sanity = pkgs.runCommand "illogical-impulse-dotfiles-sanity"
    {
      nativeBuildInputs = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.ripgrep
      ];
    }
    ''
      root=${self.packages.${system}.dotfiles}/share/illogical-impulse

      test "$(find "$root/dots/.config/quickshell/ii/modules/common/widgets/shapes" -type f | wc -l)" -gt 0
      ! rg -n '/opt/MicroTeX|pacman -Syu|sudo pacman -S|yay -S|bin/activate' \
        "$root/dots/.config/quickshell" \
        "$root/dots/.config/hypr" \
        "$root/dots/.config/matugen"

      touch "$out"
    '';
}
