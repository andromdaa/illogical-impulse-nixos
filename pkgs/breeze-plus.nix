{ lib, stdenvNoCC, src }:

stdenvNoCC.mkDerivation {
  pname = "breeze-plus";
  version = "git";
  inherit src;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -dm0755 "$out/share"
    cp -r . "$out/share/breeze-plus-src"

    for dir in color-schemes plasma desktoptheme aurorae Kvantum icons; do
      if [ -d "$dir" ]; then
        cp -r "$dir" "$out/share/"
      fi
    done

    runHook postInstall
  '';

  meta = {
    description = "Breeze Plus theme assets for illogical-impulse";
    homepage = "https://github.com/mjkim0727/breeze-plus";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
