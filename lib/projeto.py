#!/usr/bin/env python3
"""Instala ou remove o devops-agent-kit no escopo de um repositório.

Uso (via install.sh / uninstall.sh):
    projeto.py instalar <repo>
    projeto.py remover  <repo>

COPIA o kit para <repo>/.kiro/ (steering, skills, references, templates,
instruções dos agentes, prompts e script do hook), sem links: a pasta fica
autossuficiente e não quebra se o kit mudar de lugar. GERA os arquivos que
dependem de caminho: os JSONs dos agentes (caminhos relativos a .kiro/ e
regras de segredo embutidas, porque o permissions.yaml de workspace não
fica no repositório) e o JSON do hook.

Tudo que o kit escreveu fica listado em .kiro/.devops-agent-kit. Reinstalar
atualiza esses arquivos e remove os que saíram do kit; arquivos seus em
.kiro/ nunca são tocados. Adiciona .kiro/ ao .git/info/exclude (ignore
local, não altera o .gitignore versionado).
"""
import json
import os
import sys

KIT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MARCA = ".devops-agent-kit"
COPIAS = ["steering", "skills", "references", "templates"]
EXCLUDE_LINHA = ".kiro/"
erros = 0


def avisar_erro(msg):
    global erros
    erros += 1
    print(f"ERRO      {msg}")


def ler_regras_yaml(caminho):
    """Lê settings/permissions.yaml (formato simples do kit, sem PyYAML)."""
    regras, atual, lista = [], None, None
    for bruta in open(caminho, encoding="utf-8"):
        linha = bruta.split("#", 1)[0].rstrip() if not bruta.strip().startswith('- "') else bruta.rstrip()
        s = linha.strip()
        if not s or s == "rules:":
            continue
        if s.startswith("- capability:"):
            atual = {"capability": s.split(":", 1)[1].strip()}
            regras.append(atual)
            lista = None
        elif s.startswith("effect:"):
            atual["effect"] = s.split(":", 1)[1].strip()
        elif s in ("match:", "exclude:"):
            lista = s[:-1]
            atual[lista] = []
        elif s.startswith("- ") and lista:
            atual[lista].append(s[2:].strip().strip('"'))
    return regras


def gerar(destino, conteudo, gerados, kiro, silencioso=False):
    rel = os.path.relpath(destino, kiro)
    if os.path.exists(destino) and not os.path.islink(destino) and rel not in gerados["anteriores"]:
        avisar_erro(f"{destino} já existe e não foi gerado pelo kit; mova e rode de novo.")
        return
    if os.path.islink(destino):
        os.remove(destino)
    with open(destino, "w", encoding="utf-8") as f:
        f.write(conteudo)
    gerados["novos"].append(rel)
    if not silencioso:
        print(f"gerado    .kiro/{rel}")


def converter_agente(dados, regras_segredo):
    recursos = []
    for r in dados.get("resources", []):
        if r.startswith("file://~/.kiro/steering/"):
            continue  # a steering de .kiro/steering já é carregada pelo workspace
        recursos.append(r.replace("~/.kiro/", ".kiro/"))
    dados["resources"] = recursos
    regras = dados.setdefault("permissions", {}).setdefault("rules", [])
    dados["permissions"]["rules"] = [dict(r) for r in regras_segredo] + regras
    return dados


def checar_engine():
    """Os agentes do kit usam o formato v3; sem a engine v3 o Kiro responde
    'Mode <agente> not found'."""
    import subprocess
    try:
        r = subprocess.run(["kiro-cli", "settings", "chat.agentEngine"],
                           capture_output=True, text=True, timeout=20)
        valor = (r.stdout.split() or [""])[0].strip('"')  # ex.: "v3 (global)"
    except Exception:
        return
    if valor != "v3":
        print("\nATENÇÃO   os agentes do kit exigem a engine v3 do Kiro (atual: "
              f"{valor or 'não definida'}). Rode:")
        print("          kiro-cli settings chat.agentEngine v3")


def instalar(repo):
    kiro = os.path.join(repo, ".kiro")
    os.makedirs(kiro, exist_ok=True)
    marca = os.path.join(kiro, MARCA)
    anteriores = set(open(marca).read().split()) if os.path.exists(marca) else set()
    gerados = {"anteriores": anteriores, "novos": []}

    # Instalação antiga por links: remove os links para o kit antes de
    # copiar, para nunca escrever dentro do kit através de um link.
    for raiz, dirs, arquivos in os.walk(kiro, topdown=True):
        for nome in list(dirs) + arquivos:
            p = os.path.join(raiz, nome)
            if os.path.islink(p) and os.path.realpath(p).startswith(KIT):
                os.remove(p)
                if nome in dirs:
                    dirs.remove(nome)
                print(f"removido  link antigo {os.path.relpath(p, repo)}")

    def copiar_arquivo(origem, rel):
        destino = os.path.join(kiro, rel)
        os.makedirs(os.path.dirname(destino), exist_ok=True)
        gerar(destino, open(origem, encoding="utf-8").read(), gerados, kiro, silencioso=True)

    print("Copiando o kit:")
    for nome in COPIAS:
        base = os.path.join(KIT, nome)
        total = 0
        for raiz, _, arquivos in os.walk(base):
            for arq in arquivos:
                origem = os.path.join(raiz, arq)
                copiar_arquivo(origem, os.path.join(nome, os.path.relpath(origem, base)))
                total += 1
        print(f"copiado   .kiro/{nome}/ ({total} arquivos)")
    for arq in sorted(os.listdir(os.path.join(KIT, "agents", "instrucoes"))):
        copiar_arquivo(os.path.join(KIT, "agents", "instrucoes", arq), os.path.join("agents", "instrucoes", arq))
    reais = os.path.join(KIT, "prompts", "reais")
    for arq in sorted(os.listdir(reais)):
        if arq.endswith(".md"):
            copiar_arquivo(os.path.join(reais, arq), os.path.join("prompts", arq))
    copiar_arquivo(os.path.join(KIT, "hooks", "bloquear-segredos.sh"), os.path.join("hooks", "bloquear-segredos.sh"))
    print("copiado   .kiro/agents/instrucoes/, .kiro/prompts/, .kiro/hooks/bloquear-segredos.sh")

    print("\nGerando agentes e hook:")
    regras_segredo = ler_regras_yaml(os.path.join(KIT, "settings", "permissions.yaml"))
    os.makedirs(os.path.join(kiro, "agents"), exist_ok=True)
    for arq in sorted(os.listdir(os.path.join(KIT, "agents"))):
        if not arq.endswith(".json") or arq == "agent_config.json":
            continue
        dados = json.load(open(os.path.join(KIT, "agents", arq), encoding="utf-8"))
        conteudo = json.dumps(converter_agente(dados, regras_segredo), indent=2, ensure_ascii=False) + "\n"
        gerar(os.path.join(kiro, "agents", arq), conteudo, gerados, kiro)

    hook = json.load(open(os.path.join(KIT, "hooks", "guardrail-segredos.json"), encoding="utf-8"))
    for h in hook["hooks"]:
        h["action"]["command"] = "bash .kiro/hooks/bloquear-segredos.sh"
    gerar(os.path.join(kiro, "hooks", "guardrail-segredos.json"),
          json.dumps(hook, indent=2, ensure_ascii=False) + "\n", gerados, kiro)

    for rel in sorted(anteriores - set(gerados["novos"])):
        caminho = os.path.join(kiro, rel)
        if os.path.isfile(caminho):
            os.remove(caminho)
            print(f"removido  .kiro/{rel} (saiu do kit)")

    with open(marca, "w") as f:
        f.write("\n".join(sorted(gerados["novos"])) + "\n")

    print("\nGit:")
    git_dir = os.path.join(repo, ".git")
    if os.path.isdir(git_dir):
        exclude = os.path.join(git_dir, "info", "exclude")
        os.makedirs(os.path.dirname(exclude), exist_ok=True)
        linhas = open(exclude).read().splitlines() if os.path.exists(exclude) else []
        if EXCLUDE_LINHA in linhas:
            print(f"ok        {EXCLUDE_LINHA} já está em .git/info/exclude")
        else:
            with open(exclude, "a") as f:
                f.write(f"\n# devops-agent-kit (instalação local, não versionar)\n{EXCLUDE_LINHA}\n")
            print(f"criado    {EXCLUDE_LINHA} em .git/info/exclude (ignore local, não altera o .gitignore)")
    else:
        print("aviso     não é repositório git: adicione .kiro/ ao .gitignore se for versionar.")


def remover(repo):
    kiro = os.path.join(repo, ".kiro")
    if not os.path.isdir(kiro):
        print(f"Nada a remover: {kiro} não existe.")
        return
    marca = os.path.join(kiro, MARCA)
    gerados = open(marca).read().split() if os.path.exists(marca) else []
    removidos = 0
    for rel in gerados:
        p = os.path.join(kiro, rel)
        if os.path.isfile(p):
            os.remove(p)
            removidos += 1
    print(f"removido  {removidos} arquivo(s) do kit em .kiro/")
    for raiz, dirs, arquivos in os.walk(kiro, topdown=False):
        for nome in dirs + arquivos:
            p = os.path.join(raiz, nome)
            if os.path.islink(p) and os.readlink(p).startswith(KIT):
                os.remove(p)
                print(f"removido  {p}")
    if os.path.exists(marca):
        os.remove(marca)
    for raiz, dirs, arquivos in os.walk(kiro, topdown=False):
        if not os.listdir(raiz):
            os.rmdir(raiz)
    exclude = os.path.join(repo, ".git", "info", "exclude")
    if os.path.exists(exclude):
        linhas = open(exclude).read().splitlines()
        novas = [l for l in linhas if l not in (EXCLUDE_LINHA, "# devops-agent-kit (instalação local, não versionar)")]
        if novas != linhas:
            open(exclude, "w").write("\n".join(novas).rstrip() + "\n")
            print("removido  .kiro/ de .git/info/exclude")
    if os.path.isdir(kiro):
        print(f"Mantido   {kiro} (tem arquivos que não são do kit).")


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("instalar", "remover"):
        print(__doc__)
        sys.exit(2)
    alvo = os.path.abspath(os.path.expanduser(sys.argv[2]))
    if not os.path.isdir(alvo):
        print(f"ERRO: {alvo} não é um diretório.")
        sys.exit(1)
    (instalar if sys.argv[1] == "instalar" else remover)(alvo)
    if sys.argv[1] == "instalar":
        checar_engine()
    if erros:
        print(f"\nConcluído com {erros} erro(s). Veja as mensagens de ERRO acima.")
        sys.exit(1)
    print("\nConcluído.")
