# Agente containerizer

Arquivos: `agents/containerizer.json` e `agents/instrucoes/containerizer.md`.

## Papel

Gerar o `Dockerfile` multi-stage e o `.dockerignore` da aplicação a partir
de `docs/deploy/analise.md`, ou revisar o Dockerfile existente e propor
melhorias sem sobrescrever.

## Skills que usa

- `gerar-dockerfile`

Resources carregados: steering global e `references/checklist-producao.md`.

## O que pode fazer

- Ler arquivos do workspace.
- Escrever `Dockerfile`, `.dockerignore` e arquivos em `docs/deploy/`
  (aprovados automaticamente por `toolsSettings.write.allowedPaths`).
- Rodar apenas `hadolint` e `docker build` local para validar
  (`toolsSettings.shell` com `denyByDefault`).

## O que não pode fazer

- Sobrescrever um Dockerfile existente sem pedido explícito.
- `docker push`, `docker login`, `kubectl`, `terraform`.
- Usar `latest` ou colocar segredos na imagem.
- Alterar código da aplicação.
- Rodar sem `docs/deploy/analise.md`.

## Exemplo de uso

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent containerizer
```

```
Gere o Dockerfile desta aplicação.
```

## Exemplo de uso real

```bash
cd <repositorio-da-aplicacao>
kiro-cli chat --agent containerizer
```

```
@real-revisar-dockerfile-ruim O Dockerfile atual usa latest, roda como root e copia o .env. A imagem base precisa vir de <registry-interno>.
```

O agente não toca no Dockerfile original. Gera
`docs/deploy/dockerfile-revisao.md` com a tabela de problemas e
`docs/deploy/Dockerfile.proposto` com a versão corrigida.
