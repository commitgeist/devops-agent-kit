---
name: gerar-deploy
description: Gera artefatos de deploy a partir de docs/deploy/analise.md. Para AKS, manifests YAML puros (Deployment, Service, Ingress, ConfigMap) com probes, requests e limits e segredos do cofre, prontos para PR no repositório de manifests. Para ECS, Terraform (task definition, service, target group, log group e IAM de menor privilégio). Nunca aplica nada.
---

# Skill: gerar-deploy

Você vai gerar os artefatos de deploy da aplicação do workspace com base em
`docs/deploy/analise.md`.

Contexto adicional informado pelo usuário (pode estar vazio):
$ARGUMENTS

## Pré-requisito

1. Leia `docs/deploy/analise.md`. Se não existir, **pare** e oriente o
   usuário a rodar antes a skill `analisar-repo`.
2. Destino: use o informado pelo usuário nesta conversa; se não houver, use
   a seção 9 da análise. Se continuar indefinido, pergunte e pare.
3. Siga as references carregadas (`gitops.md`, `nomenclatura.md`,
   `checklist-producao.md`). Quando uma reference ainda tiver placeholders,
   mantenha os placeholders nos artefatos em vez de inventar valores.

## Regras inegociáveis

- **Nunca aplicar nada:** nada de `kubectl apply`, `kubectl create`,
  `helm`, `terraform apply`, `terraform destroy`, `aws ecs update-service`
  ou equivalentes.
- **Nunca usar `latest`.** A imagem é sempre `<registry>/<imagem>:<tag>` ou
  `<registry>/<imagem>@sha256:<digest>`.
- **Segredos só por referência ao cofre**, nunca com valor. Nada de
  `kind: Secret` com `data` ou `stringData` preenchidos.
- **Nomes seguem `nomenclatura.md`.** Valores desconhecidos ficam como
  `<placeholder>`.
- Não alterar código da aplicação nem o Dockerfile.

## Destino AKS (GitOps, YAML puro)

Gere em `deploy/aks/` no repositório da aplicação, prontos para serem
copiados para o `<manifests-repo>` via PR, conforme `gitops.md`:

| Arquivo | Conteúdo |
|---------|----------|
| `deployment.yaml` | `Deployment` com imagem de tag imutável, `replicas` (mínimo 2 para produção), `resources.requests` e `resources.limits`, `livenessProbe`, `readinessProbe` (e `startupProbe` se a aplicação demora a subir), `securityContext` (`runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem` quando possível), `envFrom` ou `env` apontando para o ConfigMap e para os segredos |
| `service.yaml` | `Service` `ClusterIP` com a porta da análise |
| `configmap.yaml` | `ConfigMap` só com variáveis de **config** da análise |
| `ingress.yaml` | Só se a aplicação for exposta por HTTP para fora do cluster. Host `<dominio>`, TLS com `<tls-secret-name>`, `ingressClassName: <ingress-class>` |
| `secret-provider-class.yaml` | Referência ao Azure Key Vault (`SecretProviderClass` do Secrets Store CSI Driver) com `keyvaultName: <key-vault-name>` e um objeto por segredo da análise (`<secret-name>`), mais `secretObjects` se a aplicação ler segredos como variável de ambiente |

Regras específicas:

- YAML puro: sem Helm, sem Kustomize, sem templating, salvo ADR em contrário.
- Labels padrão em todos os objetos, conforme `nomenclatura.md`.
- Sem endpoint de healthcheck na análise: use `tcpSocket` na porta e
  registre como pendência para o time de dev.
- Requests e limits: proponha valores iniciais conservadores e registre que
  precisam ser calibrados com métricas reais.
- Não gere `Namespace` se a reference `gitops.md` disser que o namespace é
  criado por outro processo.

## Destino ECS (Terraform)

Gere em `deploy/ecs/` no repositório da aplicação:

| Arquivo | Conteúdo |
|---------|----------|
| `versions.tf` | `required_version` e `required_providers` com versão fixa do provider AWS |
| `variables.tf` | Variáveis para tudo que muda por ambiente: `<cluster-name>`, VPC, subnets, listener do ALB, imagem, CPU, memória, contagem desejada, ARNs dos segredos |
| `main.tf` | `aws_ecs_task_definition` (Fargate, `awsvpc`, `cpu`, `memory`, porta, `healthCheck` do container quando houver endpoint, `environment` só com config, `secrets` com `valueFrom` apontando para ARNs do Secrets Manager, `logConfiguration` com `awslogs`); `aws_ecs_service` (subnets privadas, sem IP público, `deployment_circuit_breaker` com rollback, `load_balancer` quando houver porta HTTP); `aws_lb_target_group` (`target_type = "ip"`, health check no endpoint da análise); `aws_lb_listener_rule` para o host `<dominio>` quando houver domínio; `aws_cloudwatch_log_group` com `retention_in_days` definido |
| `iam.tf` | **Execution role** com permissão só para puxar a imagem, escrever no log group criado e ler apenas os ARNs de segredos listados (`secretsmanager:GetSecretValue` restrito por ARN, mais `kms:Decrypt` restrito se houver chave dedicada). **Task role** separada, com só as permissões que a aplicação usa segundo a análise; se nenhuma, sem policies |
| `outputs.tf` | ARNs e nomes úteis (service, task definition, target group, log group) |
| `terraform.tfvars.example` | Exemplo com placeholders, sem segredos |

Regras específicas:

- Nada de `"*"` em `Action` ou `Resource` nas policies.
- Não criar VPC, cluster ou ALB: recebê-los por variável, salvo pedido
  explícito.
- Tags padrão conforme `nomenclatura.md`.
- Backend do state: deixar bloco com placeholders (`<state-bucket>`,
  `<state-key>`), sem valores reais.
- Pode sugerir `terraform fmt` e `terraform validate`, mas nunca `plan`
  com credencial nem `apply`.

## Documentação gerada

Sempre gere `docs/deploy/deploy-<aks ou ecs>.md` com:

1. Lista de arquivos gerados e o que cada um faz.
2. Segredos que precisam ser criados no cofre, só com os **nomes**
   (`<secret-name>`), e quem deve criá-los.
3. Placeholders que ainda precisam ser preenchidos.
4. Próximos passos: para AKS, o fluxo de PR descrito em `gitops.md`; para
   ECS, quem roda `plan` e `apply` e em qual pipeline.
5. Resultado do `checklist-producao.md`, item a item, marcando o que está
   atendido, pendente ou não se aplica.

## Ao terminar

Mostre no chat: destino, arquivos gerados, segredos esperados no cofre,
placeholders pendentes e itens pendentes do checklist.
