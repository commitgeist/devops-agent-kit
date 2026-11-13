---
name: avaliar-seguranca
description: Avalia a postura de segurança do repositório da aplicação (segredos versionados, dependências, código, IaC, container e esteira de CI/CD) e propõe os controles de segurança para o pipeline da plataforma do contexto de entrega. Roda scanners locais só quando disponíveis e sempre com saída mascarada. Só lê; grava relatório em docs/security/.
---

# Skill: avaliar-seguranca

Escopo pedido pelo usuário (vazio = completo):
$ARGUMENTS

## Fontes

1. `docs/deploy/analise.md` e `docs/deploy/contexto.md`, se existirem
   (stack, destino, plataforma de CI/CD). Sem eles, levante o mínimo pela
   listagem do repositório e registre que a análise de deploy não existe.
2. `<kiro>/references/seguranca/ferramentas.md` (controles por camada) e as
   references confirmadas no contexto.
3. `checklist-producao.md` e a steering.

## O que avaliar

| Camada | Como avaliar sem ferramenta | Scanner local (se instalado) |
|--------|-----------------------------|------------------------------|
| Segredos | Listagem de nomes: `.env` versionado, chaves, `*.tfvars`, `*.tfstate`; `.gitignore` cobrindo esses arquivos | `gitleaks dir --redact` ou `gitleaks git --redact` |
| Dependências | Lockfile presente, versões fixadas, dependências abandonadas evidentes | `trivy fs --scanners vuln .` |
| Código | Padrões de risco evidentes (SQL concatenado, `eval`, desserialização insegura, CORS `*`, TLS desabilitado) | `semgrep scan --config auto` |
| IaC | Recurso público, sem criptografia, IAM com `*`, sem logs | `checkov -d <pasta>` ou `trivy config <pasta>` |
| Container | Base sem versão, root, segredo em `ARG`/`ENV`, `latest` | `hadolint Dockerfile`, `trivy config Dockerfile` |
| Esteira | OIDC ou chave estática, actions sem SHA, permissões do token, aprovação de produção, deploy em PR de fork | — |

Regras:

- **Nunca leia arquivos de segredo** e nunca coloque valor de segredo no
  relatório. Scanner de segredo só com `--redact`; registre `arquivo:linha`
  e o tipo de segredo.
- Scanner ausente não é erro: avalie pela leitura e recomende a ferramenta.
- Não instale ferramentas, não atualize dependências, não corrija código.
- Achado precisa de evidência (`arquivo:linha` ou saída do scanner).
  Suspeita sem evidência vai em "Verificar".

## Severidade

Crítica (segredo exposto, recurso público indevido, IAM `*`, execução
remota), Alta (CVE crítica/alta com correção, root no container, chave
estática no CI), Média, Baixa.

## Proposta para a esteira

Com base na plataforma do contexto e em `seguranca/ferramentas.md`, proponha
os estágios de segurança na ordem do "mínimo recomendado": ferramenta, em
que gatilho roda (PR, branch principal, agendado), política de falha e o
que precisa existir na plataforma (licença, extensão, conexão com Defender
for Cloud etc.). Para Azure DevOps, indique quando a opção nativa (GitHub
Advanced Security for Azure DevOps, Microsoft Security DevOps, Defender for
Cloud) cobre a camada e quando uma ferramenta aberta resolve sem licença.

A proposta é **texto**: quem implementa o YAML é o `pipeliner`, a partir do
relatório.

## Relatório

Grave `docs/security/<AAAA-MM-DD>-avaliacao.md`:

```markdown
# Avaliação de segurança: <aplicacao>

> Gerada pela skill avaliar-seguranca em <data>. Scanners usados: <lista ou "nenhum">.

## Resumo
<veredito em 2 a 3 linhas e contagem por severidade>

## Achados
| # | Severidade | Camada | Arquivo:linha | Problema | Correção proposta |
|---|------------|--------|---------------|----------|-------------------|

## Controles da esteira
| Camada | Situação atual | Proposta | Gatilho | Política de falha | Pré-requisito na plataforma |
|--------|----------------|----------|---------|-------------------|-----------------------------|

## Verificar
- <suspeita sem evidência e como confirmar>
```

## Ao terminar

Mostre no chat: veredito, contagem por severidade, achados críticos e altos,
os 3 primeiros controles a implantar na esteira e o caminho do relatório.
