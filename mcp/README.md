# MCP no devops-agent-kit

Os agentes do kit carregam os servidores MCP configurados no Kiro
(`includeMcpJson: true`), sem nenhum servidor fixo no JSON dos agentes.
Assim cada pessoa liga só o que usa, e nenhum token fica no repositório.

## Para que servem

| Tipo | Exemplos | Quem usa | Para quê |
|------|----------|----------|----------|
| Documentação | `aws-docs`, `microsoft-learn`, `terraform` | `analyzer`, `deployer`, `pipeliner` | Conferir a boa prática atual antes de recomendar destino ou gerar IaC; versões de provider e módulos |
| Plataforma | `github`, `azure-devops`, `gitea` | `pipeliner` | Consultar templates de pipeline, environments, runners e convenções já existentes |

Permissões nos agentes:

- Servidores de **documentação**: liberados (`allow`).
- Servidores de **plataforma**: cada chamada pede confirmação (`ask`), e a
  steering `guardrails-segredos.md` proíbe escrita via MCP sem pedido
  explícito.

## Como configurar

O script só mostra os comandos, a não ser que você passe `--aplicar`:

```bash
# Ver o catálogo
./mcp/configurar-mcp.sh

# Simular
./mcp/configurar-mcp.sh aws-docs microsoft-learn

# Aplicar (versões fixas, nada de latest)
TERRAFORM_MCP_VERSION=<versao> ./mcp/configurar-mcp.sh --aplicar aws-docs terraform

# Plataforma: token só no ambiente do shell, nunca em arquivo
export GITHUB_PERSONAL_ACCESS_TOKEN=<token-somente-leitura>
GITHUB_MCP_VERSION=<versao> ./mcp/configurar-mcp.sh --aplicar github
```

Depois confira com `kiro-cli mcp list` e, dentro do chat, com `/mcp`.

Também é possível adicionar à mão com `kiro-cli mcp add`. Se preferir
servidores só para um repositório, use `--scope workspace`.

## Regras

- Tokens: só variável de ambiente do shell ou login interativo. Nunca em
  `mcp.json`, no kit ou no repositório da aplicação.
- Token de plataforma com escopo de **leitura** e restrito aos
  repositórios/projetos necessários.
- Versão fixa para servidores empacotados (imagem ou pacote npm).
- Antes de aplicar, confira o README oficial de cada servidor. Nomes de
  imagem, flags e variáveis mudam entre versões.
- Servidor novo no catálogo: abra PR no kit adicionando o caso em
  `configurar-mcp.sh`, esta tabela e a regra de permissão (`allow` ou
  `ask`) nos JSONs dos agentes.
