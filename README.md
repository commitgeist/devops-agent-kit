# DevOps Agent Kit

Kit reutilizável de agentes e regras de DevOps para o **Kiro (AWS)**. Este kit
é especificamente voltado ao Kiro com AWS. Contém apenas padrões genéricos —
nada específico de aplicação, cliente, servidor ou pessoa.
Qualquer detalhe particular de uma aplicação é gerado dentro do repositório
dessa aplicação, nunca aqui.

## Propósito

Centralizar em um único lugar:

- Regras de comportamento (steering) que se aplicam a qualquer trabalho de DevOps
- Definições de agentes reutilizáveis
- Modelos (templates) de documentos padrão

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

Clone o repositório em qualquer caminho de sua preferência e execute o
script de instalação:

```bash
git clone <repo-url> <caminho-local>
cd <caminho-local>
./install.sh
```

O script cria links simbólicos em `~/.kiro/` apontando para as pastas
`steering`, `agents` e `templates` deste kit. Depois disso o Kiro carrega
automaticamente as regras e os agentes em qualquer workspace aberto na
máquina.

Se algum dos destinos já existir como arquivo ou diretório comum, o script
**não** o sobrescreverá: ele exibirá instruções e encerrará sem fazer
alterações.

## Atualização

Basta atualizar o repositório local — os links simbólicos continuam válidos:

```bash
cd <caminho-local>
git pull
```

Não é necessário executar `install.sh` novamente após um `git pull`.

## O que vai onde

| O que é | Onde fica |
|---------|-----------|
| Regras e agentes genéricos de DevOps | **Este repositório** |
| Manifests Kubernetes da aplicação | Repositório de manifests da aplicação |
| ADRs e decisões técnicas | `docs/adr/` no repositório da aplicação |
| Pipelines CI/CD da aplicação | Repositório da aplicação |
| Segredos e configurações de ambiente | Cofre da cloud (Key Vault / Secrets Manager) |

## Estrutura

```
devops-agent-kit/
├── agents/           # Definições de agentes reutilizáveis
├── steering/         # Regras de comportamento (inclusion: always)
│   └── devops-base.md
└── templates/
    └── adr/
        └── adr-template.md
```

## Convenções

- Placeholders seguem o formato `<placeholder>` em todo o kit.
- Nenhum valor específico de ambiente (URL, namespace, conta de cloud, etc.)
  deve aparecer neste repositório.
- Pull requests que adicionem conteúdo específico de aplicação serão rejeitados.
# devops-agent-kit
