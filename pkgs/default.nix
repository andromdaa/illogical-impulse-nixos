{ pkgs, inputs }:

let
  inherit (pkgs) callPackage;

  microtex = callPackage ./microtex.nix {
    src = inputs.microtex-src;
  };

  google-sans-flex = callPackage ./google-sans-flex.nix {
    src = inputs.google-sans-flex-src;
  };

  breeze-plus = callPackage ./breeze-plus.nix {
    src = inputs.breeze-plus-src;
  };

  pythonEnv = callPackage ./python-env.nix { };

  dotfiles = callPackage ./dotfiles.nix {
    src = ../vendor/upstream;
    shapesSrc = inputs.rounded-polygon-qmljs;
    inherit microtex pythonEnv;
  };

  runtimePackages = callPackage ./runtime-packages.nix {
    inherit dotfiles microtex google-sans-flex breeze-plus pythonEnv;
  };

  quickshell = callPackage ./quickshell-wrapper.nix {
    quickshellPackage = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    inherit runtimePackages;
  };

  runtime = pkgs.buildEnv {
    name = "illogical-impulse-runtime";
    paths = runtimePackages ++ [ quickshell ];
  };
in
{
  inherit
    breeze-plus
    dotfiles
    google-sans-flex
    microtex
    pythonEnv
    runtime
    quickshell
    runtimePackages;
}
