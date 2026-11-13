# Contexto de entrega: <nome-da-aplicacao>

> Ferramentas e plataformas usadas para entregar esta aplicação. Os
> agentes do devops-agent-kit leem este arquivo antes de gerar IaC e
> pipeline. Pode ser preenchido à mão (copiando de
> `<kiro>/templates/deploy/contexto-entrega.md`) ou pelo agente `devops` (fluxo `subir-app`), que
> detecta o que dá no repositório e pergunta o resto.
>
> **Não coloque segredos aqui.** Só nomes, IDs não sensíveis e
> placeholders.
>
> Origem de cada valor: `detectado (<arquivo>)`, `informado pelo usuário`,
> `padrão do time` ou `a definir`.

## Cloud

| Item | Valor | Origem |
|------|-------|--------|
| Provedor | <AWS, Azure, GCP, on-premises> | |
| Conta / assinatura / projeto | <id-ou-placeholder> | |
| Região principal | <regiao> | |
| Ambientes | <dev, hml, prd> | |

## Infraestrutura como código

| Item | Valor | Origem |
|------|-------|--------|
| Ferramenta | <Terraform, OpenTofu, Bicep, Pulumi, AWS CDK, CloudFormation, nenhuma> | |
| Versão da ferramenta | <versao> | |
| Onde fica o código de IaC | <neste repositório em deploy/, ou repositório separado <iac-repo>> | |
| Backend / state | <S3 + DynamoDB, Azure Storage, Terraform Cloud, HCP, nenhum> | |
| Módulos internos do time | <registry ou repositório de módulos, ou "nenhum"> | |

## CI/CD

| Item | Valor | Origem |
|------|-------|--------|
| Plataforma | <GitHub Actions, Azure DevOps Pipelines, Gitea Actions, Bitbucket Pipelines, GitLab CI, Jenkins> | |
| Hospedagem do Git | <GitHub, Azure Repos, Gitea, Bitbucket, GitLab> | |
| Runners / agents | <hospedados pela plataforma ou self-hosted: <label-ou-pool>> | |
| Autenticação na cloud | <OIDC/federação, service connection, workload identity, chave estática (não recomendado)> | |
| Aprovação para produção | <environment protegido, approval gate, aprovação manual, nenhuma> | |
| Templates de pipeline do time | <repositório/caminho dos templates reutilizáveis, ou "nenhum"> | |

## Artefatos e segredos

| Item | Valor | Origem |
|------|-------|--------|
| Registry de imagens | <ECR, ACR, GHCR, Harbor, Gitea Packages, ...> | |
| Cofre de segredos | <AWS Secrets Manager, Azure Key Vault, Vault, ...> | |
| Segredos da plataforma de CI | <secrets do repositório, variable groups, environments> | |
| Scanner de imagem / IaC | <Trivy, Checkov, Defender, Inspector, nenhum> | |

## Kubernetes (se aplicável)

| Item | Valor | Origem |
|------|-------|--------|
| Ferramenta GitOps | <Argo CD, Flux, nenhuma> | |
| Repositório de manifests | <manifests-repo> | |

## References do time confirmadas

| Reference | Por que se aplica | Confirmada por |
|-----------|-------------------|----------------|
| <references/...> | <motivo> | <usuário, data> |

## MCP disponíveis nesta máquina

| Servidor | Uso | Origem |
|----------|-----|--------|
| <nome> | <documentação, consulta à plataforma> | |

## Observações

- <restrições do time, exceções aprovadas, links para ADRs>
