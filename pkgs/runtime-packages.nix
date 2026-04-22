{ pkgs
, dotfiles
, microtex
, google-sans-flex
, breeze-plus
, pythonEnv
}:

with pkgs; [
  # Local/flaked packages.
  dotfiles
  microtex
  google-sans-flex
  breeze-plus
  pythonEnv

  # Core shell/runtime tools.
  bash
  bc
  coreutils
  curlFull
  dbus
  file
  findutils
  gawk
  gnugrep
  gnused
  imagemagick
  inetutils
  jq
  libnotify
  procps
  ripgrep
  rsync
  util-linux
  wget
  which
  xdg-utils
  xdg-user-dirs
  yq-go

  # Hyprland and Wayland utilities.
  grim
  hypridle
  hyprlock
  hyprpicker
  hyprshot
  hyprsunset
  slurp
  swappy
  wf-recorder
  wl-clipboard
  wlogout
  wtype
  ydotool

  # Audio/media.
  easyeffects
  ffmpeg
  libcava
  libdbusmenu-gtk3
  lxqt.pavucontrol-qt
  mpvpaper
  pipewire
  playerctl
  songrec
  wireplumber

  # Desktop integration.
  adw-gtk3
  bibata-cursors
  brightnessctl
  cmakeWithGui
  ddcutil
  eza
  fish
  fontconfig
  fuzzel
  geoclue2
  glib
  gnome-desktop
  gnome-keyring
  gtk4
  kdePackages.bluedevil
  kdePackages.breeze
  kdePackages.breeze-icons
  kdePackages.dolphin
  kdePackages.kconfig
  kdePackages.kdialog
  kdePackages.kirigami
  kdePackages.plasma-nm
  kdePackages.plasma-systemmonitor
  kdePackages.polkit-kde-agent-1
  kdePackages.qtwayland
  kdePackages.syntax-highlighting
  kdePackages.systemsettings
  kitty
  libadwaita
  libportal-gtk4
  libqalculate
  libsoup_3
  matugen
  networkmanager
  qalculate-gtk
  qt6.qt5compat
  qt6.qtbase
  qt6.qtdeclarative
  qt6.qtimageformats
  qt6.qtmultimedia
  qt6.qtpositioning
  qt6.qtquicktimeline
  qt6.qtsensors
  qt6.qtsvg
  qt6.qttools
  qt6.qttranslations
  qt6.qtvirtualkeyboard
  qt6.qtwayland
  qt6Packages.qt6ct
  starship
  translate-shell
  upower
  xdg-desktop-portal
  xdg-desktop-portal-gtk

  # OCR and fonts.
  google-fonts
  material-symbols
  nerd-fonts.jetbrains-mono
  readexpro
  rubik
  tesseract
  twemoji-color-font
]
