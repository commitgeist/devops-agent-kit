---
inclusion: always
---

# Regras base de DevOps

Estas regras se aplicam a qualquer trabalho de DevOps neste workspace.

## Ações destrutivas ou irreversíveis

- **Nunca** executar `terraform apply` ou `terraform destroy` sem pedido
  explícito do usuário na mensagem atual.
- **Nunca** executar `kubectl apply`, `kubectl delete` ou qualquer operação
  direta no cluster sem pedido explícito.
- **Nunca** disparar um deploy (em qualquer plataforma) sem pedido explícito.
- **Nunca** criar um commit ou push sem pedido explícito.

## Kubernetes via GitOps

- Deploys em Kubernetes são feitos via **GitOps**: gerar os manifests e
  orientar o usuário a abrir PR no repositório de manifests (`<manifests-repo>`).
- **Nunca** aplicar manifests diretamente no cluster (`kubectl apply`).
- Manifests devem ser **YAML puro**: sem Helm, sem Kustomize, sem qualquer
  camada de templating adicional, salvo decisão explícita registrada em ADR.

## Imagens de container

- Toda referência a imagem de container deve usar uma **tag imutável**
  (digest `sha256:…` ou tag semântica fixa como `1.2.3`).
- O uso de `latest` ou de tags mutáveis é proibido.

## Segredos e credenciais

- Segredos **nunca** devem aparecer em código, manifests ou arquivos de
  configuração versionados.
- Referenciar sempre o cofre da cloud: Azure Key Vault, AWS Secrets Manager,
  GCP Secret Manager ou equivalente, usando o placeholder `<secret-name>`.

## Decisões técnicas

- Toda decisão específica de uma aplicação deve ser registrada como ADR em
  `docs/adr/` do repositório da aplicação, usando o template em
  `~/.kiro/templates/adr/adr-template.md`.
