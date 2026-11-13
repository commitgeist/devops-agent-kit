# DevOps Agent Kit

Kit de agentes, skills e regras para o **Kiro CLI** preparar a entrega de
aplicações recebidas de outros times: análise do repositório, destino
recomendado pela boa prática (container, Kubernetes, hospedagem estática),
Dockerfile, IaC, pipeline de CI/CD, revisão contra ADRs e avaliação de
segurança.

O kit **gera e revisa**. Nunca aplica, publica, commita nem lê arquivos de
segredo.

## Pré-requisitos

- Kiro CLI 3.x com engine v3 (`kiro-cli --version`).
- `python3` (usado pelo hook de segredos) e `git`.
- Opcional, para validações locais: `hadolint`, `docker`, `terraform`/`tofu`,
  `bicep`, e scanners (`gitleaks`, `trivy`, `semgrep`, `checkov`).
- Opcional, para MCP: `docker` e/ou `npx`.

## Instalação (5 minutos)

```bash
git clone <repo-url> <caminho-local>
cd <caminho-local>
./install.sh
kiro-cli settings chat.disableInheritingDefaultResources true   # cada agente carrega só o que declara
kiro-cli agent set-default devops                               # opcional: sem precisar de --agent
```

O `install.sh` cria links em `~/.kiro/` para `steering`, `agents`, `skills`,
`references`, `templates`, `hooks`, para cada prompt e para
`settings/permissions.yaml`. Ele **não sobrescreve nada**: se algum destino
já existir e não for link (comum em `~/.kiro/agents`, `~/.kiro/skills` ou
`~/.kiro/settings/permissions.yaml` de quem já usa o Kiro), ele para sem
alterar nada e mostra o comando para mover o item. Depois de linkado, tudo
que você criar em `~/.kiro/agents` ou `~/.kiro/skills` fica dentro do kit.

**Verifique:**

```bash
kiro-cli agent list          # devops, reviewer, secops, analyzer, containerizer, deployer, pipeliner
```

Num diretório de teste com um `.env` falso, peça a qualquer agente para ler
o `.env`: a leitura tem que ser bloqueada.

**Atualizar:** `git pull` e `./install.sh` (o script reaponta links e remove
prompts que saíram do kit). **Remover:** `./uninstall.sh`.

## Configuração do time (uma vez)

Edite `references/padroes-do-time.md` com o padrão da empresa. Exemplo:

```markdown
| Cloud principal | Azure |
| Ferramenta de IaC | Terraform |
| Versão da ferramenta de IaC | 1.9.x |
| Plataforma de CI/CD | Azure DevOps Pipelines |
| Autenticação do CI na cloud | Workload identity federation |
| Registry de imagens | <acr-name>.azurecr.io |
| Cofre de segredos | Azure Key Vault |
| Scanner de imagem e IaC | Microsoft Security DevOps |
```

O que ficar `<a-definir>` o agente pergunta. Complete também
`nomenclatura.md` e, se houver, coloque templates de pipeline em
`references/pipeline/` e módulos de IaC em `references/iac/` (atualizando o
índice `references/README.md`).

MCP é opcional: `./mcp/configurar-mcp.sh` mostra o catálogo (docs da AWS,
Microsoft Learn, Terraform; GitHub, Azure DevOps, Gitea só leitura). Veja
`mcp/README.md`.

## Uso

Na raiz do repositório da aplicação:

```bash
kiro-cli chat --agent devops
```

```
@real-fluxo-completo O time disse que a app usa Postgres e não mandou .env.example.
```

O `devops`:

1. Confirma numa única pergunta o que bloqueia a geração (cloud, IaC, CI/CD)
   e as references do time que vai seguir. Grava em
   `docs/deploy/contexto.md` da aplicação; na próxima vez não pergunta.
2. Delega a análise ao `analyzer` (`docs/deploy/analise.md`), com perfil de
   execução e destino recomendado.
3. Mostra o resultado e **espera sua confirmação**.
4. Delega em paralelo só o que se aplica: `containerizer` (se houver
   container), `deployer` (IaC) e `pipeliner` (CI/CD).
5. Consolida arquivos, segredos esperados (só nomes), pendências e
   decisões que merecem ADR.

Revisão e segurança:

```bash
kiro-cli chat --agent reviewer    # @real-revisar-adr | @real-revisar-branch main
kiro-cli chat --agent secops      # @real-secops-avaliar
```

Lista de prompts: `prompts/README.md`.

## Agentes

| Agente | Tipo | Skill | Escreve em | Shell |
|--------|------|-------|------------|-------|
| `devops` | entrada | `subir-app`, `registrar-adr` | `docs/adr/` | não |
| `reviewer` | entrada | `revisar` (ADR × implementação, análise × código, container, IaC, pipeline, branch) | `docs/review/` | `git` de leitura |
| `secops` | entrada | `avaliar-seguranca` (segredos, dependências, código, IaC, container, esteira) | `docs/security/` | scanners de leitura, `gitleaks` só com `--redact` |
| `analyzer` | especialista | `analisar-repo` | `docs/deploy/` | não |
| `containerizer` | especialista | `gerar-dockerfile` | `Dockerfile`, `.dockerignore`, `docs/deploy/` | `hadolint`, `docker build` |
| `deployer` | especialista | `gerar-deploy` (Terraform, OpenTofu, Bicep, Pulumi, CDK, CloudFormation; AKS, ECS, estático) | `deploy/`, `docs/deploy/` | `fmt`/`validate` da IaC |
| `pipeliner` | especialista | `gerar-pipeline` (GitHub Actions, Azure DevOps, Gitea, Bitbucket, GitLab, Jenkins) | arquivos de pipeline, `docs/deploy/` | não |

- **Skill** é o procedimento; **agente** é o perfil de permissões que o
  executa. Os limites de escrita e shell são aplicados pelo Kiro
  (`permissions.rules`), não dependem do modelo.
- Especialistas são chamados pelo `devops`, mas funcionam direto com
  `kiro-cli chat --agent <nome>`. Uma skill chamada fora do seu agente não
  tem permissão de escrita nos caminhos dela.
- O `devops` delega a `analyzer`, `reviewer` e `secops` sem pedir aprovação
  (só leitura/relatório) e a `containerizer`, `deployer` e `pipeliner` com
  aprovação.

## Guardrails de segredos

Três camadas globais, válidas para **qualquer** agente do Kiro, inclusive o
padrão:

| Camada | Arquivo | O que faz |
|--------|---------|-----------|
| Permissão | `settings/permissions.yaml` → `~/.kiro/settings/permissions.yaml` | `deny` de leitura em `.env*` (exceto exemplos), chaves, certificados, `*.tfvars`, `*.tfstate`, credenciais de ferramentas, `.git/config`; `deny` de comandos que imprimem ambiente ou credenciais |
| Hook | `hooks/guardrail-segredos.json` + `bloquear-segredos.sh` (`PreToolUse`) | Bloqueia os mesmos caminhos em qualquer ferramenta e comandos como `printenv`, `cat .env`, `gh auth token`, `gitleaks` sem `--redact` |
| Steering | `steering/guardrails-segredos.md` | Levantar só **nomes** de variáveis, nunca repetir segredo colado, nunca contornar bloqueio |

Para descobrir se existe um `.env` versionado, os agentes usam só a
listagem de nomes, que é liberada.

## Onde fica cada coisa

| No kit | No repositório da aplicação |
|--------|-----------------------------|
| `agents/` perfis e instruções | `docs/deploy/contexto.md` ferramentas e references confirmadas |
| `skills/` procedimentos | `docs/deploy/analise.md` análise de deploy |
| `steering/` regras sempre ativas | `Dockerfile`, `deploy/` (IaC, manifests), pipeline |
| `references/` padrões do time (índice em `README.md`) | `docs/adr/` decisões |
| `hooks/`, `settings/` guardrails globais | `docs/review/`, `docs/security/` relatórios |
| `mcp/` catálogo e script de MCP | |
| `prompts/reais/` prompts `@real-*` | |
| `templates/` ADR e contexto de entrega | |

Manutenção do kit: `AGENTS.md`.
