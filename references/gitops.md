# Fluxo GitOps para AKS

> Reference inicial. Complete os placeholders com o padrão real do time.

## Princípios

- O estado desejado do cluster vive no `<manifests-repo>`. O cluster é
  sincronizado por `<ferramenta-gitops>` (exemplo: Argo CD ou Flux).
- Manifests são **YAML puro**: sem Helm, sem Kustomize, sem templating,
  salvo decisão registrada em ADR.
- **Ninguém aplica nada direto no cluster.** Nada de `kubectl apply`,
  `kubectl edit`, `kubectl delete` ou `helm install`. A única forma de
  mudar o cluster é PR aprovado no `<manifests-repo>`.
- Imagens sempre com tag imutável (versão fixa ou digest).
- Segredos sempre no `<cofre>` (Azure Key Vault `<key-vault-name>`),
  montados via Secrets Store CSI Driver. Nunca `kind: Secret` com valor
  versionado.

## Estrutura do `<manifests-repo>`

```
<manifests-repo>/
└── <estrutura-de-pastas>/            # exemplo: apps/<aplicacao>/<ambiente>/
    ├── deployment.yaml
    ├── service.yaml
    ├── configmap.yaml
    ├── ingress.yaml                  # se aplicável
    └── secret-provider-class.yaml
```

- Namespace: `<padrao-de-namespace>`. Criado por `<quem-cria-namespace>`
  (os agentes não devem gerar `Namespace` se for criado por outro processo).
- Ambientes: `<lista-de-ambientes>`.

## Passo a passo do deploy

1. Gerar os manifests em `deploy/aks/` no repositório da aplicação
   (agente `deployer`).
2. Revisar os manifests localmente.
3. Criar branch no `<manifests-repo>` seguindo `<padrao-de-branch>`.
4. Copiar os manifests para `<estrutura-de-pastas>`.
5. Abrir PR com `<template-de-pr>` e revisores `<time-revisor>`.
6. Após aprovação e merge, acompanhar a sincronização em
   `<ferramenta-gitops>`.
7. Validar a aplicação em `<url-ou-procedimento-de-validacao>`.

## Rollback

- Reverter o PR no `<manifests-repo>`. Nunca corrigir direto no cluster.

## Pendências desta reference

- [ ] Ferramenta GitOps e onde acompanhar a sincronização.
- [ ] Estrutura de pastas do `<manifests-repo>`.
- [ ] Padrão de namespace e quem o cria.
- [ ] Ingress controller e `ingressClassName`.
- [ ] Como os certificados TLS são emitidos (`<emissor-tls>`).
- [ ] Padrão de branch, template de PR e revisores.
