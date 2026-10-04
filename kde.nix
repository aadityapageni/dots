{ config, pkgs, ... }:

{
  # Enable the KDE Plasma 6 Desktop Environment with Wayland.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.enable = true;
  environment.systemPackages = with pkgs; [
  # KDE Utilities
  kdePackages.discover # Optional: Software center for Flatpaks/firmware updates
  kdePackages.kcalc # Calculator
  kdePackages.kcharselect # Character map
  kdePackages.kclock # Clock app
  kdePackages.kcolorchooser # Color picker
  kdePackages.kolourpaint # Simple paint program
  kdePackages.ksystemlog # System log viewer
 kdePackages.kdeconnect-kde
kdePackages.krdp
kdePackages.signond
  kdePackages.sddm-kcm # SDDM configuration module
  kdiff3 # File/directory comparison tool
kdePackages.bluedevil
kdePackages.kaccounts-integration
kdePackages.kaccounts-providers
kara
  # Hardware/System Utilities (Optional)
  kdePackages.isoimagewriter # Write hybrid ISOs to USB
  kdePackages.partitionmanager # Disk and partition management
  hardinfo2 # System benchmarks and hardware info
  wayland-utils # Wayland diagnostic tools
  wl-clipboard # Wayland copy/paste support
  kdePackages.kio-gdrive
  #vlc # Media player
];
environment.pathsToLink = [
  "/share/qml"
  "/lib/qml"
];


}

