{
  description = "Flake for building a Raspberry Pi Zero 2 SD image";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    zls-overlay = {
      url = "github:zigtools/zls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zig-overlay.follows = "zig-overlay";
      };
    };
  };

  outputs =
    { self
    , nixpkgs
    , zig-overlay
    , zls-overlay
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      zig = zig-overlay.packages."${system}".master;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            inherit zig;
          })
        ];
      };
      zls = zls-overlay.packages."${system}".zls.overrideAttrs (old: {
        nativeBuildInputs = [ zig ];
      });
      overlay-custom = final: prev:
        let zig = zig-overlay.packages.${system}.master;
        in {
          custom = {
            inherit zig zls;
          };
        };
    in
    {
      nixosConfigurations = {
        zero2w = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ({ ... }: {
              nixpkgs.overlays = [
                overlay-custom
              ];
            })
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./nix/zero2w.nix
            ./nix/configuration.nix
          ];
        };
      };

      devShells."${system}".default =
        pkgs.mkShell {
          packages = [
            zig
            # zls
          ];
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.gtk4 ];
        };
    };
}
