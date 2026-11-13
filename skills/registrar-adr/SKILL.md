---
name: registrar-adr
description: Registra uma decisão técnica da aplicação como ADR em docs/adr/ usando o template do kit. Use quando uma decisão de destino, ferramenta, exceção de segurança ou desvio de padrão do time precisar ficar documentada.
---

# Skill: registrar-adr

Decisão a registrar (pode estar vazia):
$ARGUMENTS

## Como fazer

1. Liste `docs/adr/` e descubra o próximo número (`NNNN`, quatro dígitos).
   Se já houver ADR sobre o mesmo assunto, pergunte se a nova **substitui**
   a anterior; se sim, atualize o status da antiga para
   "Substituída por ADR-NNNN".
2. Use o template `<kiro>/templates/adr/adr-template.md`.
3. Preencha só com o que foi decidido na conversa ou está nos documentos
   (`docs/deploy/analise.md`, `docs/deploy/contexto.md`, relatórios de
   `docs/review/`). Contexto, alternativas e consequências sem base viram
   perguntas antes de gravar, nunca suposição.
4. Escreva as consequências como itens **verificáveis**, para que a skill
   `revisar` consiga cobrar a implementação depois.
5. Status inicial: "Proposta". Só use "Aceita" se o usuário disser que a
   decisão foi aprovada.
6. Grave `docs/adr/NNNN-<titulo-curto>.md`.

## Ao terminar

Mostre o caminho, o título, o status e os itens verificáveis.
