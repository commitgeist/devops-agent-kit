Use o containerizer para gerar só o Dockerfile e o .dockerignore desta
aplicação, com base em docs/deploy/analise.md.

Contexto:
$ARGUMENTS

Restrições:
- A imagem base precisa vir do registry interno <registry-interno>, com tag
  fixa. Nada de latest.
- O build baixa dependências de um feed privado que exige token. O token não
  pode ficar em ARG, ENV nem em camada da imagem: use secret de build e
  documente o comando docker build em docs/deploy/dockerfile-notas.md.
- A aplicação precisa rodar como usuário não root e com porta alta.
- Inclua HEALTHCHECK somente se a análise tiver endpoint de saúde.
- Não gere manifests nem Terraform.
