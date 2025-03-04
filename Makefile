.PHONY: build-rpi-iso

build-rpi-iso:
	git add .
	nix build ./rpi-nix#images.rpi2
