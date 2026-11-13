# References

Aqui fica o **conhecimento do time**: convenções, fluxos e checklists que
os agentes precisam seguir para gerar artefatos do jeito que o time
trabalha. São arquivos genéricos, com placeholders no formato
`<placeholder>`, que devem ser completados com os padrões reais do time
(sem nomes de cliente, aplicação, servidor ou pessoa).

Depois do `install.sh`, esta pasta fica disponível em `~/.kiro/references/`
e cada agente carrega só os arquivos de que precisa, pelo campo
`resources` do seu JSON (`file://~/.kiro/references/<arquivo>.md`).

## Diferença para steering e skills

| Pasta | O que contém | Quem carrega |
|-------|--------------|--------------|
| `steering/` | Regras de comportamento que valem sempre (proibições, segurança) | Todos os agentes |
| `skills/` | Procedimento passo a passo de uma tarefa | O agente que executa a tarefa |
| `references/` | Dados e convenções do time (nomes, fluxo de PR, checklist) | Só os agentes que precisam daquele dado |

## Quais agentes leem cada arquivo

| Arquivo | subir-app | analyzer | containerizer | deployer | pipeliner |
|---------|:---------:|:--------:|:-------------:|:--------:|:---------:|
| `gitops.md` | | | | sim | |
| `nomenclatura.md` | | | | sim | sim |
| `checklist-producao.md` | sim | sim | sim | sim | sim |
| `padroes-do-time.md` | sim | sim | | sim | sim |

`nomenclatura.md` e `checklist-producao.md` cobrem AKS, ECS e hospedagem
estática (AWS e Azure).

Ao criar uma reference nova, adicione-a ao `resources` dos agentes que
precisam dela e atualize esta tabela.
