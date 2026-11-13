# References do time

Aqui fica o **conhecimento do time**: convenções, padrões de configuração e
exemplos que os agentes consultam antes de gerar ou revisar qualquer coisa.
Depois do `install.sh`, a pasta fica em `~/.kiro/references/`.

**Este arquivo é o índice.** Todos os agentes do kit carregam este índice e
leem sob demanda só as references que se aplicam à tarefa.

## Como os agentes usam

1. Leem este índice e escolhem as references aplicáveis (pela coluna
   "Quando usar").
2. **Confirmam com o usuário antes de seguir uma reference.** No fluxo
   `subir-app`, quem confirma é o orquestrador (`devops`), na Etapa 0, e
   repassa a lista confirmada aos subagentes. Rodando sozinho, o próprio
   agente pergunta.
3. Subagentes usam só as references confirmadas. Se acharem outra
   aplicável, devolvem como **sugestão** no resultado, sem usar.
4. Reference com status `rascunho` ainda tem placeholders: os agentes
   mantêm os placeholders nos artefatos em vez de inventar valores.
5. Reference prevalece sobre o conhecimento geral do modelo. Se uma
   reference contrariar boa prática de segurança, o agente aponta o
   conflito e pergunta; não segue em silêncio.

## Índice

| Reference | Categoria | Quando usar | Status |
|-----------|-----------|-------------|--------|
| `padroes-do-time.md` | Convenções | Sempre: ferramentas padrão (cloud, IaC, CI/CD, registry, cofre) | rascunho |
| `nomenclatura.md` | Convenções | Ao nomear recursos de cloud, objetos Kubernetes, tags e segredos | rascunho |
| `checklist-producao.md` | Convenções | Ao gerar ou revisar qualquer artefato de entrega | rascunho |
| `gitops.md` | Kubernetes | Destino AKS/Kubernetes via GitOps | rascunho |
| `pipeline/` | Pipeline | Ao gerar ou revisar pipeline: templates e exemplos aprovados por plataforma | vazio |
| `seguranca/ferramentas.md` | Segurança | Ao avaliar segurança ou propor estágios de segurança no pipeline (GitHub, Azure DevOps, open source) | noção |
| `iac/` | IaC | Ao gerar ou revisar IaC: módulos internos, exemplos aprovados, backend de state | vazio |

## Como adicionar uma reference

1. Coloque o arquivo na categoria certa (crie a pasta se for nova, por
   exemplo `observabilidade/`).
2. Sem nome de cliente, aplicação, servidor ou pessoa: placeholders
   `<placeholder>`.
3. Adicione uma linha neste índice com "Quando usar" bem específico: é por
   ele que o agente decide se a reference se aplica.
4. Marque o status: `pronto` (pode ser seguido como está), `rascunho`
   (tem placeholders) ou `noção` (orientação; a escolha é do time).

## Diferença para steering e skills

| Pasta | O que contém | Quem carrega |
|-------|--------------|--------------|
| `steering/` | Regras de comportamento que valem sempre (proibições, segurança) | Todos, sempre |
| `skills/` | Procedimento passo a passo de uma tarefa | O agente que executa a tarefa |
| `references/` | Dados, convenções e exemplos do time | Índice sempre; arquivos sob demanda, após confirmação |
