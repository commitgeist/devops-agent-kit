#!/usr/bin/env bash
# Instala o devops-agent-kit em ~/.kiro/ por meio de links simbólicos.
#
#   ./install.sh                    # global: ~/.kiro/ (todos os repositórios)
#   ./install.sh --projeto <repo>   # só no repositório: <repo>/.kiro/, fora do git
#
# Pastas linkadas inteiras: steering, agents, skills, references, templates, hooks.
# Prompts: o Kiro CLI só descobre ~/.kiro/prompts/*.md (sem subpastas), então
# cada arquivo de prompts/reais/ é linkado individualmente
# dentro de ~/.kiro/prompts/.
# Permissões globais: settings/permissions.yaml é linkado como
# ~/.kiro/settings/permissions.yaml (guardrails de segredos para todos os
# agentes). Se você já tiver esse arquivo, o script não mexe nele e mostra
# como mesclar.
#
# Regra de segurança: nada que não seja link simbólico é sobrescrito. Links
# simbólicos que apontam para outro lugar (ou quebrados) são reapontados.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIRO_DIR="${HOME}/.kiro"

# Modo projeto: instala em <repo>/.kiro/ (fora do git), em vez de ~/.kiro/.
if [[ "${1:-}" == "--projeto" ]]; then
  command -v python3 >/dev/null || { echo "ERRO: o modo --projeto precisa de python3."; exit 1; }
  exec python3 "${KIT_DIR}/lib/projeto.py" instalar "${2:-.}"
fi
PASTAS=(steering agents skills references templates hooks)

erros=0

link_item() {
  local origem="$1" destino="$2"

  if [[ -L "$destino" ]]; then
    local atual
    atual="$(readlink "$destino")"
    if [[ "$atual" == "$origem" ]]; then
      echo "ok        $destino"
      return 0
    fi
    ln -sfn "$origem" "$destino"
    echo "reapontado $destino -> $origem (antes: $atual)"
    return 0
  fi

  if [[ -e "$destino" ]]; then
    echo "ERRO      $destino já existe e não é link simbólico."
    echo "          Mova ou remova manualmente e rode o install.sh de novo:"
    echo "          mv \"$destino\" \"$destino.bak\""
    erros=$((erros + 1))
    return 0
  fi

  ln -s "$origem" "$destino"
  echo "criado    $destino -> $origem"
}

# Verifica conflitos antes de alterar qualquer coisa.
conflitos=0
for pasta in "${PASTAS[@]}"; do
  destino="${KIRO_DIR}/${pasta}"
  if [[ -e "$destino" && ! -L "$destino" ]]; then
    echo "ERRO: ${destino} já existe e não é link simbólico."
    conflitos=$((conflitos + 1))
  fi
done
if [[ -L "${KIRO_DIR}/prompts" ]]; then
  echo "ERRO: ${KIRO_DIR}/prompts é um link simbólico. Os prompts precisam de"
  echo "      uma pasta real com um link por arquivo. Remova o link e rode de novo:"
  echo "      rm \"${KIRO_DIR}/prompts\""
  conflitos=$((conflitos + 1))
elif [[ -e "${KIRO_DIR}/prompts" && ! -d "${KIRO_DIR}/prompts" ]]; then
  echo "ERRO: ${KIRO_DIR}/prompts existe e não é diretório."
  conflitos=$((conflitos + 1))
fi
PERMISSOES="${KIRO_DIR}/settings/permissions.yaml"
if [[ -e "$PERMISSOES" && ! -L "$PERMISSOES" ]]; then
  echo "ERRO: ${PERMISSOES} já existe e não é link simbólico."
  echo "      Mescle as regras de ${KIT_DIR}/settings/permissions.yaml no seu"
  echo "      arquivo (os guardrails de segredos valem para todos os agentes)"
  echo "      ou mova o seu arquivo e rode de novo:"
  echo "      mv \"${PERMISSOES}\" \"${PERMISSOES}.bak\""
  conflitos=$((conflitos + 1))
fi
if (( conflitos > 0 )); then
  echo
  echo "Nenhuma alteração foi feita. Resolva os itens acima e rode o install.sh de novo."
  exit 1
fi

mkdir -p "$KIRO_DIR"

echo "Pastas:"
for pasta in "${PASTAS[@]}"; do
  link_item "${KIT_DIR}/${pasta}" "${KIRO_DIR}/${pasta}"
done

echo
echo "Permissões globais:"
mkdir -p "${KIRO_DIR}/settings"
link_item "${KIT_DIR}/settings/permissions.yaml" "$PERMISSOES"

echo
echo "Prompts:"
mkdir -p "${KIRO_DIR}/prompts"

# Remove links quebrados que apontavam para prompts deste kit (prompts
# renomeados ou apagados).
for link in "${KIRO_DIR}/prompts"/*.md; do
  [[ -L "$link" ]] || continue
  alvo="$(readlink "$link")"
  if [[ "$alvo" == "${KIT_DIR}/prompts/"* && ! -e "$link" ]]; then
    rm "$link"
    echo "removido  $link (prompt não existe mais no kit)"
  fi
done

shopt -s nullglob
for arquivo in "${KIT_DIR}"/prompts/reais/*.md; do
  link_item "$arquivo" "${KIRO_DIR}/prompts/$(basename "$arquivo")"
done
shopt -u nullglob

echo
if (( erros > 0 )); then
  echo "Instalação concluída com ${erros} item(ns) ignorado(s). Veja as mensagens de ERRO acima."
  exit 1
fi

echo "Instalação concluída."
engine="$(kiro-cli settings chat.agentEngine 2>/dev/null | tr -d '"' || true)"
if [[ "$engine" != "v3" ]]; then
  echo
  echo "ATENÇÃO: os agentes do kit exigem a engine v3 do Kiro (atual: ${engine:-não definida}). Rode:"
  echo "  kiro-cli settings chat.agentEngine v3"
fi
echo
echo "Recomendado: para que cada agente carregue apenas as skills declaradas no"
echo "próprio JSON, desligue a herança de recursos padrão no Kiro CLI:"
echo "  kiro-cli settings chat.disableInheritingDefaultResources true"
echo "Os agentes deste kit já declaram o steering global explicitamente, então"
echo "as regras de steering continuam valendo com essa opção ligada."
