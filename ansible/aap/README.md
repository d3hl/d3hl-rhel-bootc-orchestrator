# AAP workflow exports

This directory will hold Ansible Automation Platform workflow exports and
controller setup notes.

Initial policy:

- Do not import workflows during `./init.sh`.
- Do not launch jobs from CI.
- Keep credential values out of git.
- Reference credentials with `op://d3HLPRV/...` paths in docs only.
