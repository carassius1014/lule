{
  inputs = {
    fenix = {
      url = "github:figsoda/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, fenix, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs.outPath {
          config = { allowUnfree = true; };
          inherit system;
          overlays = [ fenix.overlays.default ];
        };

        toolchain = fenix.packages.${system}.minimal.toolchain;
        platform = pkgs.makeRustPlatform {
          cargo = toolchain;
          rustc = toolchain;
        };

        lule = platform.buildRustPackage {
          pname = "lule";
          version = "0.1.0";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "pastel-0.8.0" =
                "1dnyqwy3n3ww7yma4rq21cgnf7r2136h56ask28hv7vdaynbam2c";
            };
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ cargo nixfmt rust-analyzer ];
        };

        packages.default = lule;

        apps.default = {
          type = "app";
          program = "${lule}/bin/lule";
        };
      });
}
