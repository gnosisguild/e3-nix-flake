# Contributing

## Updating the Flake

Prerequisites: `nix`, `jq`

### Run the update script
```bash
./update.sh <enclave-version> <bb-version>
```

This updates:

- `./versions/enclave.versions.json` — enclave hashes
- `./versions/bb.versions.json` — barretenberg hashes
- `./versions/dep.lock.json` — enclave → bb version mapping
- `./template/flake.nix` — Flake template gets a new enclave version
- `./README.md` — Update the code block with the contents of the template


