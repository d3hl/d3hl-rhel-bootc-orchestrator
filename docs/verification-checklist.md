# Verification checklist

## Static baseline

```bash
pwd
./init.sh
git diff --check
```

Expected result: static validation only. No live HCP Terraform run, AAP import,
Quay/private registry change, image push, Red Hat subscription use, or Proxmox
mutation.

## Secret safety

- Search for common plaintext secret patterns before committing.
- Keep all secret references in `op://d3HLPRV/...` form.
- Report missing secret paths by reference only.

## Live action gate

Before any live action, record:

- Target system and account boundary.
- Read-only pre-check command and result.
- Planned mutation and rollback hint.
- Explicit approval from the user.
