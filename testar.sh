#!/usr/bin/env bash
# Atalho para os evals do kit. Guia completo: evals/README.md
#
#   ./testar.sh                 teste do hook + todos os evals
#   ./testar.sh guardrail       só os evals cujo nome contém "guardrail"
#   ./testar.sh reviewer -r 3   só os do reviewer, 3 vezes cada
#   ./testar.sh -r 3            todos, 3 vezes cada
#   ./testar.sh hook            só o teste do hook (sem créditos)
#   ./testar.sh ver             abre o resultado no navegador
#   ./testar.sh lista           lista os evals
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTFOO="npx --yes promptfoo@0.125.1"
CONFIG="${KIT_DIR}/evals/promptfooconfig.yaml"
export PROMPTFOO_DISABLE_TELEMETRY=1 PROMPTFOO_DISABLE_UPDATE=1

cd "${KIT_DIR}"

case "${1:-}" in
  ver)
    exec ${PROMPTFOO} view
    ;;
  hook)
    exec python3 evals/testar-hook.py
    ;;
  lista)
    grep -E '^\s*- description:' "${CONFIG}" | sed -E 's/^\s*- description:\s*/  /'
    exit 0
    ;;
  -h|--help|ajuda)
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
esac

filtro=()
if [[ -n "${1:-}" && "${1}" != -* ]]; then
  filtro=(--filter-pattern "$1")
  shift
fi

repeticoes=()
if [[ "${1:-}" == "-r" ]]; then
  repeticoes=(--repeat "$2")
  shift 2
fi

if [[ ${#filtro[@]} -eq 0 ]]; then
  echo "== Teste do hook de segredos"
  python3 evals/testar-hook.py | tail -1
  echo
fi

echo "== Evals no Kiro (consome créditos)"
${PROMPTFOO} eval -c "${CONFIG}" --no-cache "${filtro[@]}" "${repeticoes[@]}" "$@" \
  && status=0 || status=$?

echo
echo "Detalhes: ./testar.sh ver"
exit "${status}"
