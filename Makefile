.PHONY: build-rpi-iso

build-rpi-iso:
	git add .
	nix build -L ./rpi-nix#nixosConfigurations.zero2w.config.system.build.sdImage
