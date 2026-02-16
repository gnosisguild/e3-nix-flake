{
  description = "Noir Barretenberg Nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
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
              homepage = "https://github.com/AztecProtocol/aztec-packages";
              platforms = platforms.linux ++ platforms.darwin;
            };
          };
        noir-bb = pkgs.writeShellScriptBin "bb" ''
          exec ${pkgs.steam-run}/bin/steam-run ${bb}/bin/bb "$@"
        '';
      in
        with pkgs; {
          packages = {
            default = noir-bb;
            bb = noir-bb; # optional alias
          };
          vShells.default = mkShell {
            buildInputs = [
              noir-bb
            ];
            shellHook = ''
              export E3_CUSTOM_BB="${noir-bb}"
            '';
          };
        }
    ))
    // {
      templates.default = {
        path = ./template;
        description = "New project using e3 tools";
      };
    };
}
