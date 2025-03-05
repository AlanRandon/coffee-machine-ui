{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cowsay

    # to compile coffee-machine-ui
    custom.zig
    gtk4
    pkg-config
  ];

  # ! Change the following configuration
  users.users.coffee = {
    isNormalUser = true;
    home = "/home/coffee";
    description = "Coffee Machine UI";
    extraGroups = [ "wheel" "networkmanager" ];
    # ! Be sure to put your own public key here
    # openssh.authorizedKeys.keys = [ "a public key" ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # ! Be sure to change the autologinUser.
  services.getty.autologinUser = "coffee";
}
