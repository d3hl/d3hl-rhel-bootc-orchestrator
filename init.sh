#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "== d3hl-rhel-bootc-orchestrator static baseline =="
echo "root: $ROOT"

if [[ "$ROOT" != "/home/d3/Github/d3hl-rhel-bootc-orchestrator" ]]; then
  echo "warning: expected /home/d3/Github/d3hl-rhel-bootc-orchestrator, got $ROOT"
fi

echo "== required files =="
required_files=(
  "AGENTS.md"
  "README.md"
  "feature_list.json"
  "claude-progress.md"
  "init.sh"
  "session-handoff.md"
)
for file in "${required_files[@]}"; do
  test -f "$file"
  echo "ok: $file"
done

echo "== shell syntax =="
bash -n "$0"
echo "ok: init.sh syntax"

echo "== feature list json =="
python3 -m json.tool feature_list.json >/dev/null
echo "ok: feature_list.json"

echo "== terraform static checks =="
if find terraform -name '*.tf' -print -quit | grep -q .; then
  if command -v terraform >/dev/null 2>&1; then
    terraform fmt -check -recursive terraform
    while IFS= read -r dir; do
      echo "terraform validate: $dir"
      terraform -chdir="$dir" init -backend=false -input=false >/dev/null
      terraform -chdir="$dir" validate
    done < <(find terraform -type f -name '*.tf' -printf '%h\n' | sort -u)
  else
    echo "skip: terraform not installed"
  fi
else
  echo "skip: no terraform files"
fi

echo "== ansible static checks =="
if find ansible -name '*.yml' -o -name '*.yaml' | grep -q .; then
  if command -v ansible-playbook >/dev/null 2>&1; then
    while IFS= read -r playbook; do
      echo "ansible syntax: $playbook"
      ansible-playbook --syntax-check "$playbook"
    done < <(find ansible/playbooks -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)
  else
    echo "skip: ansible-playbook not installed"
  fi

  if command -v ansible-lint >/dev/null 2>&1; then
    ansible-lint ansible/
  else
    echo "skip: ansible-lint not installed"
  fi
else
  echo "skip: no ansible yaml files"
fi

echo "== git whitespace =="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git diff --check
else
  echo "skip: not a git worktree yet"
fi

echo "static baseline complete"
