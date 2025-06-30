#!/bin/bash

# Fetch Artillery test results from all servers
# Uses current COUNT from logs/test-history.log
# Saves into results/test-<COUNT>/ and overwrites if already present

set -e

# --- Configuration ---
HISTORY_FILE="logs/test-history.log"
INVENTORY_FILE="ansible/inventory.ini"
PLAYBOOK_FILE="ansible/playbook_results_fetch.yml"

# --- Validate & Load State ---
if [ ! -f "$HISTORY_FILE" ]; then
  echo "$HISTORY_FILE not found. Cannot continue."
  exit 1
fi

# Load COUNT and MODE from top of test-history.log
source <(head -n 2 "$HISTORY_FILE")

if [[ -z "$COUNT" || -z "$MODE" ]]; then
  echo "Missing COUNT or MODE in $HISTORY_FILE"
  exit 1
fi

# --- Prepare results directory ---
RESULT_SUBDIR="results/test-$COUNT"
mkdir -p "$RESULT_SUBDIR"

echo "Fetching reports for test COUNT=$COUNT, MODE=$MODE"
echo "Reports will be saved in: $RESULT_SUBDIR (overwrite allowed)"

# --- Run Ansible Playbook to Fetch Reports ---
ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK_FILE" \
  --extra-vars "test_count=$COUNT results_dir=$RESULT_SUBDIR"

# --- Count how many reports were fetched ---
REPORT_COUNT=$(find "$RESULT_SUBDIR" -type f -name "*report-${COUNT}.json" | wc -l)

echo "$REPORT_COUNT report(s) fetched to: $RESULT_SUBDIR"