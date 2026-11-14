# Guia de uso

Passo a passo para quem nunca usou o kit. Para entender o que cada peça
faz, veja [como-funciona.md](como-funciona.md).

## 1. Pré-requisitos

- Kiro CLI 3.x logado (`kiro-cli --version`, `kiro-cli whoami`).
- `git` e `python3` (o hook de segredos usa `python3`).
- Opcionais: `hadolint`, `docker`, `terraform`/`tofu`, `bicep`, `gitleaks`,
  `trivy`, `semgrep`, `checkov`.

## 2. Ativar a engine v3 (uma vez por máquina)

```bash
kiro-cli settings chat.agentEngine v3
kiro-cli settings chat.disableInheritingDefaultResources true
```

A primeira é obrigatória: os agentes do kit estão no formato v3. A segunda
faz cada agente carregar só o que declara.

## 3. Instalar no repositório (recomendado)

```bash
git clone <repo-url> <caminho-do-kit>
cd <repo-da-aplicacao>
git init                                          # só se ainda não for repositório git
bash <caminho-do-kit>/install.sh --projeto .
```

- Cria `.kiro/` no repositório com agentes, skills, steering, references,
  templates, prompts e o hook.
- Coloca `.kiro/` em `.git/info/exclude`: não sobe para o git e não mexe
  no `.gitignore` do time.
- Rode o `git init` **antes**: fora de um repositório git o instalador só
  avisa, e o `.kiro/` não fica ignorado.

Conferir:

```bash
kiro-cli agent list   # devops, reviewer, secops, analyzer, containerizer, deployer, pipeliner (Workspace)
```

Quer o kit em qualquer pasta? Use o modo global (`bash <caminho-do-kit>/install.sh`).
Diferenças em [como-funciona.md](como-funciona.md#modo-projeto--modo-global).

## 4. Abrir um agente

Na raiz do repositório da aplicação:

```bash
kiro-cli chat --agent devops      # preparar o deploy
kiro-cli chat --agent reviewer    # revisar ADR, análise, IaC, pipeline, branch
kiro-cli chat --agent secops      # avaliar segurança
```

Dentro do chat, `/agent swap` troca de agente.

## 5. Usar os prompts prontos

No chat, digite `/` e o nome do prompt; o texto depois do nome entra no
lugar de `$ARGUMENTS`:

```
/real-fluxo-completo O time disse que a app usa Postgres e não mandou .env.example.
```

| Prompt | Agente | Quando usar |
|--------|--------|-------------|
| `/real-fluxo-completo` | `devops` | Deploy do zero: contexto, análise, confirmação e artefatos |
| `/real-contexto-entrega` | `devops` | Mesmo fluxo, já passando cloud, IaC, CI/CD e destino |
| `/real-analisar-conferir-time` | `analyzer` | Refazer a análise conferindo o que o time de dev disse |
| `/real-dockerfile` | `containerizer` | Gerar ou revisar Dockerfile |
| `/real-deploy-aks-segredos-dominio` | `deployer` | Manifests AKS com Key Vault e domínio com TLS |
| `/real-deploy-ecs-alb-existente` | `deployer` | ECS Fargate reaproveitando cluster, VPC e ALB |
| `/real-revisar-adr` | `reviewer` | Cobrar as ADRs contra a implementação |
| `/real-revisar-branch` | `reviewer` | Revisar o diff da branch antes do PR |
| `/real-secops-avaliar` | `secops` | Avaliar segurança e propor estágios na pipeline |

`/prompts list` mostra todos. Prompts dos especialistas também funcionam a
partir do `devops`: ele delega.

## 6. Testar a delegação em paralelo

1. Abra `kiro-cli chat --agent devops` no repositório.
2. Cole:

   ```
   Delegue em paralelo: analyzer analisa o repo, secops avalia a segurança, reviewer revisa o repo. Use AWS, Terraform e GitHub Actions. Não me pergunte nada antes.
   ```

   Funcionou se os três aparecem rodando juntos e no fim existem
   `docs/deploy/`, `docs/security/` e `docs/review/`.
3. No mesmo chat:

   ```
   Agora gere em paralelo o deploy e o pipeline com base na análise.
   ```

   Aprove quando o Kiro pedir permissão (os geradores são `ask`). Para site
   estático, o `containerizer` não deve ser chamado.

Para ver o paralelo, peça "em paralelo" explicitamente. Um pedido vago
("sobe essa app") segue o fluxo `subir-app`, que pergunta e espera sua
confirmação antes de gerar.

## 7. Personalizar para o time

Edite **no kit** (as cópias em `.kiro/` são sobrescritas a cada instalação):

1. `references/padroes-do-time.md`: cloud, IaC, CI/CD, registry, cofre,
   scanner. O que ficar `<a-definir>` o agente pergunta.
2. `references/nomenclatura.md`: padrão de nomes de recursos, tags e
   segredos.
3. Templates de pipeline em `references/pipeline/` e módulos de IaC em
   `references/iac/`.
4. Toda reference nova entra no índice `references/README.md`, com
   "Quando usar" e status.
5. Rode `install.sh --projeto <repo>` de novo para atualizar a cópia.

## 8. Ligar MCP (opcional)

```bash
./mcp/configurar-mcp.sh                                  # catálogo
./mcp/configurar-mcp.sh aws-docs microsoft-learn         # simula
./mcp/configurar-mcp.sh --aplicar aws-docs microsoft-learn
kiro-cli mcp list
```

Servidores de documentação ficam liberados; os de plataforma (GitHub, Azure
DevOps, Gitea) pedem confirmação a cada chamada. Token só em variável de
ambiente, nunca em arquivo. Detalhes em [../mcp/README.md](../mcp/README.md).

## 9. Problemas comuns

| Sintoma | Causa | Solução |
|---------|-------|---------|
| `Mode '<agente>' not found` | Engine v3 desligada | `kiro-cli settings chat.agentEngine v3` |
| `ERRO: ~/.kiro/agents já existe e não é link simbólico` (modo global) | Pasta sua em `~/.kiro/agents`. Se só tiver o exemplo do Kiro, o instalador resolve sozinho | Mova a pasta (`mv ~/.kiro/agents ~/.kiro/agents.bak`) ou use o modo projeto |
| Agente diz que a leitura foi bloqueada pelo guardrail | O hook ou a permissão barrou um arquivo de segredo | Esperado. Passe só os **nomes** das variáveis ou use `.env.example` |
| `.kiro/` aparece no `git status` | Instalou antes do `git init` | Rode `install.sh --projeto .` de novo, ou ponha `.kiro/` no `.gitignore` |
| Agentes não aparecem em `kiro-cli agent list` | Kiro aberto fora da raiz do repositório | Abra o chat na raiz, onde está `.kiro/` |
| Subagente "pergunta" e para | Subagente não fala com o usuário | Responda ao `devops`; ele repassa na próxima delegação |

## Evals

Testes automáticos dos agentes e prompts com o seu setup, usando o
promptfoo. Um robô abre o Kiro, faz o pedido, espera e confere o
resultado, em vez de você testar na mão a cada mudança no kit.

```bash
./testar.sh guardrail   # testes rápidos de segredo
./testar.sh             # todos
./testar.sh ver         # resultado no navegador
```

Guia completo, como escrever testes e como comparar versões de prompt:
[../evals/README.md](../evals/README.md).
