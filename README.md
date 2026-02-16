# Enclave Nix Flake

If you have nix and direnv installed you can install enclave by running the following:

```bash
nix flake init -t github:gnosisguild/e3-nix-flake && direnv allow
```

You can check that it has installed correctly:

```bash
enclave --version
bb --version
echo $E3_CUSTOM_BB
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

This might take a little time.

Now when you return to this folder your dependencies will load automatically.

You can check everything is installed correctly

```bash
# Check enclave
enclave --version

# Check bb
bb --version

# Ensure env vars are exported
echo $E3_CUSTOM_BB
```

