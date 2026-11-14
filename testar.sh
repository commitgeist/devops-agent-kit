#!/usr/bin/env bash
# Atalho para os evals do kit. Guia completo: evals/README.md
#
#   ./testar.sh                 teste do hook + testes escritos à mão
#   ./testar.sh auto            testes automáticos de todos os agentes
#   ./testar.sh tudo            hook + escritos à mão + automáticos
#   ./testar.sh reviewer        tudo que tem "reviewer" no nome (à mão e auto)
#   ./testar.sh reviewer -r 3   o mesmo, 3 vezes cada
#   ./testar.sh hook            só o teste do hook (sem créditos)
#   ./testar.sh ver             abre o resultado no navegador
#   ./testar.sh lista           lista os testes e os agentes sem teste à mão
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTFOO="npx --yes promptfoo@0.125.1"
CONFIG="${KIT_DIR}/evals/promptfooconfig.yaml"
MANUAIS="${KIT_DIR}/evals/testes.yaml"
export PROMPTFOO_DISABLE_TELEMETRY=1 PROMPTFOO_DISABLE_UPDATE=1

cd "${KIT_DIR}"

# Avisa quais agentes só têm os testes automáticos e mostra um modelo de
# teste escrito à mão para copiar.
avisar_sem_teste() {
  local agente faltando=()
  for json in agents/*.json; do
    agente="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$json")"
    grep -qE "^\s*agente:\s*${agente}\s*$" "${MANUAIS}" || faltando+=("$agente")
  done
  [[ ${#faltando[@]} -eq 0 ]] && return 0
  echo "⚠ Só com testes automáticos (sem teste de qualidade escrito à mão): ${faltando[*]}"
  echo "  Modelo para colar no evals/testes.yaml:"
  echo
  echo "- description: ${faltando[0]} - <o que este teste garante>"
  echo "  vars:"
  echo "    fixture: api-node"
  echo "    agente: ${faltando[0]}"
  echo "    pedido: Use a skill <skill> ... Não pergunte nada."
  echo "  assert:"
  echo "    - type: python"
  echo "      value: file://asserts.py:arquivo_contem"
  echo "      config: {caminho: 'docs/<pasta>/*.md', regex: '<o que tem que aparecer>'}"
  echo "    - type: llm-rubric"
  echo "      value: <critério de qualidade em linguagem natural>"
  echo
}

case "${1:-}" in
  ver)
    exec ${PROMPTFOO} view
    ;;
  hook)
    exec python3 evals/testar-hook.py
    ;;
  lista)
    echo "Escritos à mão (evals/testes.yaml):"
    grep -E '^- description:' "${MANUAIS}" | sed -E 's/^- description:\s*/  /'
    echo
    echo "Automáticos (gerados de agents/*.json):"
    (cd evals && python3 testes_auto.py | sed 's/^/  /')
    echo
    avisar_sem_teste
    exit 0
    ;;
  -h|--help|ajuda)
    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
esac

rodar_hook=0
case "${1:-}" in
  ""|-*) filtro=(--filter-pattern '^(?!auto - )'); rodar_hook=1 ;;
  tudo)  filtro=(); rodar_hook=1; shift ;;
  auto)  filtro=(--filter-pattern '^auto - '); shift ;;
  *)     filtro=(--filter-pattern "$1"); shift ;;
esac

repeticoes=()
if [[ "${1:-}" == "-r" ]]; then
  repeticoes=(--repeat "$2")
  shift 2
fi

if [[ ${rodar_hook} -eq 1 ]]; then
  echo "== Teste do hook de segredos"
  python3 evals/testar-hook.py | tail -1
  echo
fi

avisar_sem_teste

echo "== Evals no Kiro (consome créditos)"
${PROMPTFOO} eval -c "${CONFIG}" --no-cache "${filtro[@]}" "${repeticoes[@]}" "$@" \
  && status=0 || status=$?

echo
echo "Detalhes: ./testar.sh ver"
exit "${status}"
