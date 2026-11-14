# Prompts salvos

Abra o Kiro CLI na raiz do repositório da aplicação com o agente indicado
(`kiro-cli chat --agent <agente>` ou `/agent swap`) e digite `/nome` no
início da linha, seguido do contexto opcional, que entra no lugar de
`$ARGUMENTS`. Exemplo: `/real-fluxo-completo Destino AKS. O dev disse que a
app usa Redis.` Na engine v3 os prompts aparecem no autocompletar do `/`;
`@nome` só funciona nas engines antigas
([doc](https://kiro.dev/docs/cli/chat/manage-prompts/)). `/prompts list`
mostra todos.

O modo projeto copia os prompts para `<repo>/.kiro/prompts/`; o modo
global linka cada arquivo em `~/.kiro/prompts/`. Rode o instalador de novo
ao criar um prompt.

| Prompt | Agente | Quando usar |
|--------|--------|-------------|
| `/real-fluxo-completo` | `devops` | Preparar o deploy de um repositório do zero: contexto, análise, confirmação e artefatos |
| `/real-contexto-entrega` | `devops` | Mesmo fluxo, já passando cloud, IaC, CI/CD e destino de uma vez |
| `/real-analisar-conferir-time` | `analyzer` | Refazer a análise conferindo o que o time disse (variáveis, Redis, falta de `.env.example`) |
| `/real-dockerfile` | `containerizer` | Gerar ou revisar Dockerfile, com registry interno e feed privado |
| `/real-deploy-aks-segredos-dominio` | `deployer` | Manifests AKS com segredos no Key Vault e domínio com TLS |
| `/real-deploy-ecs-alb-existente` | `deployer` | ECS Fargate reaproveitando cluster, VPC e ALB existentes |
| `/real-revisar-adr` | `reviewer` | Cobrar as ADRs contra a implementação |
| `/real-revisar-branch` | `reviewer` | Revisar o diff da branch antes do PR |
| `/real-secops-avaliar` | `secops` | Avaliar a segurança do repositório e propor estágios de segurança na pipeline |
