#!/usr/bin/env bash
# Configura servidores MCP para os agentes do devops-agent-kit, usando
# `kiro-cli mcp add` no escopo global (~/.kiro/settings/mcp.json).
#
# Por padrão só MOSTRA os comandos (simulação). Use --aplicar para executar.
#
#   ./mcp/configurar-mcp.sh                         # lista o catálogo
#   ./mcp/configurar-mcp.sh aws-docs terraform      # simula
#   ./mcp/configurar-mcp.sh --aplicar github        # executa
#
# Regras do kit:
# - Nenhum token é gravado em arquivo. Servidores que precisam de token o
#   recebem da variável de ambiente do seu shell no momento em que o Kiro
#   inicia (docker -e <VAR> sem valor herda do ambiente) ou por login
#   interativo da própria ferramenta.
# - Nada de `latest`: servidores empacotados exigem a versão em variável
#   de ambiente (ex.: TERRAFORM_MCP_VERSION=0.x.y).
# - Servidores de plataforma são configurados em modo somente leitura
#   quando o servidor oferece essa opção.
#
# Confira sempre o README oficial de cada servidor antes de aplicar:
# nomes de imagem, flags e variáveis mudam entre versões.

set -euo pipefail

APLICAR=0
SERVIDORES=()
for arg in "$@"; do
  case "$arg" in
    --aplicar) APLICAR=1 ;;
    -h|--help) SERVIDORES=(); break ;;
    *) SERVIDORES+=("$arg") ;;
  esac
done

catalogo() {
  cat <<'EOF'
Catálogo (uso | autenticação):

  Documentação, para buscar boa prática (somente leitura, sem token):
    aws-docs         AWS Knowledge MCP (remoto)            | nenhuma
    microsoft-learn  Microsoft Learn MCP (remoto)          | nenhuma
    terraform        HashiCorp Terraform MCP (docker)      | nenhuma; exige TERRAFORM_MCP_VERSION

  Plataformas de Git e CI/CD (consulta):
    github           GitHub MCP (docker, --read-only)      | GITHUB_PERSONAL_ACCESS_TOKEN no shell; exige GITHUB_MCP_VERSION
    azure-devops     Azure DevOps MCP (npx)                | login interativo no navegador; exige AZDO_ORG e AZDO_MCP_VERSION
    gitea            Gitea MCP (docker)                    | GITEA_ACCESS_TOKEN no shell; exige GITEA_HOST e GITEA_MCP_VERSION

  Bitbucket: não há servidor oficial mantido pela Atlassian para Bitbucket
  Cloud/Data Center no catálogo do kit. Escolha um servidor, revise o
  código e registre a decisão em ADR antes de adicionar com
  `kiro-cli mcp add`.
EOF
}

exigir() {
  local var="$1"
  if [[ -z "${!var:-}" ]]; then
    echo "ERRO: defina ${var} antes (ex.: export ${var}=<valor>)." >&2
    return 1
  fi
}

rodar() {
  printf '  %q' "$@"; echo
  if (( APLICAR )); then "$@"; fi
}

adicionar() {
  case "$1" in
    aws-docs)
      rodar kiro-cli mcp add --scope global --force --name aws-docs \
        --url "https://knowledge-mcp.global.api.aws"
      ;;
    microsoft-learn)
      rodar kiro-cli mcp add --scope global --force --name microsoft-learn \
        --url "https://learn.microsoft.com/api/mcp"
      ;;
    terraform)
      exigir TERRAFORM_MCP_VERSION || return 1
      rodar kiro-cli mcp add --scope global --force --name terraform \
        --command docker \
        --args '["run","-i","--rm","hashicorp/terraform-mcp-server:'"${TERRAFORM_MCP_VERSION}"'"]'
      ;;
    github)
      exigir GITHUB_MCP_VERSION || return 1
      rodar kiro-cli mcp add --scope global --force --name github \
        --command docker \
        --args '["run","-i","--rm","-e","GITHUB_PERSONAL_ACCESS_TOKEN","ghcr.io/github/github-mcp-server:'"${GITHUB_MCP_VERSION}"'","stdio","--read-only"]'
      echo "  # O token vem de GITHUB_PERSONAL_ACCESS_TOKEN no shell que abre o Kiro."
      echo "  # Use token fine-grained, somente leitura, só nos repositórios necessários."
      ;;
    azure-devops)
      exigir AZDO_ORG || return 1
      exigir AZDO_MCP_VERSION || return 1
      rodar kiro-cli mcp add --scope global --force --name azure-devops \
        --command npx \
        --args '["-y","@azure-devops/mcp@'"${AZDO_MCP_VERSION}"'","'"${AZDO_ORG}"'"]'
      echo "  # Na primeira chamada o servidor abre o login no navegador."
      ;;
    gitea)
      exigir GITEA_HOST || return 1
      exigir GITEA_MCP_VERSION || return 1
      rodar kiro-cli mcp add --scope global --force --name gitea \
        --command docker \
        --args '["run","-i","--rm","-e","GITEA_HOST='"${GITEA_HOST}"'","-e","GITEA_ACCESS_TOKEN","docker.gitea.com/gitea-mcp-server:'"${GITEA_MCP_VERSION}"'"]'
      echo "  # O token vem de GITEA_ACCESS_TOKEN no shell. Use token com escopo de leitura."
      ;;
    *)
      echo "Servidor desconhecido: $1" >&2
      return 1
      ;;
  esac
}

if (( ${#SERVIDORES[@]} == 0 )); then
  catalogo
  echo
  echo "Uso: $0 [--aplicar] <servidor> [<servidor>...]"
  exit 0
fi

(( APLICAR )) || echo "Simulação (nada será alterado). Use --aplicar para executar:"
falhas=0
for s in "${SERVIDORES[@]}"; do
  echo
  echo "[$s]"
  adicionar "$s" || falhas=$((falhas + 1))
done

echo
if (( APLICAR )); then
  echo "Confira com: kiro-cli mcp list"
fi
exit $(( falhas > 0 ))
