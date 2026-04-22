# illogical-impulse NixOS flake

This flake packages the vendored `end-4/dots-hyprland` illogical-impulse dotfiles as reusable NixOS and Home Manager modules.

## NixOS usage

Add this flake as an input to your host flake, then import the module. If
your host already imports Home Manager, use `nixosModules.default`:

```nix
{
  inputs.illogical-impulse.url = "path:/path/to/illogical-impulse-nixos";

  outputs = { nixpkgs, home-manager, illogical-impulse, ... }: {
    nixosConfigurations.host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        illogical-impulse.nixosModules.default
        {
          programs.illogical-impulse = {
            enable = true;
            user = "cole";
            homeManager.enable = false;
          };
        }
      ];
    };
  };
}
```

The NixOS module installs and enables the system services needed by the desktop, including Hyprland, portals, PipeWire, Polkit, GNOME keyring, GeoClue, UPower, ydotool, fontconfig, and DDC/I2C support.

If you want this flake to import and configure Home Manager for you, use
`illogical-impulse.nixosModules.withHomeManager` instead of
`illogical-impulse.nixosModules.default`, and set
`programs.illogical-impulse.user`.

## Home Manager usage

If you already wire Home Manager yourself, import the user module directly:

```nix
{
  imports = [ inputs.illogical-impulse.homeModules.default ];

  programs.illogical-impulse.enable = true;
}
```

Most upstream files are managed declaratively. Known user-edited or runtime-generated files, including `hypr/custom`, monitor/workspace files, Hyprland color outputs, Hyprlock config, generated GTK/Fuzzel/Kvantum theme outputs, are copied only when missing and left writable afterwards.

## Flake outputs

- `nixosModules.default`
- `homeModules.default`
- `overlays.default`
- `packages.${system}.quickshell`
- `packages.${system}.dotfiles`
- `packages.${system}.pythonEnv`
- `packages.${system}.microtex`
- `packages.${system}.breeze-plus`
- `packages.${system}.google-sans-flex`
