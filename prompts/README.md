# Prompts salvos

Prompts prontos para as tarefas mais comuns do fluxo de deploy. São
arquivos Markdown simples, no formato de prompt salvo do Kiro CLI: o texto
do arquivo é enviado como mensagem, e `$ARGUMENTS` é substituído pelo texto
digitado depois do nome do prompt.

- `exemplos/`: prompts didáticos e curtos, para aprender o fluxo.
- `reais/`: prompts do dia a dia, com contexto e restrições.

## Instalação

O Kiro CLI só descobre prompts globais em `~/.kiro/prompts/*.md`, sem
subpastas. Por isso o `install.sh` não linka a pasta inteira: ele cria
`~/.kiro/prompts/` e linka cada arquivo de `exemplos/` e `reais/`
individualmente. Os nomes dos arquivos já têm prefixo (`exemplo-` e `real-`)
para não haver colisão.

Ao criar um prompt novo, rode `./install.sh` de novo para criar o link.

## Como invocar

1. Abra o terminal na raiz do repositório da aplicação.
2. Inicie o Kiro CLI com o agente indicado na tabela:

   ```bash
   kiro-cli chat --agent <agente>
   ```

   Dentro de uma sessão já aberta, troque de agente com `/agent swap`.
3. Digite `@` seguido do nome do prompt (sem `.md`) no **início** da linha,
   e opcionalmente o contexto, que entra no lugar de `$ARGUMENTS`:

   ```
   @real-fluxo-completo Destino AKS. O dev disse que a app usa Redis.
   ```

   Também funciona com `/prompts <nome>`. O comando `/prompts` sem nome lista
   os prompts disponíveis.

## Exemplos

| Prompt | Agente | Para que serve |
|--------|--------|----------------|
| `@exemplo-fluxo-completo` | `subir-app` | Fluxo completo: análise, confirmação, container e deploy |
| `@exemplo-analisar` | `analyzer` | Só a análise do repositório |
| `@exemplo-usar-skill` | qualquer | Pedir explicitamente a skill `analisar-repo` |
| `@exemplo-dockerfile` | `containerizer` | Só o Dockerfile e o `.dockerignore` |
| `@exemplo-deploy-aks` | `deployer` | Manifests YAML puros para AKS |
| `@exemplo-deploy-ecs` | `deployer` | Terraform para ECS |
| `@exemplo-revisar-dockerfile` | `containerizer` | Revisar um Dockerfile existente sem sobrescrever |

## Reais

| Prompt | Agente | Situação |
|--------|--------|----------|
| `@real-fluxo-completo` | `subir-app` | Fluxo completo com informações do time que precisam ser conferidas no código |
| `@real-analisar-sem-env-example` | `analyzer` | O time não mandou `.env.example` |
| `@real-usar-skill-redis-nao-encontrado` | `analyzer` | O dev diz que a app usa Redis, mas não aparece no código |
| `@real-dockerfile-feed-privado` | `containerizer` | Dockerfile com imagem base do registry interno e feed privado com token |
| `@real-deploy-aks-segredos-dominio` | `deployer` | AKS com 3 segredos no Key Vault e domínio com TLS |
| `@real-deploy-ecs-alb-existente` | `deployer` | ECS com cluster, VPC e ALB já existentes |
| `@real-revisar-dockerfile-ruim` | `containerizer` | O repositório já tem um Dockerfile ruim |

## Usar uma skill sem prompt salvo

Toda skill também vira um comando com o nome dela:

```
/analisar-repo Destino AKS.
/gerar-dockerfile
/gerar-deploy Destino: ECS.
```

Observação: se existir um prompt salvo com o mesmo nome de uma skill, o
prompt tem prioridade. Por isso nenhum prompt deste kit usa o nome de uma
skill.
