{ lib
, stdenvNoCC
, makeWrapper
, quickshellPackage
, runtimePackages
, gsettings-desktop-schemas
, kdePackages
, qt6
}:

stdenvNoCC.mkDerivation {
  pname = "illogical-impulse-quickshell";
  version = "7511545ee20664e3b8b8d3322c0ffe7567c56f7a";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -dm0755 "$out/bin"
    makeWrapper ${quickshellPackage}/bin/qs "$out/bin/qs" \
      --prefix PATH : ${lib.makeBinPath runtimePackages} \
      --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name} \
      --prefix XDG_DATA_DIRS : ${kdePackages.kirigami.unwrapped}/share \
      --prefix QML2_IMPORT_PATH : ${qt6.qt5compat}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtdeclarative}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtmultimedia}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtpositioning}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtquicktimeline}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtsensors}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtsvg}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtvirtualkeyboard}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${qt6.qtwayland}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${kdePackages.kirigami.unwrapped}/${qt6.qtbase.qtQmlPrefix} \
      --prefix QML2_IMPORT_PATH : ${kdePackages.syntax-highlighting}/${qt6.qtbase.qtQmlPrefix}

    runHook postInstall
  '';

  meta = {
    description = "Quickshell wrapper with illogical-impulse runtime PATH and QML imports";
    homepage = "https://quickshell.org";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "qs";
  };
}
