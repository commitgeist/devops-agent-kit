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
git clone git@github.com:commitgeist/devops-agent-kit.git ~/devops-agent-kit   # fora das aplicações
kiro-cli settings chat.agentEngine v3                           # obrigatório: agentes no formato v3
kiro-cli settings chat.disableInheritingDefaultResources true   # cada agente carrega só o que declara
```

Escolha o escopo:

| Modo | Comando | Onde fica | Quando usar |
|------|---------|-----------|-------------|
| **Projeto** (recomendado) | `bash ~/devops-agent-kit/install.sh --projeto <repo>` | `<repo>/.kiro/` (cópia), fora do git | O kit só naquele repositório. Depois de instalar, o clone pode ser apagado |
| **Global** | `bash ~/devops-agent-kit/install.sh` | `~/.kiro/` (links para o clone) | O kit em qualquer repositório. **Não apague o clone** sem rodar `uninstall.sh` antes |

### Modo projeto

- **Cópia, não link:** o kit é copiado para `<repo>/.kiro/`. Os agentes são
  gerados com caminhos relativos e com as regras de segredo embutidas
  (o `permissions.yaml` de workspace não fica no repositório), e o hook vai
  para `.kiro/hooks/`.
- **Fora do git sem mexer no `.gitignore` do time:** `.kiro/` entra em
  `.git/info/exclude`, que é um ignore local. Se preferir, coloque `.kiro/`
  no `.gitignore`.
- **Atualizar:** `git pull` no kit e rode o `--projeto` de novo. Os
  arquivos do kit são atualizados e os que saíram do kit são removidos.
  Arquivos seus em `.kiro/` não são tocados (o que o kit escreveu fica
  listado em `.kiro/.devops-agent-kit`).
- **Não edite as cópias:** elas são sobrescritas na próxima atualização.
  Personalize em `references/` no kit.
- **Remover:** `bash ~/devops-agent-kit/uninstall.sh --projeto <repo>`.
- Os agentes do projeto têm precedência sobre os globais de mesmo nome.

### Modo global

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

Se um agente responder `Mode '<agente>' not found`, a engine v3 não está
ativa: `kiro-cli settings chat.agentEngine v3`. Os dois instaladores avisam.

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
/real-fluxo-completo O time disse que a app usa Postgres e não mandou .env.example.
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
kiro-cli chat --agent reviewer    # /real-revisar-adr | /real-revisar-branch main
kiro-cli chat --agent secops      # /real-secops-avaliar
```

Lista de prompts: `prompts/README.md`.

## Agentes

| Agente | Tipo | Para quê |
|--------|------|----------|
| `devops` | entrada | Orquestra o deploy, delega aos especialistas, registra ADR |
| `reviewer` | entrada | Revisa ADR × implementação, análise × código, IaC, pipeline, branch |
| `secops` | entrada | Avalia segurança e propõe estágios de segurança na pipeline |
| `analyzer`, `containerizer`, `deployer`, `pipeliner` | especialistas | Análise, Dockerfile, IaC e CI/CD, chamados pelo `devops` |

Permissões, delegação e guardrails de segredos (permissão, hook e
steering): [docs/como-funciona.md](docs/como-funciona.md).

## Documentação

| Documento | Conteúdo |
|-----------|----------|
| [docs/guia-de-uso.md](docs/guia-de-uso.md) | Passo a passo: instalar, abrir agentes, prompts, teste de delegação em paralelo, personalizar, problemas comuns |
| [docs/como-funciona.md](docs/como-funciona.md) | Como o kit usa cada recurso do Kiro, fluxo dos agentes, guardrails, modos projeto e global |
| [mcp/README.md](mcp/README.md) | Catálogo e configuração de MCP |
| [prompts/README.md](prompts/README.md) | Prompts prontos |
| [references/README.md](references/README.md) | Índice das references do time |
| [evals/README.md](evals/README.md) | Testes automáticos dos agentes e prompts (`./testar.sh`) |

## Onde fica cada coisa

| No kit | No repositório da aplicação |
|--------|-----------------------------|
| `agents/` perfis e instruções | `docs/deploy/contexto.md` ferramentas e references confirmadas |
| `skills/` procedimentos | `docs/deploy/analise.md` análise de deploy |
| `steering/` regras sempre ativas | `Dockerfile`, `deploy/` (IaC, manifests), pipeline |
| `references/` padrões do time (índice em `README.md`) | `docs/adr/` decisões |
| `hooks/`, `settings/` guardrails globais | `docs/review/`, `docs/security/` relatórios |
| `lib/projeto.py` instalação no modo projeto | `.kiro/` (modo projeto, fora do git) |
| `mcp/` catálogo e script de MCP | |
| `prompts/reais/` prompts `/real-*` | |
| `docs/` documentação do kit | |
| `evals/` testes dos agentes | |
| `templates/` ADR e contexto de entrega | |

Manutenção do kit: `AGENTS.md`.
