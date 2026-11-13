#!/usr/bin/env bash
# Hook PreToolUse do devops-agent-kit: bloqueia leitura de arquivos sensíveis
# e comandos que expõem credenciais.
#
# O Kiro envia o evento em JSON no stdin (tool_name, tool_input, cwd...).
# Saída 0: libera a ferramenta. Saída diferente de 0: bloqueia, e o stderr
# volta para o agente como motivo.
#
# Só são inspecionados campos de caminho e de comando. Conteúdo que está
# sendo escrito (por exemplo, a análise citando ".env") não é bloqueado.

set -uo pipefail

if ! command -v python3 >/dev/null 2>&1; then
  # Sem python3 o hook não consegue inspecionar o evento. As regras deny de
  # permissions e a steering continuam valendo.
  exit 0
fi

python3 -I -c '
import json, re, sys

try:
    evento = json.load(sys.stdin)
except Exception:
    sys.exit(0)

entrada = evento.get("tool_input") or {}
ferramenta = str(evento.get("tool_name") or "").lower()

# Listar nomes de arquivos não expõe conteúdo: é assim que se detecta um
# .env versionado sem lê-lo.
SO_LISTAGEM = re.compile(r"(^|_)(glob|file_search|list_directory|fs_list|ls)$")
# Em busca de texto, "pattern" é o regex procurado, não um caminho.
BUSCA = re.compile(r"(^|_)(grep|grep_search|search)$")

CAMPOS_CAMINHO = {"path", "paths", "file_path", "filepath", "filePath", "file",
                  "files", "pattern", "glob", "directory", "dir", "target",
                  "source", "uri"}
CAMPOS_COMANDO = {"command", "cmd", "script"}
CAMPOS_IGNORADOS = {"content", "text", "new_str", "old_str", "file_text",
                    "summary", "description"}

caminhos, comandos, caminhos_com_chave = [], [], []

def coletar(valor, chave=None):
    if chave in CAMPOS_IGNORADOS:
        return
    if isinstance(valor, dict):
        for k, v in valor.items():
            coletar(v, k)
    elif isinstance(valor, list):
        for v in valor:
            coletar(v, chave)
    elif isinstance(valor, str):
        if chave in CAMPOS_COMANDO:
            comandos.append(valor)
        elif chave in CAMPOS_CAMINHO:
            caminhos.append(valor)
            caminhos_com_chave.append((chave, valor))

coletar(entrada)

EXEMPLO = r"(example|sample|template|dist)"
SENSIVEL = [
    rf"(^|[/\\\s\"'\''=])\.env(?!\.{EXEMPLO}\b)(\.[\w.-]+)?($|[\s\"'\'';|&)])",
    r"\.(pem|key|pfx|p12|jks|keystore|kdbx)($|[\s\"'\'';|&)])",
    r"(^|[/\\\s])id_(rsa|dsa|ecdsa|ed25519)(\.pub)?($|[\s;|&)])",
    r"(^|[/\\\s~])\.(aws|azure|kube|ssh|gnupg)([/\\]|$|\s)",
    r"\.docker[/\\]config\.json",
    r"(^|[/\\\s])\.git[/\\]config($|[\s;|&)])",
    r"(^|[/\\\s])\.(npmrc|pypirc|netrc|git-credentials)($|[\s;|&)])",
    r"(^|[/\\\s])credentials([\w.-]*\.json)?($|[\s;|&)])",
    r"(^|[/\\\s])secrets?\.[\w.-]+($|[\s;|&)])",
    r"\.tfstate(\.backup)?($|[\s;|&)])",
    rf"\.tfvars(?!\.{EXEMPLO}\b)($|[\s;|&)])",
]
COMANDOS_PROIBIDOS = [
    r"(^|[;|&(]\s*)(env|printenv|export\s+-p|set)\s*($|[;|&)])",
    r"\bprintenv\b",
    r"\baws\s+configure\s+(get|export-credentials)\b",
    r"\baz\s+account\s+get-access-token\b",
    r"\bgh\s+auth\s+token\b",
    r"\bkubectl\s+get\s+secrets?\b",
    r"\bterraform\s+output\b",
    r"\btofu\s+output\b",
    r"\bdocker\s+login\b",
    r"/proc/[^\s]*/environ",
    # Scanner de segredo só com saída mascarada.
    r"\bgitleaks\b(?!.*--redact)",
]

def casa(lista, texto):
    return any(re.search(p, texto, re.IGNORECASE) for p in lista)

if BUSCA.search(ferramenta):
    caminhos = [c for c in caminhos_com_chave if c[0] != "pattern"]
    caminhos = [c[1] for c in caminhos]
if SO_LISTAGEM.search(ferramenta):
    caminhos = []

for c in caminhos:
    if casa(SENSIVEL, c):
        print(f"Bloqueado pelo guardrail de segredos: leitura de \"{c}\" não é permitida. "
              "Use o código-fonte e os arquivos de exemplo para levantar NOMES de variáveis; "
              "para checar se o arquivo existe, use só a listagem de nomes.", file=sys.stderr)
        sys.exit(2)

for c in comandos:
    if casa(COMANDOS_PROIBIDOS, c) or casa(SENSIVEL, c):
        print(f"Bloqueado pelo guardrail de segredos: o comando \"{c}\" pode expor segredos ou credenciais. "
              "Não tente contornar; registre a necessidade como pendência para o usuário.", file=sys.stderr)
        sys.exit(2)

sys.exit(0)
'
