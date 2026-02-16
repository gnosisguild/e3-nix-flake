# Contributing

## Updating the Flake

Prerequisites: `nix`, `jq`

### 1. Update version hashes
```bash
./update.sh <enclave-version> <bb-version>
```

This updates:

- `./versions/enclave.versions.json` — enclave hashes
- `./versions/bb.versions.json` — barretenberg hashes
- `./versions/dep.lock.json` — enclave → bb version mapping
- `./template/flake.nix` — Flake template

### 2. Check the template has updated correctly

`./template/flake.nix`:

```nix
e3Pkgs = e3.packages.${system}."<enclave-version>";
```

### 3. Update README

Update version numbers in `README.md` to match.

### 4. Commit and push
```bash
git add .
git commit -m "chore: bump enclave to <enclave-version>, bb to <bb-version>"
git push
```
