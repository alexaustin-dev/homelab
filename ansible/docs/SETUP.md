# Setup

## Prerequisites

- Ansible 2.9+
- Python 3.x
- SSH access to Proxmox nodes
- Proxmox API token

## Configuration

### 1. Inventory

```bash
cp inventory/hosts.yml.example inventory/hosts.yml
```

Edit with your Proxmox node IPs and VM IPs.

### 2. Host Variables

```bash
cp host_vars/proxmox-node-1.yml.example host_vars/your-hostname.yml
```

Set `proxmox_node_name`, `proxmox_node_ip`, and `proxmox_template_id` for each node.

### 3. API Credentials

```bash
cp group_vars/proxmox_hosts/vault.yml.example group_vars/proxmox_hosts/vault.yml
```

Edit vault.yml with your API token:

```yaml
vault_proxmox_api_user: "ansible@pve"
vault_proxmox_api_token_id: "your-token-id"
vault_proxmox_api_token_secret: "your-token-secret"
```

Encrypt it:

```bash
ansible-vault encrypt group_vars/proxmox_hosts/vault.yml
```

### 4. SSH Keys

Generate a key if needed:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/homelab_key
ssh-copy-id -i ~/.ssh/homelab_key.pub root@your-proxmox-ip
```

## Create Proxmox API Token

In Proxmox web UI:
1. Datacenter → Permissions → API Tokens
2. Add token for ansible user
3. Copy token ID and secret to vault.yml

## Test

```bash
ansible proxmox_hosts -m ping --ask-vault-pass
```

Should return "pong" from all hosts.
