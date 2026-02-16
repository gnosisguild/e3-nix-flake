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
      bb = e3.packages.${system}.bb;
      enclave = e3.packages.${system}.enclave;
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          bb
          enclave
          pkgs.pkg-config
          pkgs.openssl_3_6
          # add any other packages you need here and nix will install them
          # eg. git
        ];
        shellHook = ''
          export OPENSSL_DIR="${pkgs.openssl_3_6.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl_3_6.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl_3_6.dev}/include"
          export E3_CUSTOM_BB="${bb}/bin/bb"
        '';
      };
    });
}
