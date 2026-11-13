---
name: analisar-repo
description: Analisa o repositório de uma aplicação e gera docs/deploy/analise.md em formato fixo (stack, build, porta, healthcheck, variáveis, dependências, riscos, perfil de execução, destino recomendado pela boa prática e perguntas abertas). Use quando for preparar o deploy de uma aplicação recebida de outro time.
---

# Skill: analisar-repo

Você vai analisar o repositório da aplicação aberto no workspace e gerar o
arquivo `docs/deploy/analise.md` **dentro desse repositório**, sempre no
formato fixo descrito abaixo.

Contexto adicional informado pelo usuário (pode estar vazio):
$ARGUMENTS

## Regras inegociáveis

1. **Só leitura no código da aplicação.** Os únicos arquivos que você pode
   criar ou alterar são `docs/deploy/analise.md` e `docs/deploy/contexto.md`.
   Não edite código, Dockerfile, pipeline, `.env` nem nada fora de
   `docs/deploy/`.
2. **Não inventar.** Toda afirmação precisa ter evidência no repositório
   (arquivo e, quando fizer sentido, linha). O que não encontrar vira
   **pergunta aberta**, nunca suposição apresentada como fato.
3. Informação dada pelo usuário ou pelo time de dev que **não** aparece no
   código (exemplo: "a app usa Redis") deve ser registrada como
   "informado pelo time, não encontrado no código" e gerar pergunta aberta.
4. **Nunca leia arquivos de segredo** (`.env`, `.env.*` exceto exemplos,
   chaves, certificados, `*.tfvars`, `*.tfstate`, credenciais de
   ferramentas), conforme `guardrails-segredos.md`. Levante nomes de
   variáveis pelo código e pelos arquivos de exemplo. Para registrar o risco
   de um `.env` versionado, basta a listagem de nomes de arquivo. Se uma
   leitura for bloqueada, não tente outro caminho para o mesmo conteúdo.
   Nunca copie valores de segredos para a análise: registre só o **nome**
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
   `docker-compose*` (nunca `.env` real). Classifique cada uma como **config** ou **segredo**
   (senhas, tokens, chaves, connection strings com credencial, certificados).
6. **Dependências externas:** drivers e clientes de banco, fila, cache,
   storage, e-mail e APIs de terceiros. Registre o arquivo onde aparecem.
7. **Arquivos de entrega existentes:** `Dockerfile*`, `.dockerignore`,
   `.gitignore`, `.env.example`, pipelines (`.github/workflows/`,
   `.gitea/workflows/`, `azure-pipelines*.yml`, `.azuredevops/`,
   `.gitlab-ci.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`), IaC
   (`*.tf`, `*.bicep`, `Pulumi.yaml`, `cdk.json`, templates
   CloudFormation), manifests já existentes.
8. **Contexto de entrega:** monte ou atualize `docs/deploy/contexto.md` a
   partir do template `~/.kiro/templates/deploy/contexto-entrega.md`. Para
   cada item use, nesta ordem de prioridade:
   1. o que o usuário informou nesta conversa;
   2. o que já estiver em `docs/deploy/contexto.md` (nunca apague um valor
      `informado pelo usuário` sem pedido explícito);
   3. evidência no repositório (pasta de pipeline, arquivos de IaC, versões
      fixadas em `.terraform-version`, `.tool-versions`, `required_version`;
      não leia `.git/config`, cuja URL de remote pode conter token);
   4. o padrão em `padroes-do-time.md`;
   5. `a definir`.
   Itens `a definir` que impedem gerar IaC ou pipeline (cloud, ferramenta
   de IaC, plataforma de CI/CD) viram pergunta aberta.
9. **Riscos:** segredos versionados, `.env` commitado, dependências sem
   versão fixa, estado em disco local, sessões em memória, jobs agendados
   dentro da app, uploads em disco, migrações de banco na inicialização,
   portas privilegiadas, execução como root.
10. **Perfil de execução:** antes de pensar em plataforma, classifique o que
   a aplicação **precisa em produção**, com evidência:
   - Precisa de um processo rodando continuamente? Ou o build gera só
     arquivos estáticos (HTML, JS, CSS) que qualquer servidor ou CDN
     entrega?
   - Tipo de carga: site estático/SPA, front-end com renderização no
     servidor, API HTTP, worker de fila, job agendado, função orientada a
     evento, processamento em lote.
   - Estado (disco local, sessão em memória), conexões persistentes
     (WebSocket, gRPC), tempo de execução das requisições, padrão de tráfego
     (contínuo, em picos, esporádico), dependências de rede privada.
11. **Destino:** recomende a opção de **menor complexidade operacional que
   atende ao perfil**, seguindo as boas práticas atuais do provedor de cloud.
   Não parta das plataformas que o time já usa: elas são uma opção a ser
   avaliada, não a resposta padrão.
   - Se a aplicação não precisa de processo em execução, a recomendação não
     deve ser um orquestrador de containers. Container só faz sentido se o
     perfil exigir.
   - Se o usuário informou um destino, registre-o. Se a análise mostrar que
     ele não combina com o perfil (exemplo: orquestrador de containers para
     conteúdo estático), registre a divergência e a alternativa recomendada,
     e crie uma pergunta aberta. Não troque o destino por conta própria.
   - A cloud (AWS, Azure, GCP) vem do usuário ou de evidência no
     repositório. Se não houver nenhuma das duas, recomende por categoria
     de serviço e pergunte qual é a cloud.
   - Cite pelo menos uma alternativa descartada e explique por que ela foi
     descartada.
   - Se houver servidor MCP de documentação disponível (exemplo: docs do
     provedor de cloud ou da ferramenta de IaC), consulte-o para confirmar a
     boa prática atual e cite a fonte na justificativa. Sem MCP, use o
     conhecimento próprio e deixe claro que a recomendação não foi
     conferida em documentação.
   - Indique se o destino recomendado exige container (isso define se o
     `containerizer` deve rodar) e se já existe gerador de artefatos no kit
     para ele.

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

### Perfil de execução

| Item | Valor | Evidência |
|------|-------|-----------|
| Tipo de carga | <site estático, SSR, API, worker, job, função, lote> | <arquivo> |
| Processo em execução em produção | <sim ou não> | <arquivo> |
| Estado local / sessão | <sim, não ou "não encontrado"> | <arquivo> |
| Conexões persistentes | <sim, não ou "não encontrado"> | <arquivo> |
| Padrão de tráfego | <informado, inferido ou "não encontrado"> | <origem> |

### Decisão

- Destino recomendado: <serviço ou combinação de serviços na cloud>
- Cloud: <AWS, Azure, GCP ou "a definir">
- Exige container: <sim ou não>
- Gerador no kit: <AKS, ECS, hospedagem estática ou "não suportado pelo kit ainda">
- Destino informado pelo usuário: <destino ou "nenhum">; diverge da recomendação: <sim ou não>
- Justificativa: <por que esta é a opção mais simples que atende ao perfil>
- Alternativas descartadas: <opção: motivo>, <opção: motivo>

## 10. Perguntas abertas para o time de dev

1. <pergunta objetiva, com o motivo e o arquivo que gerou a dúvida>
```

## Ao terminar

1. Confirme que `docs/deploy/analise.md` e `docs/deploy/contexto.md` foram
   gravados.
2. Mostre no chat um resumo curto: stack, porta, healthcheck, quantidade de
   configs e segredos, tipo de carga, destino recomendado (com a indicação
   de se exige container), ferramentas de IaC e CI/CD (com a origem) e
   número de perguntas abertas.
3. Não proponha Dockerfile nem manifests nesta etapa.
