
# NOTE: THIS WILL NOT WORK

This is currently under construction.

# Enclave Nix Flake

## Setup Enclave on your cloud provider


<details>
<summary>Digital Ocean</summary>

1. Create droplet: Ubuntu 22.04 x64, add SSH key and SSH into the droplet
2. Run the following:

  ```
  curl -fsSL https://raw.githubusercontent.com/gnosisguild/e3-nix-flake/refs/heads/master/install-nix.sh | bash
  ```
</details>

## Setup the binaries

1. make a folder then setup your project environment:

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

