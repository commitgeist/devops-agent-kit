# References de pipeline

Templates e exemplos de pipeline **aprovados pelo time**, um subdiretório
por plataforma. O agente `pipeliner` parte daqui em vez de escrever do zero,
e o `reviewer` compara pipelines existentes com estes padrões.

```
pipeline/
├── github-actions/        # ex.: workflow reutilizável de build, deploy-ecs.yml
├── azure-devops/          # ex.: templates de stage/job, variable groups esperados
├── gitea-actions/
├── bitbucket/
├── gitlab-ci/
└── jenkins/
```

Para cada arquivo, inclua no topo um comentário com:

- O que o template faz e quando usar.
- Parâmetros de entrada e saídas.
- Pré-requisitos na plataforma (identidade federada, environments,
  secrets esperados só por nome).

Se o time usa templates num repositório central, em vez de copiar o
conteúdo, crie aqui um `.md` apontando para `<repositorio-de-templates>` e
a forma de consumo (`uses:`, `template:`, `include:`, shared library).

Ao adicionar, atualize o índice em `references/README.md`.
