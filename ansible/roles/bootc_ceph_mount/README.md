# bootc_ceph_mount

Mounts the CephFS filesystem `cFS` persistently on bootc target VMs.

## Prerequisites

- `ceph-common` baked into the bootc image (`.5`+)
- `bootc_targets` inventory populated (`HANDOFF-001` passing)
- 1Password item `ufj6ka4i7gmqwky7i6djulkrgq` in vault `d3HLPRV` ("Ceph Storage")

## What it does

1. Writes `/etc/ceph/ceph.conf` (cluster config from 1Password)
2. Writes `/etc/ceph/ceph.client.rhel.keyring` (client key, mode 0600)
3. Extracts the base64 key and adds it to the **Linux kernel keyring** (binary payload,
   base64 string as description) — required in kernel 6.x where `key=<base64>` in CephFS
   mount options is a keyring lookup, not a raw value
4. Writes `/etc/ceph/load-keyring.py` + `ceph-rhel-keyring.service` (boot persistence —
   the service populates the kernel keyring before `local-fs.target`)
5. Enables `ceph-rhel-keyring.service`
6. Loads the `ceph` kernel module
7. Mounts `cFS` at `/mnt/cfs` and adds a persistent fstab entry (`_netdev`)

## Key variables

| Variable | Default | Description |
|----------|---------|-------------|
| `bootc_ceph_conf_env` | `CEPH_CONF` | Env var carrying ceph.conf content |
| `bootc_ceph_keyring_env` | `CEPH_KEYRING` | Env var carrying keyring content |
| `bootc_ceph_conf_path` | `/etc/ceph/ceph.conf` | Destination on VM |
| `bootc_ceph_keyring_path` | `/etc/ceph/ceph.client.rhel.keyring` | Destination on VM |
| `bootc_ceph_client_name` | `rhel` | CephFS client identity |
| `bootc_ceph_fs_name` | `cFS` | CephFS filesystem name |
| `bootc_ceph_mount_point` | `/mnt/cfs` | Local mount path |

## Run

```bash
# Write SSH key to tempfile (path required; not resolvable as op:// reference)
op read "op://d3HLPRV/d3_ops/private key" > /tmp/d3_ops_key && chmod 600 /tmp/d3_ops_key

BOOTC_SSH_PRIVATE_KEY_FILE=/tmp/d3_ops_key \
  op run --env-file ansible/op-run.ceph.example -- \
  ansible-playbook ansible/playbooks/bootc_ceph_mount.yaml
```
