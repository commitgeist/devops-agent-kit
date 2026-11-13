# Agente subir-app

Arquivos: `agents/subir-app.json` e `agents/instrucoes/subir-app.md`.

## Papel

Orquestrador do fluxo de subir uma aplicação. Não analisa código a fundo,
não escreve arquivos e não aplica nada: delega para os outros agentes,
apresenta os resultados e pede sua confirmação entre as etapas.

Fluxo:

1. Delega ao `analyzer`, que gera `docs/deploy/analise.md`.
2. Mostra o resumo da análise e as perguntas abertas, e **espera sua
   confirmação**.
3. Delega `containerizer` e `deployer` na mesma chamada, em paralelo.
4. Consolida arquivos gerados, segredos esperados no cofre, placeholders e
   pendências do checklist.

## Skills que usa

Nenhuma diretamente. As skills são usadas pelos agentes delegados.

Resources carregados: steering global e `references/checklist-producao.md`.

## O que pode fazer

- Ler arquivos do workspace (`read`, `glob`, `grep`).
- Delegar para `analyzer`, `containerizer` e `deployer` com a ferramenta
  `subagent` (configurada em `toolsSettings.crew.availableAgents`).
- O `analyzer` está em `trustedAgents` e é acionado sem confirmação extra;
  `containerizer` e `deployer` pedem aprovação ao serem acionados, porque
  escrevem arquivos.

## O que não pode fazer

- Escrever arquivos (não tem a ferramenta `write`).
- Rodar shell, `kubectl`, `terraform` ou qualquer deploy.
- Pular a confirmação depois da análise.
- Inventar respostas para as perguntas abertas.

## Exemplo de uso

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent subir-app
```

```
Prepare o deploy desta aplicação.
```

## Exemplo de uso real

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent subir-app
```

```
@real-fluxo-completo Destino AKS. O dev disse que a app usa Redis como cache e Postgres. Não mandaram .env.example.
```

O agente roda o `analyzer`, mostra que o Postgres aparece no código mas o
Redis não, lista as variáveis encontradas e pergunta se pode seguir. Depois
da sua resposta (por exemplo: "Redis não é usado, siga para AKS"), roda
`containerizer` e `deployer` em paralelo e entrega o resumo final.
