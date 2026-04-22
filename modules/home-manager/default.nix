{ self, inputs }:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.illogical-impulse;
  system = pkgs.stdenv.hostPlatform.system;
  packages = self.legacyPackages.${system};
  dotfilesRoot = "${packages.dotfiles}/share/illogical-impulse";
  dotsConfig = "${dotfilesRoot}/dots/.config";
  dotsData = "${dotfilesRoot}/dots/.local/share";
  mkManagedFile = file: file // { source = lib.mkOptionDefault file.source; };

  managedConfigFiles = lib.mapAttrs (_: mkManagedFile) {
    "Kvantum/Colloid".source = "${dotsConfig}/Kvantum/Colloid";
    "Kvantum/kvantum.kvconfig".source = "${dotsConfig}/Kvantum/kvantum.kvconfig";
    "chrome-flags.conf".source = "${dotsConfig}/chrome-flags.conf";
    "code-flags.conf".source = "${dotsConfig}/code-flags.conf";
    "darklyrc".source = "${dotsConfig}/darklyrc";
    "dolphinrc".source = "${dotsConfig}/dolphinrc";
    "fish/auto-Hypr.fish".source = "${dotsConfig}/fish/auto-Hypr.fish";
    "fish/config.fish".source = "${dotsConfig}/fish/config.fish";
    "fish/fish_variables".source = "${dotsConfig}/fish/fish_variables";
    "fontconfig/fonts.conf".source = "${dotsConfig}/fontconfig/fonts.conf";
    "foot".source = "${dotsConfig}/foot";
    "fuzzel/fuzzel.ini".source = "${dotsConfig}/fuzzel/fuzzel.ini";
    "hypr/hyprland.conf".source = "${dotsConfig}/hypr/hyprland.conf";
    "hypr/hyprland/env.conf".source = "${dotsConfig}/hypr/hyprland/env.conf";
    "hypr/hyprland/execs.conf".source = "${dotsConfig}/hypr/hyprland/execs.conf";
    "hypr/hyprland/general.conf".source = "${dotsConfig}/hypr/hyprland/general.conf";
    "hypr/hyprland/keybinds.conf".source = "${dotsConfig}/hypr/hyprland/keybinds.conf";
    "hypr/hyprland/rules.conf".source = "${dotsConfig}/hypr/hyprland/rules.conf";
    "hypr/hyprland/scripts".source = "${dotsConfig}/hypr/hyprland/scripts";
    "hypr/hyprland/shellOverrides".source = "${dotsConfig}/hypr/hyprland/shellOverrides";
    "hypr/hyprland/variables.conf".source = "${dotsConfig}/hypr/hyprland/variables.conf";
    "hypr/hyprlock/check-capslock.sh".source = "${dotsConfig}/hypr/hyprlock/check-capslock.sh";
    "hypr/hyprlock/status.sh".source = "${dotsConfig}/hypr/hyprlock/status.sh";
    "kde-material-you-colors".source = "${dotsConfig}/kde-material-you-colors";
    "kdeglobals".source = "${dotsConfig}/kdeglobals";
    "kitty".source = "${dotsConfig}/kitty";
    "konsolerc".source = "${dotsConfig}/konsolerc";
    "matugen".source = "${dotsConfig}/matugen";
    "mpv".source = "${dotsConfig}/mpv";
    "quickshell/ii".source = "${dotsConfig}/quickshell/ii";
    "starship.toml".source = "${dotsConfig}/starship.toml";
    "thorium-flags.conf".source = "${dotsConfig}/thorium-flags.conf";
    "wlogout/layout".source = "${dotsConfig}/wlogout/layout";
    "wlogout/style.css".source = "${dotsConfig}/wlogout/style.css";
    "xdg-desktop-portal".source = "${dotsConfig}/xdg-desktop-portal";
    "zshrc.d".source = "${dotsConfig}/zshrc.d";
  };

  firstRunScript = ''
    copy_if_missing() {
      local src="$1"
      local dest="$2"

      if [ ! -e "$dest" ]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$dest")"
        $DRY_RUN_CMD cp -a "$src" "$dest"
        $DRY_RUN_CMD chmod -R u+w "$dest"
      fi
    }

    ensure_dir() {
      local dest="$1"

      if [ ! -e "$dest" ]; then
        $DRY_RUN_CMD mkdir -p "$dest"
      fi
    }

    copy_if_missing "${dotsConfig}/hypr/custom" "${config.xdg.configHome}/hypr/custom"
    copy_if_missing "${dotsConfig}/hypr/hypridle.conf" "${config.xdg.configHome}/hypr/hypridle.conf"
    copy_if_missing "${dotsConfig}/hypr/hyprland/colors.conf" "${config.xdg.configHome}/hypr/hyprland/colors.conf"
    copy_if_missing "${dotsConfig}/hypr/hyprlock.conf" "${config.xdg.configHome}/hypr/hyprlock.conf"
    copy_if_missing "${dotsConfig}/hypr/hyprlock/colors.conf" "${config.xdg.configHome}/hypr/hyprlock/colors.conf"
    copy_if_missing "${dotsConfig}/hypr/monitors.conf" "${config.xdg.configHome}/hypr/monitors.conf"
    copy_if_missing "${dotsConfig}/hypr/workspaces.conf" "${config.xdg.configHome}/hypr/workspaces.conf"
    copy_if_missing "${dotsConfig}/fuzzel/fuzzel_theme.ini" "${config.xdg.configHome}/fuzzel/fuzzel_theme.ini"
    copy_if_missing "${dotsConfig}/Kvantum/MaterialAdw" "${config.xdg.configHome}/Kvantum/MaterialAdw"

    ensure_dir "${config.xdg.configHome}/gtk-3.0"
    ensure_dir "${config.xdg.configHome}/gtk-4.0"
    ensure_dir "${config.xdg.stateHome}/quickshell/user/generated"
    ensure_dir "${config.xdg.stateHome}/quickshell/user/generated/wallpaper"
  '';
in
{
  options.programs.illogical-impulse = {
    enable = lib.mkEnableOption "the illogical-impulse user session";

    mutableCustom = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Copy user/custom and generated config files only when missing, leaving them writable afterwards.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to put in the user's profile.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      packages.quickshell
    ] ++ packages.runtimePackages ++ cfg.extraPackages;

    home.sessionPath = [
      "${packages.pythonEnv}/bin"
    ];

    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = lib.mkOptionDefault "${packages.pythonEnv}";
      QT_QPA_PLATFORM = lib.mkOptionDefault "wayland;xcb";
      QT_QPA_PLATFORMTHEME = lib.mkOptionDefault "kde";
      XDG_MENU_PREFIX = lib.mkOptionDefault "plasma-";
    };

    programs = {
      starship.enable = lib.mkDefault false;
      home-manager.enable = true;
    };

    fonts.fontconfig.enable = true;
    xdg.enable = true;

    xdg.configFile = managedConfigFiles;

    xdg.dataFile = lib.mapAttrs (_: mkManagedFile) {
      "icons/illogical-impulse.svg".source = "${dotsData}/icons/illogical-impulse.svg";
      "konsole".source = "${dotsData}/konsole";
    };

    home.activation.illogicalImpulseMutableFiles = lib.mkIf cfg.mutableCustom (
      lib.hm.dag.entryAfter [ "writeBoundary" ] firstRunScript
    );
  };
}
