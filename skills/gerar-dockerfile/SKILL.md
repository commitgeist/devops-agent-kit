---
name: gerar-dockerfile
description: Gera Dockerfile multi-stage e .dockerignore a partir de docs/deploy/analise.md, com imagem base de tag fixa, usuário não root, healthcheck e sem segredos no build. Se já existir Dockerfile, revisa e propõe melhorias em vez de sobrescrever.
---

# Skill: gerar-dockerfile

Você vai containerizar a aplicação do workspace com base em
`docs/deploy/analise.md`.

Contexto adicional informado pelo usuário (pode estar vazio):
$ARGUMENTS

## Pré-requisito

1. Leia `docs/deploy/analise.md`. Se não existir, **pare** e oriente o
   usuário a rodar antes a skill `analisar-repo` (ou o agente `analyzer`).
2. Use a análise como fonte principal. Se precisar confirmar algo no código
   (exemplo: nome do artefato gerado no build), leia o arquivo, mas não
   altere código da aplicação.
3. Se a seção 9 da análise indicar que o destino **não exige container**
   (exemplo: hospedagem estática), **pare** sem gerar arquivos e informe
   isso, salvo pedido explícito do usuário na mensagem atual.
4. Se a análise tiver perguntas abertas que impedem o Dockerfile (runtime
   desconhecido, comando de execução desconhecido), não invente: liste o
   bloqueio e pare.

## Padrões obrigatórios

- **Multi-stage:** estágio de build com SDK e ferramentas, estágio final só
  com o runtime e o artefato.
- **Imagem base com tag fixa:** versão explícita compatível com a da
  análise (exemplo: `<runtime>:<versao>-<variante>`). Nunca `latest`, nunca
  tag sem versão. Se quiser fixar por digest, use `<imagem>@sha256:<digest>`
  como placeholder e avise que o digest precisa ser preenchido.
- **Usuário não root** no estágio final, com UID e GID numéricos
  (`USER <uid>:<gid>`), e arquivos da aplicação com dono adequado.
- **Porta:** `EXPOSE` com a porta da análise. Se a porta for menor que 1024,
  aponte o risco e proponha porta alta configurável.
- **Healthcheck:** incluir `HEALTHCHECK` só quando a análise tiver endpoint.
  Use uma ferramenta que exista na imagem final; se não houver `curl` ou
  `wget`, explique a alternativa em vez de instalar pacotes sem necessidade.
  Lembre que em AKS quem manda são as probes do manifest; o `HEALTHCHECK`
  serve para execução local e ECS.
- **Sem segredos no build:** nada de `ARG` ou `ENV` com senha, token ou
  chave. Se o build precisar de credencial (registry privado de pacotes),
  use `RUN --mount=type=secret,id=<id>` e documente o comando de build.
- **Cache de camadas:** copiar primeiro os manifestos de dependência,
  instalar, depois copiar o código.
- **Imagem enxuta:** remover caches de gerenciadores de pacote, não instalar
  ferramentas de depuração no estágio final.
- **Execução:** `ENTRYPOINT` ou `CMD` em forma exec (JSON). Garantir que o
  processo receba sinais (encerramento gracioso).
- Variáveis de **config** não ganham valor fixo no Dockerfile, a não ser
  padrões inofensivos (exemplo: porta). Elas vêm do deploy.

## `.dockerignore`

Gere ou revise com, no mínimo: `.git`, diretórios de dependências e build
locais, arquivos `.env*` (exceto `.env.example`), logs, artefatos de IDE,
`docs/`, `deploy/`, `Dockerfile*` e `.dockerignore`.

## Quando já existe Dockerfile

**Não sobrescreva.** Faça uma revisão:

1. Gere `docs/deploy/dockerfile-revisao.md` com uma tabela
   `item | situação atual | problema | proposta | prioridade (alta, média, baixa)`
   cobrindo todos os padrões obrigatórios acima.
2. Gere a versão proposta em `docs/deploy/Dockerfile.proposto` (e
   `docs/deploy/.dockerignore.proposto` se for o caso), para o usuário
   comparar com `diff`.
3. Só substitua o Dockerfile original se o usuário pedir explicitamente na
   mensagem atual.

## Quando não existe Dockerfile

Crie `Dockerfile` e `.dockerignore` na raiz do repositório (ou no caminho
da aplicação, em monorepo) e registre em `docs/deploy/dockerfile-notas.md`:
decisões tomadas, comando de build local
(`docker build -t <imagem>:<tag> .`), comando de execução local e pendências.

## Proibido

- Executar `docker push` ou publicar imagem em qualquer registry.
- Usar `latest`.
- Copiar `.env` ou qualquer segredo para a imagem.
- Alterar código da aplicação para "fazer caber" no container. Se for
  necessário, registre como pendência para o time de dev.

## Ao terminar

Mostre no chat: arquivos criados ou propostos, imagem base escolhida, porta,
healthcheck, usuário e a lista de pendências.
