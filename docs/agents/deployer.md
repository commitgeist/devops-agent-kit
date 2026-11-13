# Agente deployer

Arquivos: `agents/deployer.json` e `agents/instrucoes/deployer.md`.

## Papel

Gerar os artefatos de deploy a partir de `docs/deploy/analise.md`:
manifests YAML puros para AKS (entregues via PR no `<manifests-repo>`),
Terraform para ECS ou Terraform de hospedagem estática (armazenamento +
CDN, AWS ou Azure). Nunca aplica nada nem publica conteúdo.

## Skills que usa

- `gerar-deploy`

Resources carregados: steering global, `references/gitops.md`,
`references/nomenclatura.md` e `references/checklist-producao.md`.

## O que pode fazer

- Ler arquivos do workspace.
- Escrever em `deploy/` e `docs/deploy/` (aprovados automaticamente por
  `toolsSettings.write.allowedPaths`).
- Rodar apenas `terraform fmt`, `terraform validate` e
  `terraform init -backend=false` (`toolsSettings.shell` com
  `denyByDefault`).

## O que não pode fazer

- `kubectl`, `helm`, `terraform apply`, `terraform destroy`, comandos
  `aws ecs`, `aws s3`, `aws cloudfront`, `az` ou qualquer deploy.
- Usar `latest`.
- Colocar valores de segredos em manifests ou Terraform.
- Alterar código da aplicação ou o Dockerfile.
- Rodar sem `docs/deploy/analise.md` ou sem destino definido.

## Exemplo de uso

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent deployer
```

```
Gere o deploy para AKS.
```

## Exemplo de uso real

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent deployer
```

```
@real-deploy-aks-segredos-dominio Ambiente <ambiente>, domínio <dominio>, Key Vault <key-vault-name>, segredos <secret-db-password>, <secret-api-token> e <secret-jwt-key>.
```

O agente gera `deploy/aks/` com Deployment, Service, ConfigMap, Ingress
com TLS e SecretProviderClass, e `docs/deploy/deploy-aks.md` com os
segredos esperados no cofre, os placeholders pendentes e o passo a passo do
PR.
