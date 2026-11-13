# DevOps Agent Kit

Kit reutilizável de agentes, skills e regras de DevOps para o **Kiro CLI**.
É instalado de forma global (links em `~/.kiro/`) e usado dentro de
repositórios de aplicações entregues por outros times, para preparar o
deploy em **AKS** (via GitOps) ou **ECS** (via Terraform).

O kit contém apenas padrões genéricos, com placeholders no formato
`<placeholder>`. Nada específico de aplicação, cliente, servidor ou pessoa.
Tudo que é particular de uma aplicação é gerado dentro do repositório dessa
aplicação, nunca aqui.

## Uso rápido

Na raiz do repositório da aplicação, com o kit já instalado:

```bash
kiro-cli chat --agent subir-app
```

```
@real-fluxo-completo Destino AKS. O dev disse que a app usa Redis e Postgres. Não mandaram .env.example.
```

O `subir-app` roda a análise, mostra o resultado e as perguntas abertas e
espera sua confirmação. Depois gera Dockerfile e artefatos de deploy em
paralelo. Nada é aplicado e nada é commitado.

## O que é cada pasta

| Pasta | O que é | Quando entra em ação | Instalada em |
|-------|---------|----------------------|--------------|
| `steering/` | **Regras de comportamento** que valem sempre: proibições, segurança, GitOps, tags imutáveis, segredos no cofre | Em toda conversa (`inclusion: always`) e declarada em todos os agentes | `~/.kiro/steering` |
| `skills/` | **Procedimentos** passo a passo de uma tarefa (`SKILL.md`), mais um `README.md` para humanos | Sob demanda: o Kiro carrega só nome e descrição e lê o conteúdo quando a tarefa pede, ou quando você chama `/<skill>` | `~/.kiro/skills` |
| `agents/` | **Agentes**: um JSON por agente (ferramentas, permissões, skills e references que carrega) e as instruções em `agents/instrucoes/` | Quando você inicia `kiro-cli chat --agent <nome>` ou quando o orquestrador delega | `~/.kiro/agents` |
| `references/` | **Conhecimento do time**: fluxo GitOps, padrão de nomes, checklist de produção. Dados, não procedimentos | Carregados só pelos agentes que declaram o arquivo em `resources` | `~/.kiro/references` |
| `prompts/` | **Prompts salvos** prontos para invocar com `@<nome>`: `exemplos/` (didáticos) e `reais/` (dia a dia) | Quando você digita `@<nome>` no início da mensagem | um link por arquivo em `~/.kiro/prompts/` |
| `templates/` | **Modelos de documento** (ADR) | Quando um agente ou você precisa criar o documento | `~/.kiro/templates` |
| `docs/agents/` | **Documentação humana** de cada agente: papel, skills, permissões, exemplos | Leitura humana, não é carregada pelo Kiro | não é instalada |

Resumo da diferença:

- **Steering** diz o que nunca fazer e como se comportar.
- **Skill** diz como executar uma tarefa.
- **Agent** junta ferramentas, permissões, skills e references para um papel.
- **Reference** guarda os dados e convenções do time que a skill consulta.
- **Prompt** é o pedido pronto que você digita para disparar o trabalho.

## Fluxo de subir uma app

```
                    ┌──────────────┐
  você ───────────► │  subir-app   │  orquestrador (não escreve arquivos)
                    └──────┬───────┘
                           │ 1. delega
                           ▼
                    ┌──────────────┐
                    │   analyzer   │  skill analisar-repo
                    └──────┬───────┘  gera docs/deploy/analise.md
                           │
                           ▼
              2. subir-app mostra a análise
                 e ESPERA SUA CONFIRMAÇÃO
                           │
              3. delega em paralelo
                ┌──────────┴──────────┐
                ▼                     ▼
        ┌───────────────┐     ┌──────────────┐
        │ containerizer │     │   deployer   │
        └───────────────┘     └──────────────┘
        skill                 skill gerar-deploy
        gerar-dockerfile      AKS: deploy/aks/*.yaml
        Dockerfile e          ECS: deploy/ecs/*.tf
        .dockerignore
                │                     │
                └──────────┬──────────┘
                           ▼
              4. subir-app consolida: arquivos, segredos
                 esperados no cofre, placeholders e checklist
```

| Ordem | Agente | Skill | Escreve em | Documentação |
|-------|--------|-------|------------|--------------|
| 1 | `subir-app` | nenhuma (delega) | nada | `docs/agents/subir-app.md` |
| 2 | `analyzer` | `analisar-repo` | `docs/deploy/` | `docs/agents/analyzer.md` |
| 3 | `containerizer` | `gerar-dockerfile` | `Dockerfile`, `.dockerignore`, `docs/deploy/` | `docs/agents/containerizer.md` |
| 3 | `deployer` | `gerar-deploy` | `deploy/`, `docs/deploy/` | `docs/agents/deployer.md` |

Cada agente também pode ser usado sozinho, por exemplo
`kiro-cli chat --agent analyzer`. A delegação usa a ferramenta `subagent`
do Kiro CLI; os agentes delegados não podem delegar para outros.

## Entendendo o Kiro (para quem vem do Claude)

Antes de tudo, o Kiro e o Claude não são rivais: o Kiro é um ambiente de
desenvolvimento agêntico (IDE baseada em Code OSS, mais uma CLI) que usa
**modelos Claude** como motor de raciocínio. Ou seja, a inteligência que
você já conhece do Claude está lá dentro. O que muda é a **forma como o
trabalho é organizado** em volta do modelo. A comparação justa é com o
Claude Code, e não com o modelo em si.

A ideia central do Kiro é trocar o *prompt solto* por **estrutura
versionada**: as regras, as especificações e as automações ficam em
arquivos dentro de `.kiro/` (no projeto) ou de `~/.kiro/` (global). Assim o
contexto fica explícito, revisável em PR e reaproveitável, que é justamente
o que este kit aproveita.

### Spec-driven development: o diferencial do Kiro

No Claude Code, o caminho natural é conversar e, quando a tarefa é maior,
usar o *plan mode* para alinhar um plano antes de editar. Esse plano, porém,
vive na conversa.

O Kiro transforma essa etapa em **artefato de primeira classe**. Uma *spec*
fica em `.kiro/specs/<feature>/` e é dividida em três arquivos:

| Arquivo | O que contém |
|---------|--------------|
| `requirements.md` | Histórias de usuário com critérios de aceite em notação **EARS** (*"QUANDO … O SISTEMA DEVE …"*), testáveis e sem ambiguidade |
| `design.md` | Arquitetura, componentes, fluxo de dados, tratamento de erros e estratégia de testes |
| `tasks.md` | Plano de implementação em tarefas discretas e rastreáveis até os requisitos, executáveis uma a uma |

Na prática, para DevOps, isso significa que uma mudança de infraestrutura
pode passar por *requisito → desenho → tarefas* com cada etapa revisada
por humanos antes de qualquer linha de Terraform ou manifest ser escrita.
Para tarefas rápidas, o Kiro também tem o modo **Vibe**, equivalente ao
fluxo conversacional do Claude Code.

### Steering: o "CLAUDE.md" do Kiro, com mais granularidade

O papel do `CLAUDE.md` / `AGENTS.md` no Claude Code é cumprido no Kiro pelos
arquivos de **steering** (`.kiro/steering/*.md` no projeto e
`~/.kiro/steering/` no usuário). A diferença é que cada arquivo declara
**quando** deve entrar no contexto, via front matter:

| `inclusion` | Comportamento |
|-------------|---------------|
| `always` | Sempre carregado (é o caso de `steering/devops-base.md` deste kit) |
| `fileMatch` | Carregado só quando o trabalho envolve arquivos que casam com `fileMatchPattern` (ex.: `**/*.tf`, `**/k8s/**/*.yaml`) |
| `manual` | Carregado sob demanda, referenciando o arquivo no chat com `#<nome>` |

Isso permite separar as regras por domínio (Terraform, Kubernetes,
pipelines) sem inflar o contexto de toda conversa, de forma parecida com o
carregamento sob demanda que as *skills* fazem no Claude Code.

### Agent hooks: automação disparada por eventos do IDE

O Claude Code tem hooks ligados ao **ciclo de vida da ferramenta**
(antes/depois de usar uma tool, ao enviar prompt, ao parar etc.),
configurados em `settings.json` e geralmente executando scripts.

Os hooks do Kiro olham para o **workspace**: são disparados quando um
arquivo é salvo, criado ou apagado (além de gatilhos manuais e de ciclo do
agente), e a ação costuma ser um **prompt em linguagem natural** para o
agente. Exemplos úteis em DevOps:

- Ao salvar um `*.tf`, validar formatação e apontar recursos sem tags obrigatórias.
- Ao criar um manifest Kubernetes, checar se a imagem usa tag imutável.
- Ao alterar um pipeline, revisar se algum segredo foi exposto.

### Agentes, MCP e autonomia

| Conceito | No Kiro | Equivalente no Claude Code |
|----------|---------|----------------------------|
| Agentes customizados | `~/.kiro/agents/` (pasta `agents/` deste kit) | Subagents em `.claude/agents/` |
| Servidores MCP | `.kiro/settings/mcp.json` ou `~/.kiro/settings/mcp.json` | `.mcp.json` / configuração do usuário |
| Nível de autonomia | **Autopilot** (agente executa) ou **Supervised** (cada alteração é revisada) | Modos de permissão |
| Configuração global | `~/.kiro/` | `~/.claude/` |

### Por que este kit é feito para o Kiro

- O mecanismo de `~/.kiro/steering` com `inclusion: always` garante que as
  regras de segurança de DevOps (sem `apply` sem pedido, GitOps, tags
  imutáveis, segredos no cofre) valham em **qualquer** workspace aberto.
- As specs dão o lugar natural para decisões que depois viram ADRs no
  repositório da aplicação.
- Tudo é arquivo Markdown/JSON versionado: o kit evolui por PR, como
  qualquer código.

> Os conceitos são próximos o bastante para que o conteúdo deste kit
> (regras e templates) seja facilmente adaptado para `CLAUDE.md` e
> `.claude/agents/` caso o time também use o Claude Code.

## Instalação

Clone o repositório em qualquer caminho e execute o script de instalação:

```bash
git clone <repo-url> <caminho-local>
cd <caminho-local>
./install.sh
```

O script:

- Cria links simbólicos em `~/.kiro/` para as pastas `steering`, `agents`,
  `skills`, `references` e `templates`.
- Cria a pasta `~/.kiro/prompts/` e linka nela cada arquivo de
  `prompts/exemplos/` e `prompts/reais/`. Isso é necessário porque o Kiro CLI
  só descobre prompts em `~/.kiro/prompts/*.md`, sem subpastas.
- Reaponta links simbólicos que apontam para outro caminho ou estão
  quebrados (por exemplo, se o kit foi movido de pasta).
- **Não** sobrescreve arquivos ou diretórios comuns: se algum destino já
  existir e não for link, exibe instruções e encerra sem alterar nada.

### Recomendado: carregar só as skills de cada agente

Por padrão, todo agente customizado do Kiro herda todas as skills de
`~/.kiro/skills/`, além das que declara. Para que cada agente carregue
apenas as skills e references do próprio JSON, ligue:

```bash
kiro-cli settings chat.disableInheritingDefaultResources true
```

Os agentes deste kit declaram o steering global explicitamente
(`file://~/.kiro/steering/**/*.md`), então as regras continuam valendo com
essa opção ligada. Essa configuração é global e afeta também outros agentes
customizados que você tenha.

## Atualização

```bash
cd <caminho-local>
git pull
```

Os links de pastas continuam válidos após o `git pull`. Rode `./install.sh`
de novo apenas quando um **prompt novo** for adicionado (os prompts são
linkados arquivo por arquivo).

## O que vai onde

| O que é | Onde fica |
|---------|-----------|
| Regras, skills, agentes, references e prompts genéricos | **Este repositório** |
| Análise de deploy da aplicação (`docs/deploy/analise.md`) | Repositório da aplicação |
| Dockerfile e `.dockerignore` | Repositório da aplicação |
| Manifests Kubernetes da aplicação | Gerados em `deploy/aks/` e entregues via PR no `<manifests-repo>` |
| Terraform de ECS da aplicação | Gerado em `deploy/ecs/` no repositório da aplicação (ou onde `<padrao-do-time>` definir) |
| ADRs e decisões técnicas | `docs/adr/` no repositório da aplicação |
| Pipelines CI/CD da aplicação | Repositório da aplicação |
| Segredos e configurações de ambiente | Cofre da cloud (Key Vault ou Secrets Manager) |

## Estrutura

```
devops-agent-kit/
├── AGENTS.md                      # Regras de manutenção deste kit
├── README.md
├── install.sh                     # Cria os links em ~/.kiro/
├── agents/                        # Agentes do Kiro CLI
│   ├── subir-app.json
│   ├── analyzer.json
│   ├── containerizer.json
│   ├── deployer.json
│   └── instrucoes/                # Prompt de sistema de cada agente
├── docs/
│   └── agents/                    # Documentação humana dos agentes
├── prompts/
│   ├── README.md                  # Como invocar cada prompt
│   ├── exemplos/                  # Prompts didáticos (exemplo-*.md)
│   └── reais/                     # Prompts do dia a dia (real-*.md)
├── references/                    # Conhecimento do time (completar)
├── skills/
│   ├── analisar-repo/             # SKILL.md e README.md
│   ├── gerar-dockerfile/
│   └── gerar-deploy/
├── steering/
│   └── devops-base.md             # inclusion: always
└── templates/
    └── adr/
        └── adr-template.md
```

## Convenções

- Placeholders seguem o formato `<placeholder>` em todo o kit.
- Nenhum valor específico de ambiente (URL, namespace, conta de cloud etc.)
  deve aparecer neste repositório.
- Textos em português do Brasil.
- Pull requests que adicionem conteúdo específico de aplicação serão
  rejeitados.

