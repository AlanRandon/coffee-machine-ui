# TODO: consider this, building on this laptop way too slow

{
  description = "Raspberry PI ISO";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }: rec {
    nixosConfigurations.rpi2 = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"
        ({ pkgs, ... }:
          {
            nixpkgs.config.allowUnsupportedSystem = true;
            nixpkgs.hostPlatform.system = "armv7l-linux";
            nixpkgs.buildPlatform.system = "x86_64-linux";

            environment.systemPackages = with pkgs; [
              btop
            ];

            system.stateVersion = "24.11";
          })
      ];
    };

    images.rpi2 = nixosConfigurations.rpi2.config.system.build.sdImage;
  };
}
