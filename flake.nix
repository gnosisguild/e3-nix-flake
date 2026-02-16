{
  description = "Enclave Nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bb.url = "path:./bb";
    bb.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    bb,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [
        bb.packages.${system}.default
        pkgs.pkg-config
        pkgs.openssl_3_6
      ];
      shellHook = ''
        export OPENSSL_DIR="${pkgs.openssl_3_6.dev}"
        export OPENSSL_LIB_DIR="${pkgs.openssl_3_6.out}/lib"
        export OPENSSL_INCLUDE_DIR="${pkgs.openssl_3_6.dev}/include"
      '';
    };
  };
}
