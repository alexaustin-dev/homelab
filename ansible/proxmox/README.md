# Homelab Ansible

Ansible automation for my Proxmox homelab. Handles VM provisioning and configuration. Used Claude to help organize the README.md and the supporting docs.
Also used Claude to help create the `create-vm.sh` script.

## What This Does

- Automated VM creation on Proxmox nodes
- Cloud-init configuration preconfigured on each VM.
- Network setup (VLANs, static IPs)
- SSH key deployment

## Usage

### Interactive
```bash
./scripts/create-vm.sh
```

### Automated
```bash
./scripts/create-vm.sh \
  --host proxmox-node \
  --name vm-name \
  --vmid 200 \
  --ip 10.0.10.20/24 \
  --username admin \
  --password 'password' \
  --yes
```

See `./scripts/create-vm.sh --help` for all options.

## Structure

```
inventory/       - Proxmox nodes and VMs
group_vars/      - Shared variables (vault for credentials)
playbooks/       - Ansible playbooks
scripts/         - Helper scripts
```

## Notes

Private configs (hosts.yml, vault.yml) are gitignored for security reasons.
