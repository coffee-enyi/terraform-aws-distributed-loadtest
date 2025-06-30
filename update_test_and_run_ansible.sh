#!/bin/bash

# Usage: ./update_test_and_run_ansible.sh

set -e

# --- Config ---
INVENTORY_FILE="ansible/inventory.ini"
LOADTEST_FILE="loadtest.yml"
HISTORY_FILE="logs/test-history.log"
UPDATE_PLAYBOOK="ansible/playbook_update_testcase.yml"

# --- Validation ---
if [ ! -f "$LOADTEST_FILE" ]; then
  echo "Missing $LOADTEST_FILE — cannot run test. Please provide a loadtest.yml with artillery syntax"
  exit 1
fi

if [ ! -f "$INVENTORY_FILE" ]; then
  echo "Missing $INVENTORY_FILE — run generate_inventory_to_run_ansible.sh first"
  exit 1
fi

if [ ! -f "$HISTORY_FILE" ]; then
  echo "Missing $HISTORY_FILE — please run initial setup script first"
  exit 1
fi

# --- Read COUNT and MODE from top of log ---
source <(head -n 2 "$HISTORY_FILE")

if [[ -z "$MODE" || -z "$COUNT" ]]; then
  echo "Invalid or missing MODE/COUNT in $HISTORY_FILE"
  exit 1
fi

# --- Increment count ---
COUNT=$((COUNT + 1))

# --- Update log top lines ---
sed -i "1s/^COUNT=.*/COUNT=$COUNT/" "$HISTORY_FILE"
sed -i "2s/^MODE=.*/MODE=$MODE/" "$HISTORY_FILE"

# --- Append test config to history ---
{
  echo -e "\n# loadtest.yml from test $COUNT"
  cat "$LOADTEST_FILE"
  echo -e "\n---"
} >> "$HISTORY_FILE"

# --- Run the special playbook that can handle both modes ---
echo "Running update playbook with MODE=$MODE for test #$COUNT..."

ansible-playbook -i "$INVENTORY_FILE" "$UPDATE_PLAYBOOK" --extra-vars "mode=$MODE test_count=$COUNT"

echo "Test #$COUNT completed and logged using mode: $MODE"