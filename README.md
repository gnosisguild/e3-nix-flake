
# NOTE: THIS MAY NOT WORK

# Enclave Nix Flake

## Setup Enclave on your cloud provider


<details>
<summary>Digital Ocean</summary>

1. Create droplet: Ubuntu 22.04 x64, add SSH key
2. Under Advanced Options → Initialization Scripts, paste:

```yaml
#cloud-config
runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=digitalocean NIX_CHANNEL=nixos-24.05 bash 2>&1 | tee /tmp/infect.log
```

3. Create. Wait ~4 min. SSH in.
</details>

## Setup the binaries

1. Clone the template repo:

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

