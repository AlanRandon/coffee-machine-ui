.PHONY: build-rpi-iso

build-rpi-iso:
	git add .
	nix build -L .#nixosConfigurations.zero2w.config.system.build.sdImage
