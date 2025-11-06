# MTV Report Utility (`mtv-report.sh`)

## Overview

The `mtv-report.sh` script is a command-line utility designed to provide **consolidated, real-time migration progress reports** for Virtual Machines workloads being moved to OpenShift using the **Migration Toolkit for Virtualization (MTV)** (also known as the Konveyor Forklift Operator). 

While the native MTV UI is excellent for managing plans, this tool addresses the need for quick, high-level summaries across multiple migration plans, calculating aggregate totals for data transfer.

The script leverages OpenShift's `oc` client and the powerful `jq` JSON processor to transform raw API status data into human-readable, actionable reports.

## 🛠️ Requirements

1.  **OpenShift CLI (`oc`):** Must be installed and configured to connect to your OpenShift cluster.
2.  **`jq`:** The command-line JSON processor must be installed on your system.
3.  **Permissions:** Your OpenShift user must have `get` permissions on `plans.forklift.konveyor.io` in the target namespace.

## ⚙️ Setup

1.  **Save the Script:** Save the provided Bash code into a file named `mtv-report.sh`.
2.  **Make it Executable:**
    ```bash
    chmod +x mtv-report.sh
    ```

## 📋 Usage

Run the script using `bash` or directly if you are in the directory. You must specify exactly one of the three primary flags.

| Command | Description |
| :--- | :--- |
| `./mtv-report.sh --all` | Provides an aggregate report and individual VM status for **ALL** migration plans in the current namespace. |
| `./mtv-report.sh --active` | Provides a report only for plans that are currently **Executing** (i.e., actively running data transfer). |
| `./mtv-report.sh --plan planA,planB` | Provides a consolidated report for a comma-separated list of **specific plan names**. |

**Example Commands:**

```bash
# Get status for only two plans
./mtv-report.sh --plan dev-group-oct25,prod-group-nov01

# Output for Active Plans (Shows overall progress and slow VMs)
./mtv-report.sh --active
