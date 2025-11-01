# Homelab Ansible

Ansible automation for my Proxmox homelab. Handles VM provisioning and configuration.

## What This Does

- Automated VM creation on Proxmox nodes
- Cloud-init configuration
- Network setup (VLANs, static IPs)
- SSH key deployment

## Requirements

- Ansible 2.9+
- Python 3.x
- SSH access to Proxmox nodes
- Proxmox API token

## Setup

Copy example files and add your config:

```bash
cp inventory/hosts.yml.example inventory/hosts.yml
cp group_vars/proxmox_hosts/vault.yml.example group_vars/proxmox_hosts/vault.yml
```

Edit with your IPs and credentials, then encrypt:

```bash
ansible-vault encrypt group_vars/proxmox_hosts/vault.yml
```

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

Private configs (hosts.yml, vault.yml) are gitignored. Use the .example files as templates.
