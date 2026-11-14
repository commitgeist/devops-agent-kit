"""Juiz do llm-rubric usando o próprio Kiro (sem chave de API extra).

Roda o Kiro sem nenhuma ferramenta liberada, num diretório vazio, e devolve
a resposta. O promptfoo já pede ao juiz o JSON {"reason", "score", "pass"}.
"""
import shutil
import tempfile

from provider_kiro import kiro, ler_eventos


def call_api(prompt, options, context):
    vazio = tempfile.mkdtemp(prefix="promptfoo-juiz-")
    try:
        pedido = ("Você é um avaliador. Não use ferramentas. Responda SOMENTE com o JSON pedido, "
                  "sem cercas de código.\n\n" + prompt)
        rc, saida, erro = kiro(pedido, vazio, None, 300, trust_tools="",
                               modelo=options.get("config", {}).get("model"))
        texto = ler_eventos(saida)[0].strip()
        if rc != 0 or not texto:
            return {"error": f"juiz falhou ({rc}): {erro[-300:]}"}
        return {"output": texto}
    finally:
        shutil.rmtree(vazio, ignore_errors=True)
