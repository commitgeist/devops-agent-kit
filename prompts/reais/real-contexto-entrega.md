Prepare o deploy desta aplicação com o contexto de entrega abaixo. Use
esses valores como "informado pelo usuário" no `docs/deploy/contexto.md` e
não pergunte de novo o que já está aqui. Itens deixados em branco ficam
`a definir`.

- Cloud e região: <AWS | Azure | GCP>, <regiao>
- Ambientes: <dev, hml, prd>
- IaC e versão: <Terraform | OpenTofu | Bicep | Pulumi | CDK | CloudFormation> <versao>
- Backend de state: <backend>
- IaC neste repositório ou em repositório separado: <deploy/ ou <iac-repo>>
- CI/CD: <GitHub Actions | Azure DevOps | Gitea Actions | Bitbucket | GitLab | Jenkins>
- Runners: <hospedados | self-hosted <label>>
- Autenticação do CI na cloud: <OIDC | service connection | workload identity>
- Aprovação para produção: <environment protegido | approval gate | manual>
- Registry de imagens: <registry>
- Cofre de segredos: <cofre>
- Templates de pipeline / módulos do time: <caminho ou "nenhum">
- Destino desejado (opcional, a análise vai validar): <destino>
- Contexto do time de dev: <informações recebidas>

Contexto adicional (sobrepõe os itens acima): $ARGUMENTS
