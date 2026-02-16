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

      enclavePlatformMap = {
        "x86_64-linux" = {
          asset = "enclave-linux-x86_64.tar.gz";
          hash = "sha256-D5jeY8YpuMAU/5iXIruZrmwuKNDBlf3nRH9H4Nr+kd4=";
        };
        "aarch64-darwin" = {
          asset = "enclave-macos-aarch64.tar.gz";
          hash = "sha256-XTU59pAk8GTEP86G7O0p8vLScVAnp6ruKV/CsUhm2rM=";
        };
      };

      enclaveVersion = "0.1.14";

      enclave = let
        platform = enclavePlatformMap.${system} or null;
      in
        if platform == null
        then null
        else
          pkgs.stdenv.mkDerivation {
            pname = "enclave";
            version = enclaveVersion;

            src = pkgs.fetchurl {
              url = "https://github.com/gnosisguild/enclave/releases/download/v${enclaveVersion}/${platform.asset}";
              hash = platform.hash;
            };

            sourceRoot = ".";

            nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
              pkgs.autoPatchelfHook
            ];

            buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
              pkgs.stdenv.cc.cc.lib
              pkgs.openssl
            ];

            unpackPhase = ''
              tar xzf $src
            '';

            installPhase = ''
              mkdir -p $out/bin
              find . -name "enclave" -type f -executable | head -1 | xargs -I{} cp {} $out/bin/enclave \
                || cp enclave $out/bin/enclave
              chmod +x $out/bin/enclave
            '';

            dontBuild = true;
            dontConfigure = true;

            meta = with pkgs.lib; {
              description = "Enclave CLI - encrypted execution environments";
              homepage = "https://github.com/gnosisguild/enclave";
              license = licenses.mit;
            };
          };
    in {
      packages = pkgs.lib.optionalAttrs (enclave != null) {
        enclave = enclave;
        default = enclave;
      };

      devShells.default = pkgs.mkShell {
        packages =
          [
            bb
            pkgs.pkg-config
            pkgs.openssl_3_6
          ]
          ++ pkgs.lib.optionals (enclave != null) [enclave];

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
