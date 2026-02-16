
# NOTE: THIS WILL NOT WORK

This is currently under construction.

# Enclave Nix Flake

## Setup enclave on your cloud provider

1. **Server**

   Get a fresh installation using whatever distribution.
   
   This has been tested with digital ocean stock ubuntu 24.05.
   
1. **Nix**

   Run the following as **root**

   ```bash
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
   ```
   
   Then exit and ssh back in to load the environment.
   
1. **User**
   
   Add a user as normal
   
   ```bash
   adduser --disabled-password --gecos "" myuser
   ```
   
   Then login as that user

   ```bash
   sudo -iu myuser
   ```
   
1. **Direnv**
   Run this direnv script **as your user**
   
   ```bash
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-direnv.sh | bash
   ```

   Don't forget to source your bashrc!
   
   ```bash
   source ~/.bashrc
   ```
   
1. **Enclave Project**

   Make a project folder then setup your project environment:

   ```bash
   mkdir enclave && cd enclave
   ```

   Initialize our git repo - optional but recommended to save your dependency configuration
   
   ```bash
   git init
   ```
   
   Initialize the folder with our flake template

   ```bash
   nix flake init -t github:gnosisguild/e3-nix-flake
   ```
   
   Run direnv allow

   ```bash
   direnv allow
   ```

   Now when you return to this folder your dependencies will load automatically.

Thats it.

You can check everything is installed correctly

```bash
# Check enclave
enclave --version

# Check bb
bb --version

# Ensure env vars are exported
echo $E3_CUSTOM_BB
```

