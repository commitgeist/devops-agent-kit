---
name: gerar-deploy
description: Gera artefatos de deploy a partir de docs/deploy/analise.md e docs/deploy/contexto.md, na ferramenta de IaC do contexto (Terraform, OpenTofu, Bicep, Pulumi, CDK ou CloudFormation). Para hospedagem estática (sem processo em execução), armazenamento privado + CDN na AWS (S3 + CloudFront) ou Azure (Storage Account + Front Door). Para AKS, manifests YAML puros (Deployment, Service, Ingress, ConfigMap) com probes, requests e limits e segredos do cofre, prontos para PR no repositório de manifests. Para ECS, task definition, service, target group, log group e IAM de menor privilégio). Nunca aplica nada.
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
   Esta skill gera artefatos para três destinos: **AKS**, **ECS** e
   **hospedagem estática** (AWS ou Azure). Se o destino for outro (exemplo:
   serverless, PaaS de aplicação), **pare** e informe que o kit ainda não
   tem gerador para ele. Não adapte a aplicação a um destino suportado por
   conta própria.
3. Leia `docs/deploy/contexto.md` (gerado pelo `analyzer`). Dele vêm a
   cloud, a **ferramenta de IaC** e a versão, o backend de state, o
   registry e o cofre de segredos. Se a ferramenta de IaC estiver
   `a definir`, pergunte e pare.
4. Siga as references carregadas (`gitops.md`, `nomenclatura.md`,
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

## Ferramenta de IaC

As seções de destino abaixo descrevem **quais recursos e configurações** são
exigidos. O **formato** segue a ferramenta de `docs/deploy/contexto.md`:

| Ferramenta | Formato gerado | Validação permitida |
|------------|----------------|---------------------|
| Terraform | `*.tf`, `terraform.tfvars.example`, backend com placeholders | `terraform fmt`, `terraform init -backend=false`, `terraform validate` |
| OpenTofu | igual ao Terraform, com `required_version` do OpenTofu | `tofu fmt`, `tofu init -backend=false`, `tofu validate` |
| Bicep | `main.bicep`, módulos em `modules/`, `<ambiente>.bicepparam` com placeholders | `bicep build`, `bicep lint` |
| Pulumi | projeto na linguagem informada no contexto (pergunte se faltar), `Pulumi.yaml` e `Pulumi.<ambiente>.yaml` sem segredos | nenhuma (registre como pendência) |
| AWS CDK | app na linguagem informada no contexto, stack por destino | nenhuma (registre como pendência) |
| CloudFormation | `template.yaml` e `parameters-<ambiente>.json` com placeholders | nenhuma (registre como pendência) |

Regras:

- Ferramenta incompatível com a cloud (exemplo: Bicep para AWS, CDK para
  Azure): **pare** e registre a divergência.
- Se o contexto apontar **módulos internos do time**, use-os em vez de
  recursos crus e mantenha a versão do módulo fixa.
- Se o código de IaC fica em **repositório separado** (`<iac-repo>`),
  gere em `deploy/` mesmo assim e documente que precisa ser levado ao
  `<iac-repo>` por PR.
- Versões de provider, módulo e ferramenta sempre fixas.
- As regras de segurança de cada destino (sem `*` em IAM, sem segredo com
  valor, armazenamento privado etc.) valem para qualquer ferramenta.
- Onde as seções abaixo citam recursos Terraform (`aws_...`), use o
  equivalente da ferramenta escolhida.

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

## Destino ECS (IaC)

Gere em `deploy/ecs/` no repositório da aplicação. Os nomes de arquivo abaixo são os de Terraform/OpenTofu; com outra
ferramenta, use a estrutura da tabela "Ferramenta de IaC" cobrindo os
mesmos recursos.

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
- Rode só a validação permitida para a ferramenta (tabela acima). Nunca
  `plan`/`preview`/`what-if` com credencial nem `apply`/`up`/`deploy`.

## Destino hospedagem estática (IaC)

Use quando a seção 9 da análise indicar que a aplicação **não precisa de
processo em execução** (o build gera apenas arquivos estáticos). Não há
imagem de container, porta, probe nem segredo de runtime.

Antes de gerar, confirme na análise:

- **Diretório do artefato** de build (exemplo: `dist/`, `build/`, `out/`).
- **Se é SPA** com roteamento no cliente (precisa de fallback para
  `index.html`) ou site multipágina (404 real). Evidências comuns: router
  no front-end, `_redirects`, `rewrites` em configs de hospedagem.
- **Cloud**: AWS ou Azure. Se estiver "a definir", pergunte e pare.

Princípios para qualquer cloud:

- **Armazenamento nunca exposto diretamente**: o acesso público passa só
  pela CDN, salvo limitação da cloud documentada no `deploy-estatico.md`.
- **HTTPS obrigatório** com redirecionamento de HTTP, TLS mínimo 1.2,
  certificado gerenciado para `<dominio>`.
- **Cache por tipo de arquivo**: assets com hash no nome ficam com cache
  longo e `immutable`; `index.html` (e demais HTML) com `no-cache`, para que
  um deploy novo apareça sem invalidar tudo.
- **Fallback SPA** só se a análise indicar SPA, e devolvendo `index.html`
  com status 200. Não mascarar 404 de assets inexistentes quando a cloud
  permitir distinguir.
- **Headers de segurança** na CDN: HSTS, `X-Content-Type-Options`,
  `Referrer-Policy`, `X-Frame-Options` ou `frame-ancestors`. CSP só como
  proposta comentada, já que depende das origens externas da análise
  (exemplo: fontes ou scripts de terceiros).
- **Versionamento/soft delete** no armazenamento para permitir rollback.
- **Logs de acesso** da CDN com retenção definida.
- Não criar zona DNS: receber por variável, salvo pedido explícito.
- Tags padrão e nomes conforme `nomenclatura.md`.

Gere em `deploy/estatico/` no repositório da aplicação. Os nomes de arquivo abaixo são os de Terraform/OpenTofu; com outra
ferramenta, use a estrutura da tabela "Ferramenta de IaC" cobrindo os
mesmos recursos.

| Arquivo | Conteúdo |
|---------|----------|
| `versions.tf` | `required_version` e provider da cloud com versão fixa; backend com placeholders |
| `variables.tf` | Nome da aplicação, ambiente, região, `<dominio>`, referência à zona DNS existente, retenção de logs, se é SPA |
| `main.tf` | Armazenamento, CDN, regras de cache, fallback SPA, headers e logs, conforme a cloud (abaixo) |
| `outputs.tf` | Nome do armazenamento, ID/endpoint da CDN e o que o pipeline precisa para publicar e invalidar cache |
| `terraform.tfvars.example` | Exemplo com placeholders, sem segredos |

**AWS:** bucket S3 privado (Block Public Access ligado, `BucketOwnerEnforced`,
criptografia, versionamento) servido por CloudFront com **Origin Access
Control** e bucket policy restrita à distribuição. Certificado ACM em
`us-east-1` (exigência do CloudFront, usar provider com alias). Cache e
headers por *cache policy* e *response headers policy* gerenciadas ou
próprias. Fallback SPA por `custom_error_response` (403 e 404 para
`/index.html` com 200) ou CloudFront Function. Não usar o endpoint de
website do S3, que exige bucket público.

**Azure:** Storage Account (`StorageV2`, `min_tls_version = "TLS1_2"`,
`https_traffic_only_enabled`, sem acesso anônimo a blobs fora do container
`$web`, soft delete de blobs) com static website habilitado, servido por
**Azure Front Door** Standard ou Premium com domínio próprio e certificado
gerenciado. Cache e headers por *rule set*. Fallback SPA por regra de URL
rewrite para `/index.html` em caminhos sem extensão (o `error_404_document`
do static website devolve status 404 e não deve ser a solução principal).
O endpoint do static website continua acessível diretamente: registre isso
como risco e, se o time exigir origem privada, proponha Front Door Premium
com Private Link para o blob como alternativa em ADR.

**Publicação** do conteúdo não é IaC: documente os comandos que o
**pipeline** vai rodar, sem executá-los. Envio do diretório do artefato com
os headers de cache certos (HTML separado dos assets), remoção de arquivos
antigos e invalidação/purge da CDN só nos caminhos de HTML. A identidade do
pipeline deve ter permissão só de escrita no armazenamento e de
invalidação/purge da CDN, de preferência via federação OIDC, sem chave de
acesso de longa duração.

## Documentação gerada

Sempre gere `docs/deploy/deploy-<aks, ecs ou estatico>.md` com:

1. Lista de arquivos gerados e o que cada um faz.
2. Segredos que precisam ser criados no cofre, só com os **nomes**
   (`<secret-name>`), e quem deve criá-los.
3. Placeholders que ainda precisam ser preenchidos.
4. Próximos passos: para AKS, o fluxo de PR descrito em `gitops.md`; para
   ECS e hospedagem estática, quem roda `plan` e `apply` e em qual
   pipeline; para hospedagem estática, também os comandos de publicação e
   de invalidação de cache que o pipeline deve executar.
5. Resultado do `checklist-producao.md`, item a item, marcando o que está
   atendido, pendente ou não se aplica.

## Ao terminar

Mostre no chat: destino, arquivos gerados, segredos esperados no cofre,
placeholders pendentes e itens pendentes do checklist.
