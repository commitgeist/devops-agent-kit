# AGENTS.md: manutenção do devops-agent-kit

Regras para quem altera **este kit**. Regras de DevOps para qualquer
repositório ficam em `steering/`.

- Nenhum valor específico de aplicação, cliente, servidor ou pessoa: só
  placeholders `<placeholder>`. Textos em português do Brasil.
- Procedimento vai na skill (`skills/<nome>/SKILL.md`); o agente
  (`agents/<nome>.json` + `agents/instrucoes/<nome>.md`) só diz papel,
  skills e limites. Permissões vão em `permissions.rules` (Kiro v3).
- As três camadas de segredo cobrem o mesmo conjunto: ao mudar uma, mude
  `settings/permissions.yaml`, `hooks/bloquear-segredos.sh` e
  `steering/guardrails-segredos.md`.
- Reference nova: entra no índice `references/README.md`.
- Agente, skill ou prompt novo: atualize as tabelas do `README.md` e de
  `prompts/README.md`.
- Antes do PR: `kiro-cli agent validate --path agents/<nome>.json` em todos
  os agentes e `bash -n` nos scripts.
