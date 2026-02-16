# Enclave Nix Flake

If you have [nix and direnv installed](https://zero-to-nix.com/start/install):
```bash
nix flake init -t github:gnosisguild/e3-nix-flake && direnv allow
```

Verify installation:
```bash
enclave --version  # 0.1.14
bb --version       # 3.0.0-nightly.20251104
echo $E3_CUSTOM_BB # /nix/store/.../bb
```


## Cloud Setup

Tested with Digital Ocean Ubuntu 24.05.

### 1. Install Nix (as root)

```bash
curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
```

Exit and SSH back in to load the environment.
   
### 2. Create User
```bash
adduser --disabled-password --gecos "" myuser
sudo -iu myuser
```
   
### 3. Install Direnv (as user)
```bash
curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-direnv.sh | bash
source ~/.bashrc
```
   
### 4. Initialize Project

Make a project folder then setup your project environment:

```bash
mkdir enclave && cd enclave
```

Initialize your git repo - optional but recommended to save your dependency configuration as you add other dependencies and tools

```bash
git init
```

Initialize the folder with a basic `./flake.nix` demonstrating how to use enclave.

```bash
nix flake init -t github:gnosisguild/e3-nix-flake
```

Run direnv allow

```bash
direnv allow
```

## Updgrading Enclave

To upgrade enclave simply add the new version number to your `./flake.nix`

```nix
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
      e3Pkgs = e3.packages.${system}."0.1.14"; # Update this version here
    in {
      devShells.default = pkgs.mkShell {
        packages = [
          e3Pkgs.bb
          e3Pkgs.enclave
          pkgs.pkg-config
          pkgs.openssl_3_6
        ];
        shellHook = ''
          export OPENSSL_DIR="${pkgs.openssl_3_6.dev}"
          export OPENSSL_LIB_DIR="${pkgs.openssl_3_6.out}/lib"
          export OPENSSL_INCLUDE_DIR="${pkgs.openssl_3_6.dev}/include"
          export E3_CUSTOM_BB="${e3Pkgs.bb}/bin/bb"
        '';
      };
    });
}
```

Then run `direnv allow` to refresh dependencies. Barretenberg updates automatically.

## References

- [Nix](https://nixos.org/) — Package manager
- [Direnv](https://direnv.net/) — Environment loader
- [Nix Language Basics](https://nix.dev/tutorials/nix-language) — Learn the Nix expression language
- [Zero to Nix](https://zero-to-nix.com/) — Getting started guide
