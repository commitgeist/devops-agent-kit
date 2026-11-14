# Como o kit funciona

O kit usa só recursos nativos do Kiro CLI v3: steering, agentes
customizados, skills, hooks, permissões, sub-agentes, prompts salvos e MCP.
Este documento mostra onde cada um aparece e por quê. Para instalar e usar,
veja [guia-de-uso.md](guia-de-uso.md).

## Mapa: recurso do Kiro → kit

| Recurso do Kiro | No kit | Para quê | Doc oficial |
|-----------------|--------|----------|-------------|
| Steering | `steering/devops-base.md`, `steering/guardrails-segredos.md` (`inclusion: always`) | Regras que valem em toda conversa, inclusive no agente padrão do Kiro | [steering](https://kiro.dev/docs/steering/) |
| Agentes customizados | `agents/*.json` + `agents/instrucoes/*.md` | Papel, skills carregadas e **permissões** de cada perfil | [custom-agents](https://kiro.dev/docs/custom-agents/) |
| Skills | `skills/<nome>/SKILL.md` | O **procedimento** passo a passo de cada tarefa | [skills](https://kiro.dev/docs/skills/) |
| Permissões | `permissions.rules` em cada agente + `settings/permissions.yaml` | O que cada agente lê, escreve e executa; `deny` de segredos | [permissions](https://kiro.dev/docs/permissions/) |
| Hooks | `hooks/guardrail-segredos.json` + `hooks/bloquear-segredos.sh` | Bloqueio de segredos antes de qualquer ferramenta (`PreToolUse`) | [hooks](https://kiro.dev/docs/hooks/) |
| Sub-agentes | ferramentas `subagent/<agente>` no `devops` | Delegar aos especialistas, inclusive em paralelo | [subagents](https://kiro.dev/docs/custom-agents/subagents/) |
| Prompts salvos | `prompts/reais/*.md` (`/real-...`) | Pedidos prontos para as tarefas do dia a dia | [prompts](https://kiro.dev/docs/cli/chat/manage-prompts/) |
| MCP | `mcp/configurar-mcp.sh` + `includeMcpJson` nos agentes | Documentação oficial (AWS, Microsoft, Terraform) e consulta às plataformas de Git/CI | [mcp](https://kiro.dev/docs/mcp/) |
| Resources `file://` | `references/`, `templates/` | Padrões do time e modelos que os agentes consultam | [custom-agents](https://kiro.dev/docs/custom-agents/) |

## Skill × agente

- **Skill = procedimento.** Diz *como* fazer: o que ler, o que perguntar,
  o que gerar, onde gravar. Ex.: `analisar-repo`, `gerar-pipeline`.
- **Agente = permissões.** Diz *quem* faz e com que limites: quais skills
  carrega, onde pode escrever, que comandos roda. Ex.: o `reviewer` só roda
  `git` de leitura e só escreve em `docs/review/`.

Os limites são aplicados pelo Kiro (`permissions.rules`), não dependem do
modelo obedecer. Uma skill usada fora do seu agente não ganha as permissões
de escrita dele.

## Agentes e fluxo

Três agentes de **entrada** (você abre o chat com eles) e quatro
**especialistas** (normalmente chamados pelo `devops`):

```
                 você
       ┌──────────┼──────────────┐
       ▼          ▼              ▼
    devops     reviewer        secops
       │       (revisar)   (avaliar-seguranca)
       │ Etapa 0: confirma cloud, IaC, CI/CD e references
       ▼
    analyzer ──► docs/deploy/analise.md + contexto.md
       │
       ▼
  Etapa 2: você confirma destino e respostas  ◄── obrigatório
       │
       ├──► containerizer  (se o destino exige container)
       ├──► deployer       (IaC do destino)           em paralelo
       └──► pipeliner      (CI/CD da plataforma)
       │
       ▼
  fechamento: arquivos, segredos (só nomes), pendências, ADRs
```

| Agente | Tipo | Skill | Escreve em |
|--------|------|-------|------------|
| `devops` | entrada | `subir-app`, `registrar-adr` | `docs/adr/` |
| `reviewer` | entrada | `revisar` | `docs/review/` |
| `secops` | entrada | `avaliar-seguranca` | `docs/security/` |
| `analyzer` | especialista | `analisar-repo` | `docs/deploy/` |
| `containerizer` | especialista | `gerar-dockerfile` | `Dockerfile`, `.dockerignore`, `docs/deploy/` |
| `deployer` | especialista | `gerar-deploy` | `deploy/`, `docs/deploy/` |
| `pipeliner` | especialista | `gerar-pipeline` | arquivos de pipeline, `docs/deploy/` |

### Delegação

- Cada especialista vira uma ferramenta `subagent_<agente>` no `devops`,
  com os campos `explanation` e `prompt`.
- **Paralelo:** o `devops` chama várias dessas ferramentas na mesma
  resposta. Sem isso, roda uma de cada vez.
- **Subagente não pergunta ao usuário.** Toda pergunta é do `devops`, que
  repassa as respostas no `prompt` da delegação. Se faltar informação, o
  subagente devolve a pergunta.
- **Aprovação:** delegar a `analyzer`, `reviewer` e `secops` (só leitura e
  relatório) é liberado; a `containerizer`, `deployer` e `pipeliner` (geram
  artefatos) pede sua aprovação.
- **Permissões na delegação (Kiro v3):** cada ação do subagente precisa ser
  permitida pelo subagente **e** pelo agente pai
  ([doc](https://kiro.dev/docs/custom-agents/subagents/)). Por isso o
  `devops` tem regras mais largas que o próprio papel:
  - grava relatórios em `docs/deploy/`, `docs/security/` e `docs/review/`;
  - roda os comandos de leitura dos especialistas (scanners, `git diff/log`,
    `fmt`/`validate`, `hadolint`);
  - **pede aprovação** para gravar artefatos (`Dockerfile`, `deploy/`,
    pipelines).

  A instrução do `devops` proíbe que ele gere esses arquivos por conta
  própria. As permissões largas existem para os especialistas delegados.

### Destino pela boa prática

O `analyzer` não tem destino fixo. Ele classifica o **perfil de execução**
(site estático, API, worker, job, etc.) e recomenda o destino pela boa
prática: estático → S3 + CloudFront ou Storage Account + Front Door;
containers → ECS, AKS, EKS, Container Apps. O `deployer` só gera para os
destinos que tem (AKS, ECS, estático); para outros, entrega a recomendação
como passo humano e sugere ADR.

## References e templates

- `references/` é o **conhecimento do time**: ferramentas padrão
  (`padroes-do-time.md`), nomes, checklist de produção, GitOps, templates de
  pipeline, módulos de IaC, ferramentas de segurança.
- `references/README.md` é o **índice**. Todos os agentes o carregam e leem
  só as references que se aplicam.
- Antes de seguir uma reference, o agente **confirma com você**. No fluxo
  `subir-app` quem confirma é o `devops`, uma vez, e repassa a lista aos
  subagentes. Detalhes no próprio índice.
- `templates/` tem o modelo de ADR e o de contexto de entrega
  (`docs/deploy/contexto.md` na aplicação).

## Placeholder `<kiro>`

Skills e instruções citam `<kiro>/references/...`. A steering
`devops-base.md` define:

- modo projeto → `<kiro>` = `.kiro/` do repositório;
- modo global → `<kiro>` = `~/.kiro/`.

Assim o mesmo texto serve aos dois modos.

## Guardrails de segredos

Três camadas cobrem o mesmo conjunto de arquivos (`.env*` exceto exemplos,
chaves e certificados, `*.tfvars`, `*.tfstate`, credenciais de ferramentas,
`.git/config`) e de comandos (`env`, `printenv`, `gh auth token`,
`terraform output`, `gitleaks` sem `--redact` etc.):

| Camada | Arquivo | Garante | Não cobre |
|--------|---------|---------|-----------|
| Permissão | `settings/permissions.yaml` e regras embutidas nos agentes | `deny` aplicado pelo Kiro; `deny` vence qualquer `allow` | Regras de shell por **prefixo**: `git diff*` liberado pode aceitar um comando encadeado |
| Hook | `hooks/bloquear-segredos.sh` (`PreToolUse`) | Inspeciona caminho e comando de **qualquer** ferramenta, inclusive encadeamentos como `git diff && cat .env` | Precisa de `python3`; sem ele o hook libera tudo e sobram as outras camadas |
| Steering | `steering/guardrails-segredos.md` | Só **nomes** de variáveis, nunca repetir segredo colado, nunca contornar bloqueio | É instrução ao modelo, não bloqueio. No agente padrão do Kiro, é o único freio se o hook não estiver instalado |

Listar nomes de arquivo continua liberado: é assim que o agente descobre
que existe um `.env` versionado sem abri-lo.

Ao mudar uma camada, mude as três (regra do `AGENTS.md`).

## Modo projeto × modo global

| | Projeto (`install.sh --projeto <repo>`) | Global (`install.sh`) |
|-|------------------------------------------|----------------------|
| Onde fica | `<repo>/.kiro/` (cópia) | `~/.kiro/` (links para o kit) |
| Vale para | só aquele repositório | qualquer pasta que você abrir |
| Agentes | gerados com caminhos relativos e regras de segredo embutidas | os JSONs do kit, via link |
| Permissões globais | não usa `~/.kiro/settings` | `settings/permissions.yaml` linkado |
| Git | `.kiro/` vai para `.git/info/exclude` | nada no repositório |
| Atualizar | `git pull` no kit e `--projeto` de novo | `git pull` no kit |
| Quem ganha | agentes do projeto têm precedência sobre os globais de mesmo nome | |

No modo projeto o kit é **copiado**, não linkado: o Kiro leu pastas
linkadas como arquivo, e a cópia não quebra se o kit mudar de lugar. O que
o kit escreveu fica em `.kiro/.devops-agent-kit`; reinstalar só mexe
nesses arquivos.

## Recursos do Kiro que o kit não usa

| Recurso | Por que não |
|---------|-------------|
| [Powers](https://kiro.dev/docs/powers/) | Pacote de skills + MCP. Não carrega agentes, hooks nem permissões, que são o centro do kit |
| [Specs](https://kiro.dev/docs/specs/) | Fluxo de requisitos → design → tarefas para desenvolver software; o kit gera artefatos de entrega |
| [Workflows](https://kiro.dev/docs/workflows/) | Trabalho longo em segundo plano; a delegação por sub-agentes já cobre o paralelismo |
| [Checkpoints](https://kiro.dev/docs/checkpoints/) | Recurso de sessão; o kit não escreve fora de `docs/`, `deploy/` e arquivos de pipeline, e você revisa pelo `git diff` |
| [Kiroignore](https://kiro.dev/docs/kiroignore/) | Em avaliação como quarta camada de segredos |
