{ lib
, stdenvNoCC
, src
, shapesSrc
, microtex
, pythonEnv
, geoclue2
}:

stdenvNoCC.mkDerivation {
  pname = "illogical-impulse-dotfiles";
  version = "vendored";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    root="$out/share/illogical-impulse"
    install -dm0755 "$root"
    cp -a ${src}/dots "$root/dots"
    cp -a ${src}/dots-extra "$root/dots-extra"
    cp -a ${src}/licenses "$root/licenses"
    install -Dm0644 ${src}/sdata/deps-info.md "$root/sdata/deps-info.md"
    install -Dm0644 ${src}/sdata/uv/requirements.txt "$root/sdata/uv/requirements.txt"

    chmod -R u+w "$root"

    shapes="$root/dots/.config/quickshell/ii/modules/common/widgets/shapes"
    rm -rf "$shapes"
    mkdir -p "$(dirname "$shapes")"
    cp -a ${shapesSrc} "$shapes"

    latex="$root/dots/.config/quickshell/ii/services/LatexRenderer.qml"
    substituteInPlace "$latex" \
      --replace-fail 'property string microtexBinaryDir: "/opt/MicroTeX"' \
      'property string microtexBinaryDir: "${microtex}/opt/MicroTeX"'

    for py in \
      "$root/dots/.config/quickshell/ii/scripts/colors/generate_colors_material.py" \
      "$root/dots/.config/quickshell/ii/scripts/hyprland/get_keybinds.py" \
      "$root/dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py"; do
      sed -i "1c #!${pythonEnv}/bin/python3" "$py"
    done

    for wrapped in \
      "$root/dots/.config/quickshell/ii/scripts/images/find-regions-venv.sh" \
      "$root/dots/.config/quickshell/ii/scripts/images/least-busy-region-venv.sh" \
      "$root/dots/.config/quickshell/ii/scripts/images/text-color-venv.sh" \
      "$root/dots/.config/quickshell/ii/scripts/thumbnails/thumbgen-venv.sh" \
      "$root/dots/.config/quickshell/ii/scripts/colors/switchwall.sh" \
      "$root/dots/.config/matugen/templates/kde/kde-material-you-colors-wrapper.sh"; do
      substituteInPlace "$wrapped" \
        --replace 'source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate' \
                  'export PATH=${pythonEnv}/bin:$PATH' \
        --replace 'source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate"' \
                  'export PATH=${pythonEnv}/bin:$PATH' \
        --replace 'deactivate' 'true'
    done

    hypr_env="$root/dots/.config/hypr/hyprland/env.conf"
    sed -i '/^env = XDG_DATA_DIRS,/d' "$hypr_env"
    substituteInPlace "$hypr_env" \
      --replace-fail 'env = ILLOGICAL_IMPULSE_VIRTUAL_ENV, ~/.local/state/quickshell/.venv' \
      'env = ILLOGICAL_IMPULSE_VIRTUAL_ENV, ${pythonEnv}'

    geoclue_agent="$root/dots/.config/hypr/hyprland/scripts/start_geoclue_agent.sh"
    substituteInPlace "$geoclue_agent" \
      --replace 'AGENT_PATHS=(' 'AGENT_PATHS=(
  ${geoclue2}/libexec/geoclue-2.0/demos/agent
  ${geoclue2}/lib/geoclue-2.0/demos/agent'

    switchwall="$root/dots/.config/quickshell/ii/scripts/colors/switchwall.sh"
    substituteInPlace "$switchwall" \
      --replace 'kitty -1 yay -S upscayl-bin' \
                'notify-send -a "Wallpaper switcher" "Add upscayl to programs.illogical-impulse.extraPackages if desired"' \
      --replace 'kitty -1 sudo pacman -S "''${missing_deps[*]}"' \
                'notify-send -a "Wallpaper switcher" "Add missing video wallpaper packages to programs.illogical-impulse.extraPackages"'

    config_qml="$root/dots/.config/quickshell/ii/modules/common/Config.qml"
    substituteInPlace "$config_qml" \
      --replace "kitty -1 --hold=yes fish -i -c 'pkexec pacman -Syu'" \
                "kitty -1 --hold=yes fish -i -c 'sudo nixos-rebuild switch'"

    runHook postInstall
  '';

  meta = {
    description = "Patched illogical-impulse dotfiles for NixOS/Home Manager";
    homepage = "https://github.com/end-4/dots-hyprland";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
