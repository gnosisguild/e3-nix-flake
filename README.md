
# NOTE: THIS WILL NOT WORK

This is currently under construction.

# Enclave Nix Flake

## Setup enclave on your cloud provider

1. Create a server

   This has been tested with Ubuntu 22.04 x64, add SSH key and SSH into the droplet

   NOTE: This will work the best with a fresh install
   
1. Run the following:

   ```
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
   ```

1. make a folder then setup your project environment:

   ```
   mkdir enclave && cd enclave
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

