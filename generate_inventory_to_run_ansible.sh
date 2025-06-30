#!/bin/bash

# Usage: ./generate_inventory_to_run_ansible.sh [docker|native]
# Defaults to "docker" if no or unrecognized argument is given

set -e

# --- Configuration ---
PLAYBOOK_CHOICE="$1"
INVENTORY_FILE="ansible/inventory.ini"
KEY_FILE="ansible/artillery-key.pem"
DEFAULT_PLAYBOOK="ansible/playbook_docker.yml"
NATIVE_PLAYBOOK="ansible/playbook_native_vm.yml"
LOADTEST_FILE="loadtest.yml"
HISTORY_FILE="logs/test-history.log"

# --- Determine playbook and mode ---
case "$PLAYBOOK_CHOICE" in
  native)
    PLAYBOOK="$NATIVE_PLAYBOOK"
    MODE="native"
    ;;
  docker)
    PLAYBOOK="$DEFAULT_PLAYBOOK"
    MODE="docker"
    ;;
  *)
    echo "You were to pass the argument 'docker' or 'native'. Defaulting to 'docker'..."
    PLAYBOOK="$DEFAULT_PLAYBOOK"
    MODE="docker"
    ;;
esac

# --- Generate Ansible inventory from Terraform output ---
echo "Generating Ansible inventory from your Terraform outputs..."
{
  echo "[us_east]"
  terraform output -json us_east_ips | jq -r '.[]'

  echo ""
  echo "[eu_west]"
  terraform output -json eu_west_ips | jq -r '.[]'

  echo ""
  echo "[ap_southeast]"
  terraform output -json ap_southeast_ips | jq -r '.[]'

  echo ""
  echo "[all:vars]"
  echo "ansible_ssh_user=ubuntu"
  echo "ansible_ssh_private_key_file=${KEY_FILE}"
  echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'"
  echo "ansible_python_interpreter=/usr/bin/python3"
} > "$INVENTORY_FILE"

echo "Inventory generated at $INVENTORY_FILE"

# --- Check for loadtest.yml existence ---
if [ ! -f "$LOADTEST_FILE" ]; then
  echo "Missing $LOADTEST_FILE — you need to provide your test script in a loadtest.yml file saved in the root directory."
  exit 1
fi

# --- Create logs directory if missing ---
mkdir -p logs

# --- Load or initialize COUNT ---
if [ -f "$HISTORY_FILE" ]; then
  old_count=$(grep '^COUNT=' "$HISTORY_FILE" | cut -d= -f2)
  COUNT=$((old_count + 1))
else
  COUNT=1
  echo -e "COUNT=$COUNT\nMODE=$MODE\n---" > "$HISTORY_FILE"
fi

echo "Running Ansible playbook: $PLAYBOOK with count=$COUNT"

# --- Run the Ansible playbook ---
ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK" --extra-vars "test_count=$COUNT"

# --- Update top lines in history log ---
sed -i "1s/^COUNT=.*/COUNT=$COUNT/" "$HISTORY_FILE"
sed -i "2s/^MODE=.*/MODE=$MODE/" "$HISTORY_FILE"

# --- Append loadtest.yml to log ---
{
  echo -e "\n# loadtest.yml from test $COUNT"
  cat "$LOADTEST_FILE"
  echo -e "\n---"
} >> "$HISTORY_FILE"

echo "Logged test #$COUNT using mode: $MODE in $HISTORY_FILE"