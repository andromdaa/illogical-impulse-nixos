{ python3 }:

python3.withPackages (ps: with ps; [
  build
  certifi
  click
  dbus-python
  google-auth
  kde-material-you-colors
  libsass
  loguru
  material-color-utilities
  materialyoucolor
  numpy
  opencv4Full
  pillow
  psutil
  pycairo
  pygobject3
  pywayland
  requests
  setproctitle
  setuptools
  setuptools-scm
  tqdm
  wheel
])
