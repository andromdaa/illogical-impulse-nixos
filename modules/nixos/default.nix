{ self, inputs }:
{ config, lib, options, pkgs, ... }:

let
  cfg = config.programs.illogical-impulse;
  system = pkgs.stdenv.hostPlatform.system;
  packages = self.legacyPackages.${system};
  hasHomeManager = builtins.hasAttr "home-manager" options;
in
{
  options.programs.illogical-impulse = {
    enable = lib.mkEnableOption "the illogical-impulse Hyprland desktop";

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "cole";
      description = "User that should receive the Home Manager dotfile configuration.";
    };

    homeManager.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Configure the already imported Home Manager NixOS module for programs.illogical-impulse.user.";
    };

    mutableCustom = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Copy user/custom and generated config files only when missing, leaving them writable afterwards.";
    };

    setFishAsDefaultShell = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set the configured user's login shell to fish.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install with the desktop runtime.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.homeManager.enable || cfg.user != null;
          message = "programs.illogical-impulse.user must be set when homeManager.enable is true.";
        }
        {
          assertion = !cfg.homeManager.enable || hasHomeManager;
          message = "programs.illogical-impulse.homeManager.enable requires Home Manager's NixOS module. Import inputs.home-manager.nixosModules.home-manager yourself, or use illogical-impulse.nixosModules.withHomeManager.";
        }
      ];

      nixpkgs.overlays = [ self.overlays.default ];

      environment.systemPackages = packages.runtimePackages ++ [
        packages.quickshell
      ] ++ cfg.extraPackages;

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      fonts = {
        fontDir.enable = lib.mkDefault true;
        fontconfig.enable = lib.mkDefault true;
        packages = with pkgs; [
          google-fonts
          material-symbols
          nerd-fonts.jetbrains-mono
          packages.google-sans-flex
          readexpro
          rubik
          twemoji-color-font
        ];
      };

      programs = {
        dconf.enable = lib.mkDefault true;
        fish.enable = lib.mkDefault true;
        hyprland = {
          enable = lib.mkDefault true;
          xwayland.enable = lib.mkDefault true;
        };
        hyprlock.enable = lib.mkDefault true;
        ydotool.enable = lib.mkDefault true;
      };

      security = {
        polkit.enable = lib.mkDefault true;
        rtkit.enable = lib.mkDefault true;
        pam.services.hyprlock = { };
      };

      services = {
        dbus.enable = lib.mkDefault true;
        geoclue2.enable = lib.mkDefault true;
        gnome.gnome-keyring.enable = lib.mkDefault true;
        gvfs.enable = lib.mkDefault true;
        upower.enable = lib.mkDefault true;

        pipewire = {
          enable = lib.mkDefault true;
          audio.enable = lib.mkDefault true;
          pulse.enable = lib.mkDefault true;
          wireplumber.enable = lib.mkDefault true;
        };
      };

      networking.networkmanager.enable = lib.mkDefault true;

      hardware = {
        bluetooth.enable = lib.mkDefault true;
        i2c.enable = lib.mkDefault true;
      };

      services.udev.packages = with pkgs; [
        brightnessctl
        ddcutil
      ];

      xdg.portal = {
        enable = lib.mkDefault true;
        xdgOpenUsePortal = lib.mkDefault true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          kdePackages.xdg-desktop-portal-kde
        ];
      };
    }

    (lib.mkIf (cfg.user != null) {
      users.users.${cfg.user}.extraGroups = [
        "i2c"
        "input"
        "networkmanager"
        "video"
      ];
    })

    (lib.mkIf (cfg.user != null && cfg.setFishAsDefaultShell) {
      users.users.${cfg.user}.shell = pkgs.fish;
    })

    (lib.optionalAttrs hasHomeManager (lib.mkIf (cfg.homeManager.enable && cfg.user != null) {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${cfg.user} = {
          imports = [ self.homeModules.default ];

          home = {
            username = lib.mkDefault cfg.user;
            homeDirectory = lib.mkDefault "/home/${cfg.user}";
            stateVersion = lib.mkDefault config.system.stateVersion;
          };

          programs.illogical-impulse = {
            enable = true;
            mutableCustom = cfg.mutableCustom;
            extraPackages = cfg.extraPackages;
          };
        };
      };
    }))
  ]);
}
