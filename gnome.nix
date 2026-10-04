{ config, pkgs, ... }:

{
  # Display Manager / Desktop
services.displayManager.gdm.enable = true;
services.desktopManager.gnome.enable = true;
  # Security / Keyring
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Online Accounts / GVFS
  services.gnome.gnome-online-accounts.enable = true;
  services.gvfs.package = pkgs.gnome.gvfs;

  # Programs
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.systemPackages = with pkgs; [
ubuntu-sans-mono
ubuntu-sans  
    gnomeExtensions.control-monitor-brightness-and-volume-with-ddcutil
];

}
