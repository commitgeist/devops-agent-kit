# Ferramentas de segurança (noção)

> Reference de **orientação**, não de padrão fechado. Os agentes `secops` e
> `pipeliner` usam esta tabela para sugerir controles; a escolha final é do
> time e vai para `padroes-do-time.md` ou ADR. Nomes de tasks, versões e
> licenciamento mudam: confira a documentação oficial antes de adotar.

## Controles por camada

| Camada | O que pega | Open source / multiplataforma | GitHub | Azure DevOps |
|--------|-----------|-------------------------------|--------|--------------|
| Segredos no código | Chave, token e senha versionados | Gitleaks | Secret scanning + push protection | GitHub Advanced Security for Azure DevOps (secret scanning e push protection) |
| Dependências (SCA) | CVE em bibliotecas | Trivy (`fs`), Grype, OWASP Dependency-Check | Dependabot, dependency review | GHAzDO dependency scanning; Trivy via Microsoft Security DevOps |
| Código (SAST) | Injeção, XSS, desserialização etc. | Semgrep CE | CodeQL | GHAzDO code scanning (CodeQL) |
| IaC | Recurso público, sem criptografia, IAM amplo | Checkov, Trivy (`config`) | Checkov/Trivy como action, upload SARIF | Microsoft Security DevOps (Checkov, Terrascan, Template Analyzer, Trivy) |
| Container | CVE na imagem, Dockerfile inseguro | Trivy (`image`), hadolint | Trivy action, Dependabot para imagem base | Trivy via MSDO; Defender for Containers no registry |
| SBOM e assinatura | Rastreabilidade e integridade do artefato | Syft (SBOM), Cosign (assinatura) | Attestations | Syft/Cosign como script |
| DAST | Falha visível só com a app rodando | OWASP ZAP (baseline) | ZAP action | ZAP em container no job |
| Postura | Visão consolidada e priorização | — | Security overview | Microsoft Defender for Cloud (DevOps security) conectado à organização |

## Mínimo recomendado para começar

1. **Segredos** em todo PR (Gitleaks ou secret scanning nativo) e push
   protection quando a plataforma tiver.
2. **SCA** em todo PR e agendado (CVE nova aparece sem mudança de código).
3. **IaC** em todo PR que muda IaC.
4. **Imagem** antes do push para o registry, falhando em `CRITICAL` com
   correção disponível.
5. **SAST** em todo PR (Semgrep CE ou CodeQL).
6. DAST e SBOM/assinatura quando os itens acima estiverem estáveis.

Política de falha sugerida: bloquear o PR em segredo encontrado e em
`CRITICAL`/`HIGH` com correção disponível; demais severidades geram
relatório. Exceções só com justificativa registrada (ADR ou arquivo de
supressão versionado com data de expiração).

## Segurança da própria esteira

- Autenticação na cloud por OIDC/workload identity federation, sem chave
  estática.
- Actions de terceiros fixadas por SHA; tasks e imagens de job por versão
  fixa.
- Token do pipeline com permissões mínimas; sem deploy a partir de PR de
  fork.
- Ambientes de produção com aprovação; branch principal protegida com
  revisão obrigatória.
- Azure DevOps: variable groups ligados ao Key Vault, service connections
  restritas a pipelines específicos, approvals and checks nos environments.
- Saída das ferramentas em SARIF quando possível, para aparecer na aba de
  segurança da plataforma.
