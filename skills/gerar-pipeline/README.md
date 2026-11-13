# Skill gerar-pipeline

## Para que serve

Gera o pipeline de CI/CD da aplicação na plataforma registrada em
`docs/deploy/contexto.md`: GitHub Actions, Azure DevOps Pipelines, Gitea
Actions, Bitbucket Pipelines, GitLab CI ou Jenkins. Cobre build, testes,
scan, imagem com tag imutável (quando há container), `plan` e `apply` da
IaC com aprovação e a entrega no destino (PR no `<manifests-repo>` para
AKS, atualização do service no ECS, publicação + invalidação de cache em
hospedagem estática).

## Entradas

- `docs/deploy/analise.md` e `docs/deploy/contexto.md` (obrigatórios).
- Opcional: ambientes, regras de aprovação, templates do time.

## Saída

- Arquivos de pipeline no caminho da plataforma (ou proposta em
  `docs/deploy/pipeline.proposto/` se já existir pipeline).
- `docs/deploy/pipeline.md` com a configuração necessária na plataforma
  (identidade federada, environments, secrets só por nome, runners).

## Regras principais

- Autenticação na cloud por OIDC/federação, sem chave estática.
- Segredos só por referência; permissões mínimas do token do pipeline.
- Actions de terceiros fixadas por SHA; imagens por versão fixa.
- Nunca dispara pipeline nem cria secrets na plataforma.

## Exemplo de uso

```
/gerar-pipeline
```

```
/gerar-pipeline Plataforma: Azure DevOps, aprovação em prd pelo environment <environment-prd>.
```
