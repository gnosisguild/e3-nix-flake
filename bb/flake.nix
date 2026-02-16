{
  description = "Barretenberg Nix Flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
  };
  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    versions = builtins.fromJSON (builtins.readFile ../bb.versions.json);
  in {
    lib.mkBB = {
      pkgs,
      version,
    }: let
      hashes = versions.${version} or (throw "Unknown version ${version}. Available: ${builtins.concatStringsSep ", " (builtins.attrNames versions)}");
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
      bb = pkgs.stdenv.mkDerivation {
        pname = "barretenberg";
        inherit version;
        src = pkgs.fetchurl {
          url = "https://github.com/AztecProtocol/aztec-packages/releases/download/v${version}/barretenberg-${bbPlatform}.tar.gz";
          sha256 = hashes.${bbPlatform} or (throw "No hash for ${bbPlatform} in version ${version}");
        };
        nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [pkgs.autoPatchelfHook];
        buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [pkgs.stdenv.cc.cc.lib];
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
    in
      if pkgs.stdenv.isLinux
      then
        pkgs.buildFHSEnv {
          name = "bb";
          targetPkgs = p: [bb p.stdenv.cc.cc.lib];
          runScript = "${bb}/bin/bb";
        }
      else bb;

    lib.versions = builtins.attrNames versions;
  };
}
