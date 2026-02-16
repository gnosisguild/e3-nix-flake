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
      e3p = e3.packages.${system}."0.1.14"; # to upgrade change this version
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          e3p.bb
          e3p.enclave
          pkg-config
          openssl_3_6
          # Add any extra packages you need here from nixos.org
          # neovim git wget curl etc.. 
        ];
        shellHook = ''
          export OPENSSL_DIR="${pkgs.openssl_3_6.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl_3_6.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl_3_6.dev}/include"
          export E3_CUSTOM_BB="${e3p.bb}/bin/bb"
        '';
      };
    });
}
