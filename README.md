# Enclave Nix Flake

If you have nix and direnv installed you can install enclave by running the following:

```bash
nix flake init -t github:gnosisguild/e3-nix-flake && direnv allow
```

You can check that it has installed correctly:

```bash
❯ enclave --version
enclave 0.1.14

❯ bb --version
3.0.0-nightly.20251104

❯ echo $E3_CUSTOM_BB
/nix/store/q6ndlkhkf9pzp2rlpfhpz0ghly392ish-bb/bin/bb
```

## Setting up Enclave on a Digital Ocean Droplet

### 1. **Server**

Get a fresh installation using whatever distribution.

This has been tested with digital ocean stock ubuntu 24.05.

### 2. **Nix**

Run the following as **root**

```bash
curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
```

Then exit and ssh back in to load the environment.
   
### 3. **User**
   
Add a user as normal

```bash
adduser --disabled-password --gecos "" myuser
```

Then login as that user

```bash
sudo -iu myuser
```
   
### 4. **Direnv**

Run this direnv script **as your user**

```bash
curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-direnv.sh | bash
```

Don't forget to source your bashrc!

```bash
source ~/.bashrc
   ```
   
### 5. **Enclave Project**

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

This will install all the prerequisites


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

Once you have updated your nix file either `ctrl+C` to leave your direnv shell or run `direnv allow` to refresh your shells dependencies. Other internal dependencies such as barretenberg will be automatically updated in lockstep.
