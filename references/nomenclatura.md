# Padrão de nomenclatura

> Reference inicial. Complete com o padrão real do time. Os agentes usam
> este arquivo para nomear recursos e, enquanto houver placeholders, mantêm
> os placeholders nos artefatos.

## Componentes do nome

| Componente | Descrição | Formato | Exemplo genérico |
|------------|-----------|---------|------------------|
| `<produto>` | Produto ou sistema ao qual a aplicação pertence | `<regra>` | `<produto>` |
| `<aplicacao>` | Nome curto da aplicação | minúsculas, hífen | `<aplicacao>` |
| `<componente>` | Parte da aplicação (api, worker, web) | minúsculas | `<componente>` |
| `<ambiente>` | Ambiente | `<lista-de-siglas>` | `<ambiente>` |
| `<regiao>` | Região da cloud | `<lista-de-siglas>` | `<regiao>` |

Ordem e separador: `<ordem-dos-componentes>` com `<separador>`.

## Kubernetes (AKS)

| Objeto | Padrão |
|--------|--------|
| Namespace | `<padrao-namespace>` |
| Deployment, Service, ConfigMap | `<padrao-workload>` |
| Ingress | `<padrao-ingress>` |
| SecretProviderClass | `<padrao-secret-provider-class>` |
| Host do Ingress | `<padrao-host>` |

Labels obrigatórias em todos os objetos:

```yaml
app.kubernetes.io/name: <aplicacao>
app.kubernetes.io/component: <componente>
app.kubernetes.io/part-of: <produto>
app.kubernetes.io/version: <versao>
<label-do-time>: <valor>
```

## AWS (ECS)

| Recurso | Padrão |
|---------|--------|
| ECS service | `<padrao-service>` |
| Task definition family | `<padrao-task-family>` |
| Target group (máximo 32 caracteres) | `<padrao-target-group>` |
| Log group | `<padrao-log-group>` |
| IAM roles (execution e task) | `<padrao-iam-role>` |
| Segredos no Secrets Manager | `<padrao-secret>` |

Tags obrigatórias em todos os recursos:

```hcl
tags = {
  <tag-produto>    = "<produto>"
  <tag-aplicacao>  = "<aplicacao>"
  <tag-ambiente>   = "<ambiente>"
  <tag-time>       = "<time>"
  <tag-custo>      = "<centro-de-custo>"
}
```

## Hospedagem estática

| Recurso | Padrão |
|---------|--------|
| Bucket S3 (globalmente único, minúsculas) | `<padrao-bucket>` |
| Distribuição CloudFront (comentário/tag) | `<padrao-cloudfront>` |
| Storage Account (3 a 24 caracteres, só minúsculas e números) | `<padrao-storage-account>` |
| Front Door profile e endpoint | `<padrao-front-door>` |

## Segredos no cofre

- Azure Key Vault: `<padrao-nome-segredo-key-vault>` (apenas letras,
  números e hífen).
- AWS Secrets Manager: `<padrao-nome-segredo-secrets-manager>`.

## Pendências desta reference

- [ ] Ordem e separador dos componentes.
- [ ] Siglas de ambiente e região.
- [ ] Padrões de cada objeto Kubernetes, recurso AWS e recurso Azure.
- [ ] Labels e tags obrigatórias reais.
