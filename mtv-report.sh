#!/bin/bash

# mtv-report.sh
# A resilient utility to get consolidated migration progress from OpenShift Migration Toolkit for Virtualization (MTV) Plans.
# Requires: oc (kubectl) and jq installed and configured.

JQ_FULL_QUERY='
  [
    .[] as $plan 
    | ($plan.status.migration.vms // [])
    | .[]?
    | . as $vm
    | ($vm.pipeline // [])
    | .[]?
    | select(.name=="DiskTransferV2v")
    | select(.progress.total > 0)
    | {
      plan: $plan.metadata.name,
      name: $vm.name,
      completed: .progress.completed,
      total: .progress.total,
      percent: (.progress.completed / .progress.total * 100)
    }
  ] as $vms
  |
  (
    ($vms | map(.completed) | add // 0) as $completed_total
    |
    ($vms | map(.total) | add // 0) as $data_total
    |
    if $data_total > 0 then
      "TOTAL: \((100 * $completed_total / $data_total)|floor)% (\($completed_total) / \($data_total) MB)\n"
    else
      "TOTAL: 0% (0 / 0 MB)\n"
    end
  ),
  (
    $vms
    | sort_by(.percent)
    | reverse
    | .[]
    | "\(.plan): \(.name): \(.percent|floor)% (\(.completed) / \(.total) MB)"
  )
'

usage() {
  echo "Usage: $0 [--all | --active | --plan <PLAN1,PLAN2,...>]"
  echo "Report on Migration Toolkit for Virtualization (MTV) Plan status."
  echo ""
  echo "Options:"
  echo "  --all                        Report on all plans found in the current namespace."
  echo "  --active                     Report only on plans that are currently executing."
  echo "  --plan <PLAN1,PLAN2,...>     Report on a comma-separated list of specific plan names."
  echo "  --help                       Show this help message."
}

normalize_and_stream_json() {
    jq -c '
        if .kind and (.kind | endswith("List")) then
            .items[]
        elif .kind then
            .
        else
            empty
        end
    '
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

PLAN_SOURCE="" # Will hold the oc get command
FILTER_QUERY="" # Will hold the additional jq filter for active plans

case "$1" in
  --all)
    echo "--- Reporting ALL Migration Plans ---"
    PLAN_SOURCE="oc get plan -o json"
    ;;

  --active)
    echo "--- Reporting ACTIVE Migration Plans ---"
    PLAN_SOURCE="oc get plan -o json"
    FILTER_QUERY='
        select(
            (.status.executing == true)
            or
            (.status.conditions[]? | select(.type=="Executing" and .status=="True"))
        )
    '
    ;;

  --plan)
    if [[ -z "$2" ]]; then
      echo "Error: --plan requires a comma-separated list of plan names."
      usage
      exit 1
    fi
    
    PLAN_NAMES=$(echo "$2" | tr ',' ' ')
    echo "--- Reporting Specific Migration Plans: ($PLAN_NAMES) ---"
    PLAN_SOURCE="oc get plan $PLAN_NAMES -o json"
    ;;

  --help)
    usage
    exit 0
    ;;
  *)
    echo "Invalid option: $1"
    usage
    exit 1
    ;;
esac

eval "$PLAN_SOURCE" 2>/dev/null | normalize_and_stream_json | jq -c "$FILTER_QUERY" | jq -s -r "$JQ_FULL_QUERY"

echo "--------------------------------------------------------"
