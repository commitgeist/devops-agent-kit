---
name: revisar
description: Revisa artefatos de entrega contra o que foi decidido e contra os padrões do time. ADR contra implementação, análise contra código atual, Dockerfile, IaC, manifests e pipeline contra steering, references e checklist de produção, ou o diff de uma branch. Só lê e gera um relatório em docs/review/; nunca corrige.
---

# Skill: revisar

Você vai revisar o repositório do workspace e gerar um relatório. Você
**não corrige nada**: aponta, com evidência, e propõe.

Pedido do usuário (escopo da revisão, pode estar vazio):
$ARGUMENTS

## Escopo

Identifique o escopo pelo pedido. Se estiver vazio, pergunte qual destes:

| Escopo | Fonte da verdade | O que é revisado |
|--------|------------------|------------------|
| `adr` | ADRs em `docs/adr/` (todas ou a citada) | Código, IaC, manifests e pipeline que implementam a decisão |
| `analise` | `docs/deploy/analise.md` e `docs/deploy/contexto.md` | Código atual: variáveis, porta, healthcheck, dependências e destino ainda batem? |
| `container` | `gerar-dockerfile`, `checklist-producao.md` | `Dockerfile`, `.dockerignore` |
| `iac` | `gerar-deploy`, `nomenclatura.md`, references de IaC | `deploy/**`, IaC fora de `deploy/` |
| `pipeline` | `gerar-pipeline`, references de pipeline | Arquivos de pipeline da plataforma |
| `branch` | Tudo acima que se aplicar | Só o que mudou: `git diff <base>...HEAD` |
| `completo` | Tudo acima | Tudo acima |

## Como revisar

1. Leia a fonte da verdade do escopo e o índice
   `~/.kiro/references/README.md`; leia as references que se aplicam.
2. Para ADR: extraia de cada ADR a **decisão**, as **consequências** e as
   **restrições** em itens verificáveis. Para cada item, procure a
   implementação e classifique: **cumprido**, **divergente**, **não
   implementado** ou **não verificável** (diga o que faltaria para
   verificar). ADR com status "substituída" ou "rejeitada" não é cobrada,
   mas aponte se o código ainda segue a decisão antiga.
3. Para artefatos: confira item a item as regras da skill geradora, a
   steering (`devops-base.md`, `guardrails-segredos.md`) e o checklist.
4. Procure também o que **não tem decisão**: escolhas relevantes no código
   ou na IaC sem ADR (ferramenta, destino, exceção de segurança).
5. Toda constatação precisa de evidência (`arquivo:linha`). Sem evidência,
   não é constatação.
6. Não leia arquivos de segredo. Se a revisão depender de um, registre como
   "não verificável".

## Severidade

- **Crítica:** segredo exposto, permissão `*`, recurso público indevido,
  deploy sem aprovação, divergência de ADR com impacto em segurança.
- **Alta:** divergência de ADR, `latest`, sem rollback, sem healthcheck.
- **Média:** padrão do time não seguido, nomenclatura, tags ausentes.
- **Baixa:** legibilidade, documentação.

## Relatório

Grave `docs/review/<AAAA-MM-DD>-<escopo>.md`:

```markdown
# Revisão: <escopo>

> Gerada pela skill revisar em <data>. Base: <branch ou commit, se houver>.

## Resumo
<veredito em 2 a 3 linhas e contagem por severidade>

## Conformidade com ADRs
| ADR | Item da decisão | Situação | Evidência | Observação |
|-----|-----------------|----------|-----------|------------|

## Achados
| # | Severidade | Arquivo:linha | Regra ou fonte | Problema | Proposta |
|---|------------|---------------|----------------|----------|----------|

## Decisões sem ADR
- <decisão> (evidência: <arquivo:linha>)

## Não verificável
- <item> — <o que faltaria>
```

Omita seções que não se aplicam ao escopo.

## Ao terminar

Mostre no chat: escopo, veredito, contagem por severidade, os achados
críticos e altos e o caminho do relatório. Não ofereça aplicar correções:
isso é papel do agente que gera o artefato.
