# Skill analisar-repo

## Para que serve

Faz o levantamento técnico de um repositório de aplicação recebido de outro
time e grava o resultado em `docs/deploy/analise.md`, no próprio repositório
da aplicação. Esse arquivo é a entrada das skills `gerar-dockerfile` e
`gerar-deploy`, então tudo começa por aqui.

A análise tem sempre as mesmas 10 seções: resumo, stack e runtime, build e
execução, porta e healthcheck, variáveis (config separada de segredo),
dependências externas, arquivos existentes, riscos, perfil de execução e recomendação de destino
(a opção mais simples que atende ao perfil, pela boa prática da cloud) e
perguntas abertas para o time de dev.

## Quando usar

- Ao receber um repositório novo para preparar o deploy.
- Quando o time de dev mudar algo relevante (nova dependência, nova porta,
  novas variáveis) e a análise precisar ser refeita.
- Antes de qualquer conversa com o time de dev, para levar as perguntas
  abertas já organizadas.

## Entradas

- O repositório da aplicação aberto como workspace no Kiro.
- Opcional, como texto após o nome da skill: cloud e destino desejados,
  informações passadas pelo time de dev, restrições conhecidas.

## Saída

- `docs/deploy/analise.md` no repositório da aplicação.
- Um resumo curto no chat.
- Nenhum outro arquivo é criado ou alterado.

## Regras principais

- Só leitura no código da aplicação.
- Não inventa: o que não encontra vira pergunta aberta.
- Informação do time que não aparece no código é marcada como "informado
  pelo time, não encontrado no código".
- Segredos aparecem só pelo nome da variável, nunca pelo valor.

## Exemplo de uso

Dentro do Kiro CLI, com o repositório da aplicação como diretório atual:

```
/analisar-repo
```

Ou pelo agente dedicado:

```bash
kiro-cli chat --agent analyzer
```

```
Analise este repositório usando a skill analisar-repo.
```

## Exemplo de uso real

O time entregou uma API e disse por mensagem que ela usa um cache e que o
deploy deve ir para AKS. Não veio `.env.example`.

```
/analisar-repo Destino informado: AKS. O time de dev disse que a aplicação usa Redis como cache, confirme no código. Não recebemos .env.example, levante todas as variáveis lidas pelo código.
```

Resultado esperado: a seção 9 registra "AKS, informado pelo usuário"; se o
Redis não aparecer no código, a seção 6 registra "informado pelo time, não
encontrado no código" e a seção 10 ganha a pergunta correspondente; a seção
5 lista as variáveis encontradas no código e a seção 7 marca `.env.example`
como inexistente.
