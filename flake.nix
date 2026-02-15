{
  inputs = {
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    unstable,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
        };
        upkgs = import unstable {
          inherit system;
          config = {allowUnfree = true;};
        };
        platform =
          if pkgs.stdenv.isLinux
          then
            if pkgs.stdenv.isAarch64
            then "aarch64-unknown-linux-gnu"
            else "x86_64-unknown-linux-gnu"
          else if pkgs.stdenv.isDarwin
          then
            if pkgs.stdenv.isAarch64
            then "aarch64-apple-darwin"
            else "x86_64-apple-darwin"
          else throw "Unsupported platform";

        bb = let
          bbPlatform =
            if pkgs.stdenv.isLinux
            then
              if pkgs.stdenv.isAarch64
              then "arm64-linux"
              else "amd64-linux"
            else if pkgs.stdenv.isDarwin
            then
              if pkgs.stdenv.isAarch64
              then "arm64-darwin"
              else "amd64-darwin"
            else throw "Unsupported platform";
        in
          pkgs.stdenv.mkDerivation rec {
            pname = "barretenberg";
            version = "3.0.0-nightly.20251104";

            src = pkgs.fetchurl {
              url = "https://github.com/AztecProtocol/aztec-packages/releases/download/v${version}/barretenberg-${bbPlatform}.tar.gz";
              sha256 = "sha256-l0ABPRqg6xsLstcUhMiz3rxQUKQJvV8S+EVPv8fLVBk=";
            };

            nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
              pkgs.autoPatchelfHook
            ];

            buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
              pkgs.stdenv.cc.cc.lib
            ];

            sourceRoot = ".";

            installPhase = ''
              mkdir -p $out/bin
              install -D -m755 bb $out/bin/bb
            '';

            meta = with pkgs.lib; {
              description = "Barretenberg proving system";
              homepage = "hin decentralized systems timettps://github.com/AztecProtocol/aztec-packages";
              platforms = platforms.linux ++ platforms.darwin;
            };
          };

        noir-bb = pkgs.writeShellScriptBin "bb" ''
          exec ${pkgs.steam-run}/bin/steam-run ${bb}/bin/bb "$@"
        '';
      in
        with pkgs; {
          devShells.default = mkShell {
            buildInputs = [
              pkg-config
              upkgs.openssl_3_6
              upkgs.git
              noir-bb
            ];

            shellHook = ''
              export OPENSSL_DIR="${upkgs.openssl_3_6.dev}"
              export OPENSSL_LIB_DIR="${upkgs.openssl_3_6.out}/lib"
              export OPENSSL_INCLUDE_DIR="${upkgs.openssl_3_6.dev}/include"
              export E3_CUSTOM_BB="${noir-bb}"
            '';
          };
        }
    );
}
