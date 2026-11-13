Avalie a postura de segurança deste repositório e proponha os estágios de
segurança da pipeline.

Foco ou contexto adicional: $ARGUMENTS

- Cubra segredos versionados (inclusive no histórico do git), dependências
  vulneráveis ou desatualizadas, IaC, Dockerfile e pipeline existente, com
  evidência `arquivo:linha` e severidade.
- Proponha estágios de segurança (segredos, SCA, SAST, IaC, imagem) para a
  plataforma de CI/CD definida em `docs/deploy/contexto.md`, com ferramenta,
  ponto do fluxo e critério de bloqueio.
- Nunca copie valor de segredo para o relatório.
- Só leitura: não corrija nada. Escreva apenas o relatório em
  `docs/security/`.
