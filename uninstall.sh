#!/usr/bin/env bash
# Remove de ~/.kiro/ somente os links simbólicos que apontam para este kit.
#   ./uninstall.sh --projeto <repo>  remove a instalação de <repo>/.kiro/
# Nada que não seja link para o kit é tocado.
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIRO_DIR="${HOME}/.kiro"

if [[ "${1:-}" == "--projeto" ]]; then
  exec python3 "${KIT_DIR}/lib/projeto.py" remover "${2:-.}"
fi

remover_se_do_kit() {
  local link="$1"
  [[ -L "$link" ]] || return 0
  if [[ "$(readlink "$link")" == "${KIT_DIR}"* ]]; then
    rm "$link"
    echo "removido  $link"
  fi
}

for pasta in steering agents skills references templates hooks; do
  remover_se_do_kit "${KIRO_DIR}/${pasta}"
done
remover_se_do_kit "${KIRO_DIR}/settings/permissions.yaml"
for link in "${KIRO_DIR}"/prompts/*.md; do
  remover_se_do_kit "$link"
done

echo "Desinstalação concluída. Se você tinha um permissions.yaml próprio"
echo "salvo como permissions.yaml.bak, restaure-o com:"
echo "  mv ~/.kiro/settings/permissions.yaml.bak ~/.kiro/settings/permissions.yaml"
