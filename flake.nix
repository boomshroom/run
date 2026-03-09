{
  inputs = {
    naersk = {
      
      url = "github:nix-community/naersk/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, naersk, rust }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust.overlays.default ];
        };
        toolchain = pkgs.rust-bin.nightly."2026-03-09".default.override {
          extensions = [ "rust-src" ];
          targets = [ "x86_64-unknown-linux-musl" ];
        };
        naersk-lib = naersk.lib.${system}.override {
          rustc = toolchain;
          cargo = toolchain;
        };
      in
      {
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;

          nativeBuildInputs = [ pkgs.pkgsStatic.stdenv.cc ];
          additionalCargoLock = "${toolchain}/lib/rustlib/src/rust/library/Cargo.lock";

          CARGO_BUILD_TARGET = "x86_64-unknown-linux-musl";
          CARGO_BUILD_RUSTFLAGS = "-C target-feature=+crt-static";
        };
        devShell = with pkgs; mkShell {
          buildInputs = [ toolchain pre-commit pkgsStatic.stdenv.cc ];
        };
      }
    );
}
