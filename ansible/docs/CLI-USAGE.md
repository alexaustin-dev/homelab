# CLI Usage

## Modes

**Interactive:** Prompts for config
```bash
./scripts/create-vm.sh
```

**Automated:** All via arguments
```bash
./scripts/create-vm.sh --host node --name vm --vmid 200 \
  --ip 10.0.10.20/24 --username user --password 'pass' --yes
```

## Required Arguments

| Argument | Example |
|----------|---------|
| `--host <name>` | `--host proxmox-node-1` |
| `--name <vm-name>` | `--name web-01` |
| `--vmid <id>` | `--vmid 201` |
| `--ip <ip/cidr>` | `--ip 10.0.10.20/24` |
| `--username <user>` | `--username admin` |
| `--password <pass>` | `--password 'pass123'` |

## Optional Arguments

| Argument | Default | Example |
|----------|---------|---------|
| `--cores <num>` | 2 | `--cores 4` |
| `--memory <mb>` | 4096 | `--memory 8192` |
| `--disk <gb>` | 50 | `--disk 100` |
| `--vlan <tag>` | 10 | `--vlan 20` |
| `--gateway <ip>` | 192.168.1.1 | `--gateway 10.0.1.1` |
| `--dns <ip>` | 192.168.1.1 | `--dns 10.0.1.1` |
| `--template <id>` | from host_vars | `--template 9000` |
| `--yes` | false | `--yes` (skip confirmation) |

## Examples

### Basic
```bash
./scripts/create-vm.sh \
  --host proxmox1 \
  --name test-vm \
  --vmid 201 \
  --ip 10.0.10.20/24 \
  --username admin \
  --password 'pass'
```

### Custom Resources
```bash
./scripts/create-vm.sh \
  --host proxmox1 \
  --name db-01 \
  --vmid 301 \
  --ip 10.0.10.30/24 \
  --cores 8 \
  --memory 16384 \
  --disk 500 \
  --username dbadmin \
  --password 'dbpass' \
  --yes
```

### Batch Deployment
```bash
for i in {1..3}; do
  ./scripts/create-vm.sh \
    --host proxmox1 \
    --name "web-0${i}" \
    --vmid "$((200 + i))" \
    --ip "10.0.10.$((20 + i))/24" \
    --username admin \
    --password 'pass' \
    --yes
done
```

### From Variables
```bash
VM_HOST="proxmox1"
VM_NAME="app-01"
VM_ID="210"
VM_IP="10.0.10.25/24"

./scripts/create-vm.sh \
  --host "$VM_HOST" \
  --name "$VM_NAME" \
  --vmid "$VM_ID" \
  --ip "$VM_IP" \
  --username admin \
  --password "$VM_PASSWORD" \
  --yes
```

## Tips

**View available hosts:**
```bash
cat inventory/hosts.yml
```

**Quote passwords with special chars:**
```bash
--password 'P@$$w0rd!'
```

**Dry run (see config before creating):**
```bash
./scripts/create-vm.sh --host ... --name ... # omit --yes
```

**Log output:**
```bash
./scripts/create-vm.sh [...] 2>&1 | tee deployment.log
```
