{
  description = "Enclave Nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    barretenberg.url = "path:./bb";
    barretenberg.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    barretenberg,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      bb = barretenberg.packages.${system}.default;
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          bb
          pkgs.pkg-config
          pkgs.openssl_3_6
        ];
        shellHook = ''
          export OPENSSL_DIR="${pkgs.openssl_3_6.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl_3_6.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl_3_6.dev}/include"
          export E3_CUSTOM_BB="${bb}/bin/bb"
        '';
      };
    })
    // {
      templates.default = {
        path = ./template;
        description = "New project using e3 tools";
      };
    };
}
