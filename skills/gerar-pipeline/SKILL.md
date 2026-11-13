---
name: gerar-pipeline
description: Gera o pipeline de CI/CD da aplicação na plataforma do contexto de entrega (GitHub Actions, Azure DevOps Pipelines, Gitea Actions, Bitbucket Pipelines, GitLab CI ou Jenkins), a partir de docs/deploy/analise.md e docs/deploy/contexto.md. Build, testes, scan, imagem com tag imutável quando houver container, plan/apply da IaC com aprovação e publicação do destino. Autenticação na cloud por federação (OIDC), sem chave estática. Se já existir pipeline, revisa e propõe em vez de sobrescrever.
---

# Skill: gerar-pipeline

Você vai gerar o pipeline de CI/CD da aplicação do workspace.

Contexto adicional informado pelo usuário (pode estar vazio):
$ARGUMENTS

## Pré-requisito

1. Leia `docs/deploy/analise.md` e `docs/deploy/contexto.md`. Se algum não
   existir, **pare** e oriente rodar antes o `analyzer`.
2. Da análise vêm: comandos de build e teste, versão do runtime, diretório
   do artefato, se exige container, destino. Do contexto vêm: plataforma de
   CI/CD, runners, autenticação na cloud, aprovação para produção,
   registry, cofre, ferramenta de IaC, ambientes e templates do time.
3. Plataforma de CI/CD `a definir`: pergunte e pare. Não escolha por conta
   própria.
4. Siga `checklist-producao.md`, `nomenclatura.md` e
   `guardrails-segredos.md`.
5. Use as references confirmadas (lista recebida ou registrada em
   `docs/deploy/contexto.md`), em especial `pipeline/<plataforma>/`: parta
   dos templates do time em vez de escrever do zero.

## Onde gerar

| Plataforma | Arquivo |
|------------|---------|
| GitHub Actions | `.github/workflows/<aplicacao>-ci.yml` e `.github/workflows/<aplicacao>-cd.yml` |
| Gitea Actions | `.gitea/workflows/<aplicacao>-ci.yml` e `.gitea/workflows/<aplicacao>-cd.yml` |
| Azure DevOps Pipelines | `azure-pipelines.yml` (ou `.azuredevops/<aplicacao>.yml` se o contexto indicar) |
| Bitbucket Pipelines | `bitbucket-pipelines.yml` |
| GitLab CI | `.gitlab-ci.yml` |
| Jenkins | `Jenkinsfile` |

Se o contexto apontar **templates reutilizáveis do time**, consuma-os
(`uses:` de workflow reutilizável, `template:` do Azure DevOps, `include:`
do GitLab, shared library do Jenkins) em vez de reescrever os passos.

## Estágios

Gere só o que se aplica ao destino da análise:

1. **CI (pull request e branch principal):** checkout, setup do runtime na
   versão da análise, cache de dependências, instalação travada pelo lock
   (`npm ci`, `pip install -r` com hashes, `mvn -B` etc.), lint e testes
   quando existirem, build.
2. **Segurança:** se existir relatório do `secops` em `docs/security/`,
   implemente os controles propostos nele. Senão, aplique o "mínimo
   recomendado" de `seguranca/ferramentas.md` com as ferramentas do
   contexto (ou as nativas da plataforma): segredos, SCA, IaC, imagem e
   SAST, com saída SARIF quando a plataforma suportar.
3. **Artefato:**
   - Com container: build da imagem e push para o registry do contexto
     com **tag imutável** (SHA do commit ou versão semântica), nunca
     `latest`. Registrar o digest como saída do job.
   - Sem container: publicar o diretório do artefato como artefato do
     pipeline.
4. **IaC:** em pull request, `plan`/`preview`/`what-if` com o resultado
   anexado; na branch principal, `apply`/`up`/`deploy` **só após
   aprovação** (environment protegido, approval gate ou etapa manual, como
   indicado no contexto). Um job por ambiente, promovendo o mesmo artefato.
5. **Entrega no destino:**
   - AKS/GitOps: atualizar a tag ou o digest da imagem no
     `<manifests-repo>` **por pull request** (nunca `kubectl apply`).
   - ECS: nova revisão de task definition com o digest da imagem e
     atualização do service via IaC ou ação oficial de deploy, aguardando
     estabilidade.
   - Hospedagem estática: envio do artefato com headers de cache corretos
     (HTML com `no-cache`, assets com hash como `immutable`), remoção de
     arquivos antigos e invalidação/purge da CDN só nos caminhos de HTML.
6. **Verificação pós-deploy:** chamada ao healthcheck da análise (ou status
   200 nas rotas principais, em site estático).

## Regras inegociáveis

- **Autenticação na cloud por federação** (OIDC no GitHub/Gitea/GitLab,
  service connection com workload identity federation no Azure DevOps,
  OIDC do Bitbucket). Chave de acesso estática só com exceção registrada em
  ADR, e mesmo assim por referência a secret da plataforma.
- **Segredos só por referência** (secrets do repositório, variable groups
  ligados ao cofre, environments). Nunca valor no YAML, nunca `echo` de
  segredo, nunca `set -x` em passo que manipula segredo.
- **Permissões mínimas** do token do pipeline (`permissions:` explícito no
  GitHub/Gitea, escopo mínimo nas demais).
- **Ações e imagens fixadas:** actions de terceiros por SHA completo do
  commit (com comentário da versão), imagens de job por versão fixa.
  Quando não souber o SHA, use `<sha-da-versao-x.y.z>` como placeholder e
  registre como pendência.
- **Concorrência:** um deploy por ambiente por vez, sem cancelar deploy de
  produção em andamento.
- **Nada de deploy em pull request de fork.**
- Não alterar código da aplicação.

## Quando já existe pipeline

**Não sobrescreva.** Gere `docs/deploy/pipeline-revisao.md` com a tabela
`item | situação atual | problema | proposta | prioridade` cobrindo as
regras acima e a versão proposta em `docs/deploy/pipeline.proposto/`,
mantendo os nomes de arquivo da plataforma. Só substitua com pedido
explícito do usuário na mensagem atual.

## Documentação gerada

Gere `docs/deploy/pipeline.md` com:

1. Arquivos gerados e o gatilho de cada workflow/pipeline.
2. Configuração que precisa existir na plataforma: identidade federada e
   suas permissões na cloud, environments e aprovadores, secrets e
   variáveis (só **nomes**), runners ou pools.
3. Placeholders pendentes (incluindo SHAs de actions).
4. Itens do `checklist-producao.md` cobertos pelo pipeline.

## Ao terminar

Mostre no chat: plataforma, arquivos gerados ou propostos, configuração
necessária na plataforma, segredos esperados (só nomes) e pendências.
