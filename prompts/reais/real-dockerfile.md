Use o containerizer para gerar o Dockerfile e o .dockerignore desta
aplicação com base em docs/deploy/analise.md. Se o repositório já tiver
Dockerfile, revise em vez de sobrescrever.

Contexto (registry interno, feed privado, problemas já percebidos):
$ARGUMENTS

Restrições:
- Imagem base do registry `<registry-interno>`, com tag fixa. Nada de latest.
- Token de feed privado nunca em ARG, ENV ou camada da imagem: use secret de
  build e documente o comando `docker build` em docs/deploy/dockerfile-notas.md.
- Usuário não root, porta alta, CMD/ENTRYPOINT em forma exec. HEALTHCHECK
  só se a análise tiver endpoint de saúde.
- Dockerfile existente: não sobrescreva. Gere a tabela de problemas em
  docs/deploy/dockerfile-revisao.md e a versão corrigida em
  docs/deploy/Dockerfile.proposto. Segredo versionado no repositório é
  prioridade alta: me avise sem copiar o valor.
- Não gere IaC nem pipeline.
