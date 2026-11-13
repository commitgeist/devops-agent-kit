---
name: analisar-repo
description: Analisa o repositório de uma aplicação e gera docs/deploy/analise.md em formato fixo (stack, build, porta, healthcheck, variáveis, dependências, riscos, destino AKS ou ECS e perguntas abertas). Use quando for preparar o deploy de uma aplicação recebida de outro time.
---

# Skill: analisar-repo

Você vai analisar o repositório da aplicação aberto no workspace e gerar o
arquivo `docs/deploy/analise.md` **dentro desse repositório**, sempre no
formato fixo descrito abaixo.

Contexto adicional informado pelo usuário (pode estar vazio):
$ARGUMENTS

## Regras inegociáveis

1. **Só leitura no código da aplicação.** O único arquivo que você pode criar
   ou alterar é `docs/deploy/analise.md`. Não edite código, Dockerfile,
   pipeline, `.env` nem nada fora de `docs/deploy/`.
2. **Não inventar.** Toda afirmação precisa ter evidência no repositório
   (arquivo e, quando fizer sentido, linha). O que não encontrar vira
   **pergunta aberta**, nunca suposição apresentada como fato.
3. Informação dada pelo usuário ou pelo time de dev que **não** aparece no
   código (exemplo: "a app usa Redis") deve ser registrada como
   "informado pelo time, não encontrado no código" e gerar pergunta aberta.
4. Nunca copie valores de segredos para a análise. Registre apenas o **nome**
   da variável e onde ela aparece.
5. Não execute build, testes, containers nem comandos que alterem o ambiente.
6. Não use nomes reais de cliente, servidor ou pessoa em exemplos: use
   placeholders no formato `<placeholder>`.

## Roteiro de investigação

Siga esta ordem e anote a evidência de cada achado:

1. **Visão geral:** `README*`, `docs/`, estrutura de pastas, monorepo ou não.
2. **Stack e runtime:** manifestos de dependência (`package.json`,
   `pom.xml`, `build.gradle*`, `*.csproj`, `go.mod`, `requirements*.txt`,
   `pyproject.toml`, `Gemfile`, `composer.json`), arquivos de versão
   (`.nvmrc`, `.node-version`, `.python-version`, `.tool-versions`,
   `global.json`, `<java.version>` no pom) e `engines`.
3. **Build e execução:** scripts (`scripts` do package.json, `Makefile`,
   `mvnw`, `gradlew`, `Procfile`), ponto de entrada da aplicação.
4. **Porta e healthcheck:** procure `listen(`, `PORT`, `server.port`,
   `ASPNETCORE_URLS`, `EXPOSE`, rotas como `/health`, `/healthz`, `/ready`,
   `/actuator/health`, `/status`. Se não achar, escreva "não encontrado".
5. **Variáveis de ambiente:** `process.env`, `os.environ`, `os.Getenv`,
   `System.getenv`, `Environment.GetEnvironmentVariable`, `@Value`,
   `appsettings*.json`, `application*.yml`, `.env.example`,
   `docker-compose*`. Classifique cada uma como **config** ou **segredo**
   (senhas, tokens, chaves, connection strings com credencial, certificados).
6. **Dependências externas:** drivers e clientes de banco, fila, cache,
   storage, e-mail e APIs de terceiros. Registre o arquivo onde aparecem.
7. **Arquivos de entrega existentes:** `Dockerfile*`, `.dockerignore`,
   `.gitignore`, `.env.example`, pipelines (`.github/workflows/`,
   `azure-pipelines*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`,
   `bitbucket-pipelines.yml`), manifests ou Terraform já existentes.
8. **Riscos:** segredos versionados, `.env` commitado, dependências sem
   versão fixa, estado em disco local, sessões em memória, jobs agendados
   dentro da app, uploads em disco, migrações de banco na inicialização,
   portas privilegiadas, execução como root.
9. **Destino:** se o usuário informou AKS ou ECS, use o informado. Caso
   contrário, recomende com justificativa baseada nos achados e nas
   references carregadas. Se não houver base suficiente, recomende e marque
   a decisão como pergunta aberta.

## Formato fixo de `docs/deploy/analise.md`

Use exatamente estes títulos, nesta ordem. Não remova seções: quando não
houver conteúdo, escreva "não encontrado" e crie a pergunta correspondente.

```markdown
# Análise de deploy: <nome-da-aplicacao>

> Gerado pela skill analisar-repo em <data>. Commit analisado: <hash ou "não identificado">.

## 1. Resumo da aplicação

<o que a aplicação faz, tipo (API, worker, front-end, job), em 3 a 5 linhas>

## 2. Stack e versão do runtime

| Item | Valor | Evidência |
|------|-------|-----------|
| Linguagem | <linguagem> | <arquivo> |
| Runtime e versão | <runtime e versão> | <arquivo> |
| Framework | <framework e versão> | <arquivo> |
| Gerenciador de dependências | <ferramenta> | <arquivo> |

## 3. Como builda e como roda

| Etapa | Comando | Evidência |
|-------|---------|-----------|
| Instalar dependências | `<comando>` | <arquivo> |
| Build | `<comando>` | <arquivo> |
| Testes | `<comando>` | <arquivo> |
| Executar | `<comando>` | <arquivo> |

## 4. Porta exposta e healthcheck

- Porta: <porta ou "não encontrado"> (evidência: <arquivo:linha>)
- Healthcheck: <método e caminho ou "não encontrado"> (evidência: <arquivo:linha>)
- Readiness separado do liveness: <sim, não ou "não encontrado">

## 5. Variáveis de ambiente

### Configuração

| Variável | Uso | Obrigatória | Valor padrão | Evidência |
|----------|-----|-------------|--------------|-----------|
| <NOME> | <para que serve> | <sim ou não> | <padrão ou "nenhum"> | <arquivo:linha> |

### Segredos

| Variável | Uso | Evidência |
|----------|-----|-----------|
| <NOME> | <para que serve> | <arquivo:linha> |

## 6. Dependências externas

| Tipo | Tecnologia | Variáveis relacionadas | Onde aparece no código |
|------|-----------|------------------------|------------------------|
| <banco, fila, cache, API, storage> | <tecnologia> | <variáveis> | <arquivo:linha> |

## 7. Arquivos existentes relevantes

| Arquivo | Existe | Observação |
|---------|--------|------------|
| Dockerfile | <sim ou não> | <observação> |
| .dockerignore | <sim ou não> | <observação> |
| Pipeline de CI/CD | <sim ou não> | <caminho e observação> |
| .env.example | <sim ou não> | <observação> |
| .gitignore | <sim ou não> | <observação> |

## 8. Riscos e pontos de atenção

- <risco> (evidência: <arquivo:linha>; impacto: <impacto>)

## 9. Recomendação de destino

- Destino: <AKS ou ECS>
- Origem da decisão: <informado pelo usuário ou recomendação da análise>
- Justificativa: <motivos baseados nos achados>

## 10. Perguntas abertas para o time de dev

1. <pergunta objetiva, com o motivo e o arquivo que gerou a dúvida>
```

## Ao terminar

1. Confirme que o arquivo foi gravado em `docs/deploy/analise.md`.
2. Mostre no chat um resumo curto: stack, porta, healthcheck, quantidade de
   configs e segredos, destino recomendado e número de perguntas abertas.
3. Não proponha Dockerfile nem manifests nesta etapa.
