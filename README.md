
# NOTE: THIS WILL NOT WORK

This is currently under construction.

# Enclave Nix Flake

## Setup enclave on your cloud provider

1. Create a server

   This has been tested with Ubuntu 22.04 x64, add SSH key and SSH into the droplet as root

   NOTE: This will work the best with a fresh install
   
1. As root setup nix:

   ```
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
   ```
   
   then exit and ssh back in to load the environment.

1. Setup a user however you normally would

   ```
   adduser --disabled-password --gecos "" myuser
   ```

   ```
   su - myuser
   ```
1. Setup direnv for your user:

   ```
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-direnv.sh | bash
   ```

   Don't forget to source your bashrc!

   ```
   source ~/.bashrc
   ```
   
1. Make a project folder then setup your project environment:

   ```
   mkdir enclave && cd enclave && git init
   ```

   ```
   nix flake init -t github:gnosisguild/e3-nix-flake
   ```

2. Run direnv allow

   ```bash
   direnv allow
   ```

3. Ensure the binaries are installed correctly

   ```bash
   enclave --version
   ```

   ```bash
   bb --version
   ```

   Ensure that the bb override env var is set correctly

   ```bash
   echo $E3_CUSTOM_BB
   ```

