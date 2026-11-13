# Checklist mínimo de produção

> Reference inicial. Ajuste os itens ao padrão do time. O agente `deployer`
> marca cada item como **atendido**, **pendente** ou **não se aplica** em
> `docs/deploy/deploy-<destino>.md`. Os demais agentes usam a lista para
> apontar riscos cedo.

> Para **hospedagem estática**, os itens de Imagem, réplicas, probes e
> SIGTERM não se aplicam; use a seção "Hospedagem estática".

## Imagem

- [ ] Dockerfile multi-stage.
- [ ] Imagem base com tag fixa (ou digest), nunca `latest`.
- [ ] Processo roda como usuário não root.
- [ ] Nenhum segredo em `ARG`, `ENV` ou camada da imagem.
- [ ] `.dockerignore` exclui `.git`, `.env*` e artefatos locais.
- [ ] Imagem publicada em `<registry>` com tag imutável.
- [ ] Imagem passou no scan de vulnerabilidades `<ferramenta-de-scan>`.

## Configuração e segredos

- [ ] Todas as variáveis da análise mapeadas (config ou segredo).
- [ ] Segredos criados no cofre (`<key-vault-name>` ou Secrets Manager) com
      os nomes do padrão.
- [ ] Nenhum valor de segredo em manifest, Terraform ou repositório.

## Saúde e resiliência

- [ ] Endpoint de healthcheck definido (ou pendência registrada com o time).
- [ ] Liveness e readiness configurados (AKS) ou health check do container e
      do target group (ECS).
- [ ] Requests e limits definidos (AKS) ou CPU e memória da task (ECS).
- [ ] No mínimo `<replicas-minimas>` réplicas em produção.
- [ ] Encerramento gracioso (aplicação trata SIGTERM).
- [ ] Rollback definido (reverter PR no AKS, circuit breaker no ECS).

## Rede e exposição

- [ ] Domínio `<dominio>` e certificado TLS definidos, se exposta.
- [ ] Aplicação em rede privada; exposição só pelo ingress ou ALB.

## Hospedagem estática

- [ ] Armazenamento sem acesso público direto (acesso só pela CDN) ou
      exceção documentada.
- [ ] HTTPS obrigatório, TLS mínimo 1.2 e certificado gerenciado.
- [ ] Cache longo e `immutable` para assets com hash; `no-cache` para HTML.
- [ ] Fallback SPA com status 200 (só se for SPA).
- [ ] Headers de segurança na CDN (HSTS, `X-Content-Type-Options`,
      `Referrer-Policy`, proteção contra frame).
- [ ] Versionamento ou soft delete habilitado para rollback.
- [ ] Logs de acesso da CDN com retenção definida.
- [ ] Publicação e invalidação de cache pelo pipeline, com identidade
      federada (OIDC) e permissão mínima.

## Segurança (DevSecOps)

- [ ] Varredura de segredos em todo PR (e push protection, se houver).
- [ ] SCA de dependências em PR e agendado.
- [ ] Scan de IaC em PR que altera IaC.
- [ ] Scan da imagem antes do push, falhando em `CRITICAL` com correção.
- [ ] SAST em PR.
- [ ] Exceções de segurança com justificativa e data de expiração.

## Observabilidade

- [ ] Logs em stdout e stderr.
- [ ] Log group com retenção definida (ECS) ou coleta configurada (AKS).
- [ ] Métricas e alertas mínimos em `<ferramenta-de-observabilidade>`.

## Processo

- [ ] Análise (`docs/deploy/analise.md`) sem perguntas abertas bloqueantes.
- [ ] Decisões específicas registradas como ADR em `docs/adr/`.
- [ ] Deploy feito via PR (AKS) ou pipeline (ECS), nunca manual.
- [ ] Responsável pela aplicação definido: `<time-responsavel>`.
