# References de IaC

Módulos, exemplos e convenções de infraestrutura como código **aprovados
pelo time**, um subdiretório por ferramenta. O agente `deployer` usa os
módulos daqui em vez de recursos crus, e o `reviewer` compara a IaC com
estes padrões.

```
iac/
├── terraform/             # ex.: catálogo de módulos internos, backend.md
├── opentofu/
├── bicep/
├── pulumi/
└── cdk/
```

Conteúdo esperado:

- **Catálogo de módulos:** nome, origem (`<registry-ou-repositorio>`),
  versão aprovada, entradas obrigatórias e para que serve.
- **Backend de state:** padrão por ambiente, com placeholders
  (`<state-bucket>`, `<state-key>`), nunca credencial.
- **Exemplos completos** de um destino (ECS, AKS, hospedagem estática)
  seguindo o padrão do time.

Ao adicionar, atualize o índice em `references/README.md`.
