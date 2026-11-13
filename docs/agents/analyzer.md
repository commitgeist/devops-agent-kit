# Agente analyzer

Arquivos: `agents/analyzer.json` e `agents/instrucoes/analyzer.md`.

## Papel

Fazer o levantamento técnico do repositório da aplicação e gravar
`docs/deploy/analise.md` no formato fixo da skill `analisar-repo`. É a
primeira etapa do fluxo e a entrada dos outros agentes.

## Skills que usa

- `analisar-repo`

Resources carregados: steering global e `references/checklist-producao.md`
(para enriquecer a seção de riscos).

## O que pode fazer

- Ler qualquer arquivo do workspace (`read`, `glob`, `grep`, `code`).
- Escrever em `docs/deploy/` (gravação aprovada automaticamente por
  `toolsSettings.write.allowedPaths`).

## O que não pode fazer

- Alterar código, Dockerfile, pipeline ou qualquer arquivo fora de
  `docs/deploy/`. Escritas fora dessa pasta não são aprovadas
  automaticamente e as instruções do agente mandam recusar.
- Rodar shell (não tem a ferramenta `shell`).
- Gerar Dockerfile, manifests ou Terraform.
- Inventar informação: o que não encontra vira pergunta aberta.

## Exemplo de uso

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent analyzer
```

```
Analise este repositório.
```

## Exemplo de uso real

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent analyzer
```

```
@real-analisar-sem-env-example O time não mandou .env.example e disse que a aplicação "só precisa da connection string". Destino ainda indefinido.
```

O agente levanta todas as variáveis lidas pelo código, separa config de
segredo, marca `.env.example` como inexistente, compara com a afirmação do
time e transforma as divergências em perguntas abertas.
