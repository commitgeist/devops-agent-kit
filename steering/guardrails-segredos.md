---
inclusion: always
---

# Guardrails de segredos e credenciais

Estas regras valem para qualquer agente, skill ou conversa. Elas são
reforçadas por três camadas técnicas: regras `deny` em `permissions` de cada
agente, o hook `hooks/bloquear-segredos.sh` (PreToolUse) e esta steering.
Se uma camada falhar, as outras continuam valendo: **nunca tente contornar
um bloqueio**.

## Nunca ler

- Arquivos de ambiente: `.env`, `.env.*` (exceto `.env.example`,
  `.env.sample` e `.env.template`).
- Chaves e certificados: `*.pem`, `*.key`, `*.pfx`, `*.p12`, `*.jks`,
  `*.keystore`, `id_rsa*`, `id_ed25519*`, `id_ecdsa*`.
- Credenciais de ferramentas: `~/.aws/`, `~/.azure/`, `~/.kube/`, `~/.ssh/`,
  `~/.gnupg/`, `~/.docker/config.json`, `.npmrc`, `.pypirc`, `.netrc`,
  `.git-credentials`, `.git/config` (a URL do remote pode ter token),
  `credentials*.json`, `secret.*`, `secrets.*`.
- Estado e variáveis de IaC: `*.tfstate*`, `*.tfvars` (exceto
  `*.tfvars.example`).

Para saber **quais** variáveis a aplicação usa, leia o **código**
(`process.env`, `os.environ` etc.) e os arquivos de exemplo. Para saber se
um arquivo sensível **existe** (risco de segredo versionado), use só a
listagem de nomes (`glob`), nunca o conteúdo.

## Nunca executar

- Comandos que imprimem o ambiente ou credenciais: `env`, `printenv`,
  `set`, `export -p`, `aws configure get`, `aws configure
  export-credentials`, `az account get-access-token`, `gh auth token`,
  `kubectl get secret`, `terraform output` de valores sensíveis,
  `docker login`.
- `cat`, `head`, `tail`, `less`, `grep`, `source` ou equivalentes sobre os
  arquivos da lista acima.

## Quando o usuário colar um segredo

- Não repita o valor na resposta nem em arquivo.
- Avise que o valor foi exposto, recomende a rotação e siga usando apenas
  o **nome** do segredo (`<secret-name>`).

## MCP e tokens

- Tokens de servidores MCP vêm de variáveis de ambiente do shell do
  usuário ou de login interativo da ferramenta, nunca escritos em
  `mcp.json`, em arquivo do kit ou no repositório da aplicação.
- Servidores MCP de plataforma (Git, CI/CD, cloud) são usados para
  **consulta**. Criar, alterar ou apagar qualquer coisa por MCP exige pedido
  explícito do usuário na mensagem atual, como qualquer outra ação
  irreversível.
