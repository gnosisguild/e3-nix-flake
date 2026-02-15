{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
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
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;};
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            e3.packages.${system}.bb
            # Add your own packages here
          ];
        };
      }
    );
}
