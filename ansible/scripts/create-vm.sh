#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command-line arguments
INTERACTIVE=true
SKIP_CONFIRMATION=false

function show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Create a new VM on Proxmox in interactive or non-interactive mode.

Interactive Mode (default):
    $0

Non-Interactive Mode:
    $0 --host <hostname> --name <vm-name> --vmid <id> --ip <ip/cidr> \\
       --username <user> --password <pass> [OPTIONS]

Required Arguments (non-interactive mode):
    --host <name>           Proxmox host name from inventory
    --name <vm-name>        Name for the new VM
    --vmid <id>             VM ID (VMID)
    --ip <ip/cidr>          IP address in CIDR notation (e.g., 10.10.10.50/24)
    --username <user>       VM username
    --password <pass>       VM password

Optional Arguments:
    --cores <num>           CPU cores (default: 2)
    --memory <mb>           Memory in MB (default: 4096)
    --disk <gb>             Disk size in GB (default: 50)
    --vlan <tag>            VLAN tag (default: 10)
    --gateway <ip>          Gateway IP (default: from defaults)
    --dns <ip>              DNS server IP (default: from defaults)
    --template <id>         Template ID (default: from host_vars)
    --yes                   Skip confirmation prompt
    --help                  Show this help message

Examples:
    # Interactive mode
    $0

    # Non-interactive mode - minimal
    $0 --host oreki-pve-001 --name web-01 --vmid 201 \\
       --ip 10.10.10.20/24 --username admin --password 'SecurePass123'

    # Non-interactive mode - full options
    $0 --host oreki-pve-001 --name db-01 --vmid 202 \\
       --ip 10.10.10.30/24 --username admin --password 'SecurePass123' \\
       --cores 8 --memory 16384 --disk 200 --vlan 10 \\
       --gateway 10.10.10.1 --dns 10.10.10.1 --yes

EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            PROXMOX_HOST="$2"
            INTERACTIVE=false
            shift 2
            ;;
        --name)
            VM_NAME="$2"
            shift 2
            ;;
        --vmid)
            VM_ID="$2"
            shift 2
            ;;
        --cores)
            VM_CORES="$2"
            shift 2
            ;;
        --memory)
            VM_MEMORY="$2"
            shift 2
            ;;
        --disk)
            VM_DISK_SIZE="$2"
            shift 2
            ;;
        --vlan)
            VM_VLAN="$2"
            shift 2
            ;;
        --ip)
            VM_IP="$2"
            shift 2
            ;;
        --gateway)
            VM_GATEWAY="$2"
            shift 2
            ;;
        --dns)
            VM_NAMESERVER="$2"
            shift 2
            ;;
        --username)
            VM_USERNAME="$2"
            shift 2
            ;;
        --password)
            VM_PASSWORD="$2"
            shift 2
            ;;
        --template)
            TEMPLATE_ID="$2"
            shift 2
            ;;
        --yes)
            SKIP_CONFIRMATION=true
            shift
            ;;
        --help|-h)
            show_usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

if [ "$INTERACTIVE" = true ]; then
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Proxmox VM Creation Tool             ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
fi

# Change to ansible directory
cd "$(dirname "$0")/.." || exit 1

# Function to prompt with default
prompt_with_default() {
    local prompt=$1
    local default=$2
    local var_name=$3

    if [ -n "$default" ]; then
        read -p "$(echo -e ${YELLOW}${prompt}${NC}) [${GREEN}${default}${NC}]: " value
        value=${value:-$default}
    else
        read -p "$(echo -e ${YELLOW}${prompt}${NC}): " value
        while [ -z "$value" ]; do
            echo -e "${RED}This field is required!${NC}"
            read -p "$(echo -e ${YELLOW}${prompt}${NC}): " value
        done
    fi

    eval "$var_name='$value'"
}

# Get available Proxmox hosts from inventory dynamically
if [ "$INTERACTIVE" = true ]; then
    echo -e "${BLUE}Detecting Proxmox hosts from inventory...${NC}"
    echo ""
fi

# Use ansible-inventory to parse the hosts
if [ ! -f "inventory/hosts.yml" ]; then
    echo -e "${RED}Error: inventory/hosts.yml not found!${NC}"
    echo -e "${YELLOW}Please copy inventory/hosts.yml.example to inventory/hosts.yml and configure it.${NC}"
    exit 1
fi

# Get list of proxmox hosts using ansible-inventory
PROXMOX_HOSTS=$(ansible-inventory -i inventory/hosts.yml --list 2>/dev/null | \
    python3 -c "import sys, json; data=json.load(sys.stdin); hosts=data.get('proxmox_hosts', {}).get('hosts', []); print('\n'.join(hosts))" 2>/dev/null)

if [ -z "$PROXMOX_HOSTS" ]; then
    echo -e "${RED}Error: No proxmox hosts found in inventory!${NC}"
    echo -e "${YELLOW}Please check your inventory/hosts.yml configuration.${NC}"
    exit 1
fi

# Build arrays of host info
declare -a HOST_NAMES
declare -a HOST_IPS
declare -a HOST_TEMPLATE_IDS

counter=1
while IFS= read -r hostname; do
    # Get host IP
    host_ip=$(ansible-inventory -i inventory/hosts.yml --host "$hostname" 2>/dev/null | \
        python3 -c "import sys, json; print(json.load(sys.stdin).get('ansible_host', 'N/A'))" 2>/dev/null)

    # Try to get template ID from host_vars file if it exists
    template_id="N/A"
    if [ -f "host_vars/${hostname}.yml" ]; then
        template_id=$(grep -E "^proxmox_template_id:" "host_vars/${hostname}.yml" 2>/dev/null | awk '{print $2}' || echo "N/A")
    fi

    HOST_NAMES+=("$hostname")
    HOST_IPS+=("$host_ip")
    HOST_TEMPLATE_IDS+=("$template_id")

    counter=$((counter + 1))
done <<< "$PROXMOX_HOSTS"

# In non-interactive mode, validate and lookup the provided host
if [ "$INTERACTIVE" = false ]; then
    # Find the host in our arrays
    HOST_FOUND=false
    for i in "${!HOST_NAMES[@]}"; do
        if [ "${HOST_NAMES[$i]}" = "$PROXMOX_HOST" ]; then
            PROXMOX_IP="${HOST_IPS[$i]}"
            if [ -z "$TEMPLATE_ID" ]; then
                TEMPLATE_ID="${HOST_TEMPLATE_IDS[$i]}"
            fi
            HOST_FOUND=true
            break
        fi
    done

    if [ "$HOST_FOUND" = false ]; then
        echo -e "${RED}Error: Host '$PROXMOX_HOST' not found in inventory!${NC}"
        echo -e "${YELLOW}Available hosts:${NC}"
        for hostname in "${HOST_NAMES[@]}"; do
            echo "  - $hostname"
        done
        exit 1
    fi
else
    # Interactive mode - display available hosts
    echo -e "${BLUE}Available Proxmox hosts:${NC}"
    for i in "${!HOST_NAMES[@]}"; do
        num=$((i + 1))
        echo "  $num) ${HOST_NAMES[$i]} (${HOST_IPS[$i]}) - Template ID: ${HOST_TEMPLATE_IDS[$i]}"
    done
    echo ""

    # Get number of hosts for validation
    NUM_HOSTS=${#HOST_NAMES[@]}

    prompt_with_default "Select Proxmox host [1-$NUM_HOSTS]" "1" PROXMOX_CHOICE

    # Validate choice
    if ! [[ "$PROXMOX_CHOICE" =~ ^[0-9]+$ ]] || [ "$PROXMOX_CHOICE" -lt 1 ] || [ "$PROXMOX_CHOICE" -gt "$NUM_HOSTS" ]; then
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
    fi

    # Set selected host info (array is 0-indexed, choice is 1-indexed)
    ARRAY_INDEX=$((PROXMOX_CHOICE - 1))
    PROXMOX_HOST="${HOST_NAMES[$ARRAY_INDEX]}"
    PROXMOX_IP="${HOST_IPS[$ARRAY_INDEX]}"
    TEMPLATE_ID="${HOST_TEMPLATE_IDS[$ARRAY_INDEX]}"

    if [ "$TEMPLATE_ID" = "N/A" ]; then
        echo -e "${YELLOW}Warning: No template ID found for this host.${NC}"
        prompt_with_default "Enter template ID" "9000" TEMPLATE_ID
    fi

    echo ""
    echo -e "${GREEN}Selected: ${PROXMOX_HOST}${NC}"
    echo ""
fi

# VM Configuration
if [ "$INTERACTIVE" = true ]; then
    prompt_with_default "VM Name" "new-vm" VM_NAME
    prompt_with_default "VM ID (VMID)" "200" VM_ID
    prompt_with_default "CPU Cores" "2" VM_CORES
    prompt_with_default "Memory (MB)" "4096" VM_MEMORY
    prompt_with_default "Disk Size (GB)" "50" VM_DISK_SIZE

    echo ""
    echo -e "${BLUE}Network Configuration:${NC}"
    prompt_with_default "VLAN Tag" "10" VM_VLAN
    prompt_with_default "IP Address (CIDR)" "192.168.2.50/24" VM_IP
    prompt_with_default "Gateway" "192.168.1.1" VM_GATEWAY
    prompt_with_default "DNS Server" "192.168.1.1" VM_NAMESERVER

    echo ""
    echo -e "${BLUE}User Configuration:${NC}"
    prompt_with_default "Username" "alex" VM_USERNAME

    # Password input with confirmation
    while true; do
        read -s -p "$(echo -e ${YELLOW}VM Password:${NC}) " VM_PASSWORD
        echo ""
        if [ -z "$VM_PASSWORD" ]; then
            echo -e "${RED}Password cannot be empty!${NC}"
            continue
        fi
        read -s -p "$(echo -e ${YELLOW}Confirm Password:${NC}) " VM_PASSWORD_CONFIRM
        echo ""
        if [ "$VM_PASSWORD" = "$VM_PASSWORD_CONFIRM" ]; then
            break
        else
            echo -e "${RED}Passwords do not match! Please try again.${NC}"
        fi
    done

    echo ""
else
    # Non-interactive mode - validate required parameters
    MISSING_PARAMS=()

    [ -z "$VM_NAME" ] && MISSING_PARAMS+=("--name")
    [ -z "$VM_ID" ] && MISSING_PARAMS+=("--vmid")
    [ -z "$VM_IP" ] && MISSING_PARAMS+=("--ip")
    [ -z "$VM_USERNAME" ] && MISSING_PARAMS+=("--username")
    [ -z "$VM_PASSWORD" ] && MISSING_PARAMS+=("--password")

    if [ ${#MISSING_PARAMS[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing required parameters in non-interactive mode:${NC}"
        for param in "${MISSING_PARAMS[@]}"; do
            echo "  $param"
        done
        echo ""
        echo "Use --help for usage information"
        exit 1
    fi

    # Set defaults for optional parameters
    VM_CORES="${VM_CORES:-2}"
    VM_MEMORY="${VM_MEMORY:-4096}"
    VM_DISK_SIZE="${VM_DISK_SIZE:-50}"
    VM_VLAN="${VM_VLAN:-10}"
    VM_GATEWAY="${VM_GATEWAY:-192.168.1.1}"
    VM_NAMESERVER="${VM_NAMESERVER:-192.168.1.1}"
fi
# Display configuration summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}VM Configuration Summary:${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "Proxmox Host:  ${GREEN}${PROXMOX_HOST}${NC}"
echo -e "Proxmox IP:    ${GREEN}${PROXMOX_IP}${NC}"
echo -e "Template ID:   ${GREEN}${TEMPLATE_ID}${NC}"
echo -e "VM Name:       ${GREEN}${VM_NAME}${NC}"
echo -e "VM ID:         ${GREEN}${VM_ID}${NC}"
echo -e "CPU Cores:     ${GREEN}${VM_CORES}${NC}"
echo -e "Memory:        ${GREEN}${VM_MEMORY} MB${NC}"
echo -e "Disk Size:     ${GREEN}${VM_DISK_SIZE} GB${NC}"
echo -e "VLAN:          ${GREEN}${VM_VLAN}${NC}"
echo -e "IP Address:    ${GREEN}${VM_IP}${NC}"
echo -e "Gateway:       ${GREEN}${VM_GATEWAY}${NC}"
echo -e "DNS:           ${GREEN}${VM_NAMESERVER}${NC}"
echo -e "Username:      ${GREEN}${VM_USERNAME}${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Confirmation prompt (skip if --yes flag provided)
if [ "$SKIP_CONFIRMATION" = false ]; then
    read -p "$(echo -e ${YELLOW}Proceed with VM creation? [y/N]:${NC}) " CONFIRM

    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        echo -e "${RED}Aborted.${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${GREEN}🚀 Creating VM...${NC}"
echo ""

# Run Ansible playbook with all parameters
ansible-playbook playbooks/proxmox/create-vm-workflow.yml \
    --ask-vault-pass \
    -e "proxmox_node_name=${PROXMOX_HOST}" \
    -e "proxmox_node_ip=${PROXMOX_IP}" \
    -e "proxmox_template_id=${TEMPLATE_ID}" \
    -e "vm_name=${VM_NAME}" \
    -e "vm_id=${VM_ID}" \
    -e "vm_cores=${VM_CORES}" \
    -e "vm_memory=${VM_MEMORY}" \
    -e "vm_disk_size=${VM_DISK_SIZE}" \
    -e "vm_network_tag=${VM_VLAN}" \
    -e "vm_ip=${VM_IP}" \
    -e "vm_gateway=${VM_GATEWAY}" \
    -e "vm_nameserver=${VM_NAMESERVER}" \
    -e "vm_username=${VM_USERNAME}" \
    -e "vm_password=${VM_PASSWORD}"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅ VM Created Successfully!          ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Connect with:${NC}"
    VM_IP_CLEAN=$(echo $VM_IP | cut -d'/' -f1)
    echo -e "${GREEN}ssh ${VM_USERNAME}@${VM_IP_CLEAN}${NC}"
else
    echo ""
    echo -e "${RED}❌ VM creation failed!${NC}"
    exit 1
fi
