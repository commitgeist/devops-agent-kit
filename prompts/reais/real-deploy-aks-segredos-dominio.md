Use o deployer para gerar o deploy desta aplicação para AKS via GitOps, com
base em docs/deploy/analise.md.

Dados do ambiente:
$ARGUMENTS

Restrições:
- A aplicação precisa de 3 segredos, que já existem (ou vão existir) no Key
  Vault <key-vault-name>: <secret-1>, <secret-2> e <secret-3>. Use
  SecretProviderClass e nunca coloque valor de segredo em YAML.
- A aplicação será publicada no domínio <dominio>, com TLS. Gere o Ingress
  com ingressClassName <ingress-class> e o secret TLS <tls-secret-name>.
- Manifests em YAML puro, sem Helm e sem Kustomize, em deploy/aks/.
- Siga nomenclatura.md para nomes e labels; mantenha placeholders onde a
  reference ainda não estiver preenchida.
- Imagem com tag imutável, nunca latest.
- Em docs/deploy/deploy-aks.md, liste os 3 segredos esperados no cofre, os
  placeholders pendentes, o passo a passo do PR no <manifests-repo> e o
  checklist de produção.
- Não rode kubectl.
