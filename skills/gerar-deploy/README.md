# Skill gerar-deploy

## Para que serve

Gera os artefatos de deploy da aplicação a partir de
`docs/deploy/analise.md`, conforme o destino:

- **AKS:** manifests YAML puros (Deployment, Service, ConfigMap, Ingress
  quando aplicável e SecretProviderClass para o Key Vault), prontos para PR
  no `<manifests-repo>` via GitOps.
- **ECS:** Terraform com task definition, service, target group, log group
  com retenção e IAM de menor privilégio.

A skill nunca aplica nada e nunca usa a tag `latest`.

## Quando usar

- Depois da `analisar-repo`, com o destino definido.
- Quando a aplicação ganhar novo segredo, nova variável ou novo domínio e
  os artefatos precisarem ser regerados.

## Entradas

- `docs/deploy/analise.md` (obrigatório).
- Destino (AKS ou ECS): informado no pedido ou lido da seção 9 da análise.
- Opcional: domínio, nomes de segredos, ambiente, restrições de recursos.
- References carregadas pelo agente `deployer`: `gitops.md`,
  `nomenclatura.md`, `checklist-producao.md`.

## Saída

- AKS: `deploy/aks/*.yaml`.
- ECS: `deploy/ecs/*.tf` e `deploy/ecs/terraform.tfvars.example`.
- Sempre: `docs/deploy/deploy-<aks ou ecs>.md` com segredos esperados,
  placeholders pendentes, próximos passos e o checklist de produção.

## Exemplo de uso

```
/gerar-deploy Destino: AKS.
```

```
/gerar-deploy Destino: ECS.
```

## Exemplo de uso real

A aplicação vai para AKS, precisa de três segredos e será publicada em um
domínio próprio.

```
/gerar-deploy Destino: AKS, ambiente <ambiente>. Domínio <dominio>. Segredos no Key Vault <key-vault-name>: <secret-db-password>, <secret-api-token>, <secret-jwt-key>. A app demora cerca de 60 segundos para subir.
```

Resultado esperado: `deploy/aks/` com Deployment (incluindo `startupProbe`
por causa da subida lenta), Service, ConfigMap, Ingress para `<dominio>` com
TLS e SecretProviderClass com os três objetos do Key Vault;
`docs/deploy/deploy-aks.md` lista os três segredos que precisam existir no
cofre e os passos do PR no `<manifests-repo>`.
