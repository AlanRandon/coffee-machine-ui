{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cowsay

    # to compile coffee-machine-ui
    custom.zig
    gtk4
    pkg-config

    # Other system packages (wm, e.t.c.)
    cage
  ];

  # ! Change the following configuration
  users.users.coffee = {
    isNormalUser = true;
    home = "/home/coffee";
    description = "Coffee Machine UI";
    extraGroups = [ "wheel" "networkmanager" ];
    # ! Be sure to put your own public key here
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+YdA6ujWIbIGUWGQgWrlBhvBTyMd0qnFkIHrbgw111 alan@nixos" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # ! Be sure to change the autologinUser.
  services.getty.autologinUser = "coffee";
}
