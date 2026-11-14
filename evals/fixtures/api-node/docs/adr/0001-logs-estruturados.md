# ADR 0001: Logs estruturados no stdout

- Status: aceita
- Data: 2026-09-01

## Contexto

As aplicações rodam em container e a coleta de logs da plataforma lê o
stdout dos containers.

## Decisão

Toda aplicação escreve logs em **JSON**, **somente no stdout**. Nenhum log
em arquivo dentro do container.

## Consequências

- O nível de log é configurável por `LOG_LEVEL`.
- Arquivos de log locais são proibidos.
