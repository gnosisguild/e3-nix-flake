
# NOTE: THIS WILL NOT WORK

This is currently under construction.

# Enclave Nix Flake

## Setup enclave on your cloud provider

1. **Server**

   This has been tested with Ubuntu 22.04 x64, add SSH key and SSH into the droplet as root

   NOTE: This will work the best with a fresh install
   
1. **Nix**

   ```bash
   # Run the following as root
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
   ```
   
   then exit and ssh back in to load the environment.

1. **User**

   ```bash
   # Add the user
   adduser --disabled-password --gecos "" myuser

   # Then login as that user
   su - myuser
   ```
   
1. **Direnv**

   ```bash
   # Run the direnv script
   curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-direnv.sh | bash
   

   # Don't forget to source your bashrc!
   source ~/.bashrc
   ```
   
1. **Enclave Project**

   Make a project folder then setup your project environment:

   ```bash
   # setup the project folder
   mkdir enclave && cd enclave
   
   # initialize our git repo
   git init

   # initialize the folder with our flake template
   nix flake init -t github:gnosisguild/e3-nix-flake

   # run direnv allow
   direnv allow
   ```


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

