{ config, pkgs, inputs, ... }:

{
  # Hyprland compositor
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Ly display manager
  services.displayManager.ly = {
    enable = true;
  };

  # System packages needed by the dotfiles
  environment.systemPackages = with pkgs; [
    hyprlock hyprpaper hyprsunset
    quickshell
    foot
	nautilus
    brightnessctl playerctl
    wireplumber
    networkmanager
    bluez bluez-tools
    cliphist wl-clipboard
    grim slurp
    socat jq
    libnotify
    tofi
    jetbrains-mono
    nerd-fonts.jetbrains-mono
  ];

  # Wayland session env
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    WLR_NO_HARDWARE_CURSORS = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };

  # Hyprland portal (config.common.default is already set in configuration.nix)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    configPackages = [ pkgs.hyprland ];
  };

  # Polkit agent
  security.polkit.enable = true;
  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland Polkit Agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprland}/libexec/hyprland/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
