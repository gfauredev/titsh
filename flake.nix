{
  description = "Nix flake Rust development environment";
  inputs = {
    # nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1"; # unstable Nixpkgs
    # fenix = {
    #   url = "https://flakehub.com/f/nix-community/fenix/0.1";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self, ... }@inputs:
    let
      systems =
        f:
        inputs.nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
          ]
          (
            system:
            f {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [
                  inputs.self.overlays.default
                ];
              };
            }
          );
    in
    {
      overlays.default = final: prev: {
        rustToolchain =
          with inputs.fenix.packages.${prev.stdenv.hostPlatform.system};
          combine (
            with stable;
            [
              clippy
              rustc
              cargo
              rustfmt
              rust-src
            ]
          );
      };
      devShells = systems (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              rustToolchain
              openssl
              pkg-config
              cargo-deny
              cargo-edit
              cargo-watch
              rust-analyzer
            ];
            env = {
              RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
            };
          };
        }
      );
    };
}
