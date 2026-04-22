{ lib
, stdenv
, cmake
, pkg-config
, tinyxml-2
, gtkmm3
, gtksourceviewmm4
, cairomm
, src
}:

stdenv.mkDerivation {
  pname = "illogical-impulse-microtex";
  version = "git";
  inherit src;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    tinyxml-2
    gtkmm3
    gtksourceviewmm4
    cairomm
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "gtksourceviewmm-3.0" "gtksourceviewmm-4.0"

    substituteInPlace CMakeLists.txt \
      --replace "tinyxml2.so.10" "tinyxml2.so.11"
  '';

  cmakeBuildType = "None";

  installPhase = ''
    runHook preInstall

    latex_exe="$(find . -maxdepth 2 -type f -name LaTeX -perm -0100 | head -n1)"
    test -n "$latex_exe"
    install -Dm0755 "$latex_exe" "$out/opt/MicroTeX/LaTeX"

    res_dir=""
    for candidate in ./res ./build/res "$src/res"; do
      if [ -d "$candidate" ]; then
        res_dir="$candidate"
        break
      fi
    done

    test -n "$res_dir"
    cp -r "$res_dir" "$out/opt/MicroTeX/res"
    install -Dm0644 "$src/LICENSE" "$out/share/licenses/$pname/LICENSE"

    runHook postInstall
  '';

  meta = {
    description = "MicroTeX packaged for illogical-impulse Quickshell LaTeX rendering";
    homepage = "https://github.com/NanoMichael/MicroTeX";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
