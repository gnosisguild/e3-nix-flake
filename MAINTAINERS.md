# Contributing

## Updating the Flake

Prerequisites: `nix`, `jq`
```bash
./update.sh <enclave-version> <bb-version>
```

This updates:

- `./versions/enclave.versions.json` — enclave hashes
- `./versions/bb.versions.json` — barretenberg hashes
- `./versions/dep.lock.json` — enclave → bb version mapping

Commit and push the changes.
