MTV Report Utility (mtv-report.sh)

Overview The mtv-report.sh script is a command-line utility designed to provide consolidated, real-time migration progress reports for VMware workloads being moved to OpenShift using the Migration Toolkit for Virtualization (MTV) (also known as the Konveyor Forklift Operator).

While the native MTV UI is excellent for managing plans, this tool addresses the need for quick, high-level summaries across multiple migration plans, calculating aggregate totals for data transfer.

The script leverages OpenShift's oc client and the powerful jq JSON processor to transform raw API status data into human-readable, actionable reports.

Requirements OpenShift CLI (oc): Must be installed and configured to connect to your OpenShift cluster.

jq: The command-line JSON processor must be installed on your system.

Permissions: Your OpenShift user must have get permissions on plans.forklift.konveyor.io in the target namespace.

Setup Save the Script: Save the provided Bash code into a file named mtv-report.sh.

Make it Executable:

Future Enhancements (Roadmap) The script is highly flexible and can be extended using the existing oc and jq pipeline. Potential enhancements include:

Custom Sorting (--sort-by):

Add flags to sort individual VM results by total size (--sort-by size), current completion percentage (--sort-by progress), or alphabetically by name.

Status Filtering (--status):

Filter the individual VM list to only show non-completed VMs (--status running), failed VMs (--status failed), or fully completed VMs (--status completed).

Output Formatting:

Add an option to output the final data in CSV format for easy import into spreadsheets or monitoring tools.
