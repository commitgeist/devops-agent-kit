# Skill gerar-dockerfile

## Para que serve

Gera o `Dockerfile` multi-stage e o `.dockerignore` da aplicação, partindo
do levantamento em `docs/deploy/analise.md`. Quando o repositório já tem um
Dockerfile, a skill revisa o existente e propõe melhorias em arquivos
separados, sem sobrescrever.

## Quando usar

- Depois da `analisar-repo`, quando o repositório ainda não tem Dockerfile.
- Quando o repositório já tem um Dockerfile e você quer saber se ele atende
  aos padrões do time.
- Quando a análise mudou (novo runtime, nova porta) e o Dockerfile precisa
  acompanhar.

## Entradas

- `docs/deploy/analise.md` (obrigatório).
- Opcional, como texto após o nome da skill: restrições como imagem base
  homologada, registry privado de pacotes, porta desejada.

## Saída

Sem Dockerfile existente:

- `Dockerfile` e `.dockerignore` na raiz da aplicação.
- `docs/deploy/dockerfile-notas.md` com decisões, comandos e pendências.

Com Dockerfile existente:

- `docs/deploy/dockerfile-revisao.md` com a tabela de problemas e propostas.
- `docs/deploy/Dockerfile.proposto` e, se for o caso,
  `docs/deploy/.dockerignore.proposto`.

## Padrões aplicados

- Multi-stage.
- Imagem base com tag fixa, nunca `latest`.
- Usuário não root com UID e GID numéricos.
- `HEALTHCHECK` quando a análise tiver endpoint.
- Nenhum segredo em `ARG`, `ENV` ou camada da imagem.

## Exemplo de uso

```
/gerar-dockerfile
```

## Exemplo de uso real

O repositório já tem um Dockerfile antigo, com imagem `latest`, rodando como
root e copiando o `.env` para dentro da imagem. A empresa exige imagem base
do registry interno.

```
/gerar-dockerfile Já existe Dockerfile, não sobrescreva. A imagem base precisa vir de <registry-interno>/<runtime>:<versao>. O build baixa pacotes de um feed privado que exige token.
```

Resultado esperado: `docs/deploy/dockerfile-revisao.md` aponta `latest`,
root e `.env` copiado como prioridade alta; `docs/deploy/Dockerfile.proposto`
usa a imagem do registry interno com tag fixa, `USER` não root e
`RUN --mount=type=secret` para o token do feed; o Dockerfile original
permanece intacto.
