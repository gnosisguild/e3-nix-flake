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
  }: let
    enclaveVersions = builtins.fromJSON (builtins.readFile ./versions/enclave.versions.json);
    depLock = builtins.fromJSON (builtins.readFile ./versions/dep.lock.json);
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      mkEnclave = {version}: let
        hashes = enclaveVersions.${version} or (throw "Unknown enclave version ${version}. Available: ${builtins.concatStringsSep ", " (builtins.attrNames enclaveVersions)}");
        platformName =
          {
            "x86_64-linux" = "linux-x86_64";
            "aarch64-linux" = "linux-aarch64";
            "x86_64-darwin" = "macos-x86_64";
            "aarch64-darwin" = "macos-aarch64";
          }.${
            system
          } or null;
        hash =
          if platformName != null
          then hashes.${platformName} or null
          else null;
      in
        if hash == null
        then null
        else
          pkgs.stdenv.mkDerivation {
            pname = "enclave";
            inherit version;
            src = pkgs.fetchurl {
              url = "https://github.com/gnosisguild/enclave/releases/download/v${version}/enclave-${platformName}.tar.gz";
              inherit hash;
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
      mkE3Shell = {version}: let
        deps = depLock.${version} or (throw "Unknown e3 version ${version}. Available: ${builtins.concatStringsSep ", " (builtins.attrNames depLock)}");
        bb = barretenberg.lib.mkBB {
          inherit pkgs;
          version = deps.bb;
        };
        enclave = mkEnclave {inherit version;};
      in
        pkgs.mkShell {
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
    in {
      lib = {inherit mkEnclave mkE3Shell;};

      packages = builtins.mapAttrs (version: deps: let
        bb = barretenberg.lib.mkBB {
          inherit pkgs;
          version = deps.bb;
        };
        enclave = mkEnclave {version = version;};
      in
        {
          inherit bb;
        }
        // pkgs.lib.optionalAttrs (enclave != null) {
          inherit enclave;
        })
      depLock;

      devShells.default = mkE3Shell {version = "0.1.14";};
    })
    // {
      templates.default = {
        path = ./template;
        description = "New project using e3 tools";
      };
    };
}
