{
  description = "New e3 project";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    e3.url = "github:gnosisguild/e3-nix-flake";
    e3.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    e3,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      e3Pkgs = e3.packages.${system}."0.1.14";
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          e3Pkgs.bb
          e3Pkgs.enclave
          pkgs.pkg-config
          pkgs.openssl_3_6
        ];
        shellHook = ''
          export OPENSSL_DIR="${pkgs.openssl_3_6.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl_3_6.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl_3_6.dev}/include"
          export E3_CUSTOM_BB="${e3Pkgs.bb}/bin/bb"
        '';
      };
    });
}
