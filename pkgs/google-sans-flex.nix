{ lib, stdenvNoCC, src }:

stdenvNoCC.mkDerivation {
  pname = "google-sans-flex";
  version = "git";
  inherit src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -dm0755 "$out/share/fonts/truetype/google-sans-flex"
    find . -type f \( -iname '*.ttf' -o -iname '*.otf' \) \
      -exec install -Dm0644 '{}' "$out/share/fonts/truetype/google-sans-flex/" \;

    runHook postInstall
  '';

  meta = {
    description = "Google Sans Flex font files for illogical-impulse";
    homepage = "https://github.com/end-4/google-sans-flex";
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.all;
  };
}
