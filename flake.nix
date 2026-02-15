{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          config = {
            allowUnfree = true;
          };
        };
        upkgs = unstable;
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

        nargo = pkgs.stdenv.mkDerivation rec {
          pname = "nargo";
          version = "1.0.0-beta.15";

          src = pkgs.fetchurl {
            url =
              if version == "latest"
              then "https://github.com/noir-lang/noir/releases/latest/download/noir-${platform}.tar.gz"
              else "https://github.com/noir-lang/noir/releases/download/v${version}/noir-${platform}.tar.gz";
            # Leave sha256 empty on first run, nix will tell you the correct hash
            sha256 = "sha256-J1nqEA3kGlKYInA2kva3zVYEys/Xs2jkifzdwbxXKVc=";
          };

          nativeBuildInputs = [pkgs.autoPatchelfHook];
          buildInputs = [pkgs.stdenv.cc.cc.lib];

          sourceRoot = ".";

          installPhase = ''
            mkdir -p $out/bin
            for bin in nargo noir-profiler noir-inspector; do
              if [ -f "$bin" ]; then
                install -D -m755 "$bin" "$out/bin/$bin"
              fi
            done
          '';

          meta = with pkgs.lib; {
            description = "Noir programming language compiler";
            homepage = "https://noir-lang.org";
            platforms = platforms.linux ++ platforms.darwin;
          };
        };

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

        # Create steam-run wrapper for nargo
        nargo-fhs = pkgs.writeShellScriptBin "nargo" ''
          exec ${pkgs.steam-run}/bin/steam-run ${nargo}/bin/nargo "$@"
        '';

        noir-profiler-fhs = pkgs.writeShellScriptBin "noir-profiler" ''
          exec ${pkgs.steam-run}/bin/steam-run ${nargo}/bin/noir-profiler "$@"
        '';

        noir-inspector-fhs = pkgs.writeShellScriptBin "noir-inspector" ''
          exec ${pkgs.steam-run}/bin/steam-run ${nargo}/bin/noir-inspector "$@"
        '';
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
              nargo-fhs
              noir-profiler-fhs
              noir-inspector-fhs
              noir-bb
            ];

            shellHook = ''
              export OPENSSL_DIR="${upkgs.openssl_3_6.dev}"
              export OPENSSL_LIB_DIR="${upkgs.openssl_3_6.out}/lib"
              export OPENSSL_INCLUDE_DIR="${upkgs.openssl_3_6.dev}/include"
            '';
          };
        }
    );
}
