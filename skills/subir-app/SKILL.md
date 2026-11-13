---
name: subir-app
description: Fluxo completo para preparar o deploy de uma aplicação recebida de outro time. Confirma contexto de entrega e references do time, delega a análise ao analyzer, pede confirmação e delega containerizer, deployer e pipeliner conforme o destino. Use quando o pedido for subir, publicar ou preparar o deploy de uma aplicação. Requer as ferramentas subagent_<agente> (agente devops).
---

# Skill: subir-app

Você coordena a preparação do deploy. Nesta skill você **não** analisa código
a fundo, **não** gera artefatos e **não** aplica nada: delega, apresenta
resultados e pede confirmação.

Contexto informado pelo usuário (pode estar vazio):
$ARGUMENTS

Subagentes não conseguem perguntar nada ao usuário: **toda pergunta é sua**,
e as respostas são repassadas no prompt da delegação.

**Como delegar:** cada especialista é uma ferramenta `subagent_<agente>`
(`subagent_analyzer`, `subagent_containerizer`, `subagent_deployer`,
`subagent_pipeliner`) com os campos `explanation` (uma linha) e `prompt`.
O `prompt` precisa ser autossuficiente: skill a usar, caminho do
workspace, contexto confirmado, references confirmadas e respostas do
usuário. Para rodar em paralelo, chame as ferramentas na mesma resposta.

## Etapa 0: contexto de entrega e references do time

Objetivo: saber cloud, ferramenta de IaC, plataforma de CI/CD e quais
references do time valem para esta aplicação **antes** de gerar qualquer
coisa, perguntando uma vez só.

1. Se `docs/deploy/contexto.md` existir, leia-o.
2. Leia o índice `~/.kiro/references/README.md` e selecione as references
   que se aplicam (exemplo: template de pipeline da plataforma, módulo de
   IaC da cloud, padrão de nomes). Leia só as selecionadas.
3. Levante o que der sem perguntar: o que o usuário já escreveu, evidências
   por listagem de arquivos (`.github/workflows/`, `.gitea/workflows/`,
   `azure-pipelines*.yml`, `.azuredevops/`, `bitbucket-pipelines.yml`,
   `.gitlab-ci.yml`, `Jenkinsfile`, `*.tf`, `*.bicep`, `Pulumi.yaml`,
   `cdk.json`) e `padroes-do-time.md`.
4. Pergunte só o que **bloqueia** a geração: cloud, ferramenta de IaC,
   plataforma de CI/CD e as references aplicáveis. O resto (autenticação
   do CI, aprovação, registry, cofre) vem de `padroes-do-time.md` ou da
   evidência; se faltar, vira pergunta aberta na análise, sem travar o
   fluxo. Faça **uma única** pergunta, já preenchida, para o usuário só
   confirmar ou corrigir:

   ```
   Antes de analisar, confirme (responda só o que mudar):
   1. Cloud: <valor> (detectado | padrão do time | a definir)
   2. IaC: <valor>
   3. CI/CD: <valor>
   References do time que vou seguir:
   - [x] <reference> (<por que se aplica>)
   - [ ] <reference> (possível, confirme)
   ```

   Nunca peça tokens, senhas ou chaves.
5. **Pare e espere a resposta.** O que ficar sem resposta vira `a definir`
   e pergunta aberta na análise.

Se o contexto já estiver completo e as references já estiverem registradas
em `docs/deploy/contexto.md`, pule a pergunta.

## Etapa 1: análise

Delegue **apenas** ao `analyzer` (`subagent_analyzer`). Prompt mínimo:

```
Use a skill analisar-repo no workspace <caminho> para gerar
docs/deploy/analise.md e docs/deploy/contexto.md.
Contexto de entrega confirmado: <cloud, IaC, CI/CD, origem de cada um>.
References confirmadas: <lista>.
Informado pelo time de dev: <texto>.
```

## Etapa 2: confirmação (obrigatória)

1. Leia `docs/deploy/analise.md` e `docs/deploy/contexto.md`.
2. Mostre: stack e runtime, porta, healthcheck, configs e segredos (só
   nomes), dependências externas, riscos, contexto de entrega, references
   que serão seguidas, tipo de carga, destino recomendado, alternativas
   descartadas, se exige container e **todas** as perguntas abertas. Se o
   destino informado divergir da recomendação, destaque a divergência.
3. Pergunte se pode seguir, se o destino está correto e se há respostas
   para as perguntas abertas.
4. **Pare e espere.** Sem confirmação explícita, o fluxo não continua.
5. Correção relevante (destino, ferramenta, reference, dependência): delegue
   de novo ao `analyzer` antes de seguir.

## Etapa 3: container, IaC e pipeline

Chame na **mesma** resposta (em paralelo) só os que se aplicam:

| Agente | Quando |
|--------|--------|
| `containerizer` | O destino exige container |
| `deployer` | Há gerador no kit para o destino e a ferramenta de IaC está definida |
| `pipeliner` | A plataforma de CI/CD está definida |

Destino sem gerador no kit: não force um destino suportado. Entregue a
recomendação como próximo passo humano e sugira ADR (skill
`registrar-adr`). O `pipeliner` ainda pode gerar o CI.

Em cada prompt de delegação repasse: destino confirmado, respostas do
usuário e **references confirmadas** (os subagentes usam só essas; se
acharem outra aplicável, devolvem como sugestão).

## Etapa 4: fechamento

Apresente:

1. Arquivos gerados ou propostos por agente.
2. References usadas e sugestões de references novas vindas dos agentes
   (pergunte se devem ser usadas numa próxima rodada).
3. Segredos esperados no cofre ou na plataforma de CI (só nomes).
4. Configuração necessária na plataforma de CI/CD.
5. Placeholders e itens pendentes do checklist.
6. Perguntas ainda abertas para o time de dev.
7. Decisões que merecem ADR (ofereça registrar com `registrar-adr`).
8. Próximo passo humano (PR no `<manifests-repo>` para AKS; PR do pipeline
   e da IaC, com `plan` e `apply` pelo pipeline).

## Proibido

- Pular a confirmação da Etapa 2.
- Delegar geração antes de existir `docs/deploy/analise.md`.
- Inventar respostas, escolher ferramenta não confirmada ou usar reference
  não confirmada.
- Encaixar a aplicação num destino só porque há gerador para ele.
