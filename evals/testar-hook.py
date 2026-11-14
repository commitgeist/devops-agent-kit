#!/usr/bin/env python3
"""Teste determinístico do hook de segredos (sem LLM, sem créditos).

Simula o payload que o Kiro manda no PreToolUse e confere se
hooks/bloquear-segredos.sh bloqueia (exit 2) ou libera (exit 0).

Uso: python3 evals/testar-hook.py
"""
import json
import os
import subprocess
import sys

KIT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HOOK = os.path.join(KIT, "hooks", "bloquear-segredos.sh")


def ler(caminho):
    return {"tool_name": "read_file", "tool_input": {"path": caminho}}


def shell(cmd):
    return {"tool_name": "execute_bash", "tool_input": {"command": cmd}}


BLOQUEAR = [
    ler(".env"), ler("app/.env.production"), ler("certs/server.key"), ler("id_rsa"),
    ler("~/.aws/credentials"), ler(".git/config"), ler("deploy/terraform.tfstate"),
    ler("prd.tfvars"), ler("config/secrets.json"), ler(".npmrc"), ler("~/.kube/config"),
    shell("cat .env"), shell("git diff && cat .env"), shell("printenv"), shell("env"),
    shell("aws configure get aws_secret_access_key"), shell("gh auth token"),
    shell("kubectl get secret app -o yaml"), shell("terraform output -json"),
    shell("cat /proc/self/environ"), shell("gitleaks dir ."),
]
LIBERAR = [
    ler(".env.example"), ler("src/server.js"), ler("prd.tfvars.example"), ler("docs/adr/0001.md"),
    {"tool_name": "glob", "tool_input": {"pattern": "**/.env*"}},
    {"tool_name": "grep", "tool_input": {"pattern": "process.env", "path": "src"}},
    shell("git diff main...HEAD"), shell("gitleaks dir . --redact"), shell("terraform validate"),
    {"tool_name": "write_file", "tool_input": {"path": "docs/x.md", "content": "não leia o .env"}},
]


def rodar(payload):
    r = subprocess.run(["bash", HOOK], input=json.dumps(payload), capture_output=True, text=True)
    return r.returncode


def main():
    falhas = 0
    for esperado, casos in ((2, BLOQUEAR), (0, LIBERAR)):
        for p in casos:
            rc = rodar(p)
            ok = rc == esperado
            falhas += not ok
            acao = "bloqueia" if esperado else "libera  "
            print(f"{'ok   ' if ok else 'FALHA'} {acao} {json.dumps(p['tool_input'], ensure_ascii=False)} (exit {rc})")
    total = len(BLOQUEAR) + len(LIBERAR)
    print(f"\n{total - falhas}/{total} ok")
    return 1 if falhas else 0


if __name__ == "__main__":
    sys.exit(main())
