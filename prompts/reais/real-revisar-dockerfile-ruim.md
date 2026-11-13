Use o containerizer para revisar o Dockerfile que já existe neste
repositório. Ele foi feito pelo time de dev e tem problemas conhecidos.

Problemas que já percebi:
$ARGUMENTS

Restrições:
- Não sobrescreva o Dockerfile original.
- Gere docs/deploy/dockerfile-revisao.md com uma tabela item, situação atual,
  problema, proposta e prioridade, cobrindo pelo menos: tag da imagem base,
  multi-stage, usuário, segredos ou .env copiados para a imagem, cache de
  camadas, .dockerignore, healthcheck, forma exec do CMD ou ENTRYPOINT e
  tamanho da imagem.
- Gere a versão corrigida em docs/deploy/Dockerfile.proposto e, se preciso,
  docs/deploy/.dockerignore.proposto.
- Se encontrar segredo versionado no repositório, registre como prioridade
  alta e me avise, sem copiar o valor.
