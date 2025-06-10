{
  description = "advanced websearch plugin for anyrun";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "https://flakehub.com/f/oxalica/rust-overlay/*";
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
  }: let
    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (
        system: let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              rust-overlay.overlays.default
            ];
          };
        in
          f {inherit pkgs;}
      );
  in {
    packages = forAllSystems (
      {pkgs}: let
        rustPlatform = pkgs.rustPlatform;

        myRustApp = rustPlatform.buildRustPackage {
          pname = "websearchengines";
          version = "0.1.0";
          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "anyrun-interface-0.1.0" = "sha256-pg0w4uOZI32dLASD6UbBezeQg5PwOa0GLv7rTwn3VxY=";
            };
          };

          # If your Rust project needs specific system dependencies, list them here.
          # For example, if you use `openssl-sys`:
          # buildInputs = [ pkgs.openssl ];

          # cargoBuildFlags = ["--release"];

          # By default, buildRustPackage tries to find the binary specified by `pname`
          # or the first binary in `Cargo.toml`.
          # If you have multiple binaries or a specific one to install:
          # postInstall = ''
          #   mv $out/bin/another-binary $out/bin/my-rust-app
          # '';
        };
      in {
        websearchengines = myRustApp;
        default = myRustApp;
      }
    );
  };
}
