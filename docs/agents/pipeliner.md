# Agente pipeliner

Arquivos: `agents/pipeliner.json` e `agents/instrucoes/pipeliner.md`.

## Papel

Gerar o pipeline de CI/CD da aplicação na plataforma do contexto de entrega
(`docs/deploy/contexto.md`), com a skill `gerar-pipeline`.

## Skills que usa

- `gerar-pipeline`

Resources carregados: steering global, `nomenclatura.md`,
`checklist-producao.md` e `padroes-do-time.md`. Servidores MCP do Kiro
(`includeMcpJson`): documentação liberada, plataforma com confirmação.

## O que pode fazer

- Ler arquivos do workspace (exceto arquivos de segredo).
- Escrever arquivos de pipeline da plataforma e em `docs/deploy/`.
- Consultar a plataforma de CI/CD via MCP, com confirmação.

## O que não pode fazer

- Rodar shell (não tem a ferramenta).
- Disparar pipeline, criar secrets ou alterar configuração da plataforma.
- Sobrescrever pipeline existente sem pedido explícito.
- Usar `latest` ou colocar valor de segredo no YAML.

## Exemplo de uso

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent pipeliner
```

```
Gere o pipeline desta aplicação.
```
