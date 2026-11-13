# Checklist mínimo de produção

> Reference inicial. Ajuste os itens ao padrão do time. O agente `deployer`
> marca cada item como **atendido**, **pendente** ou **não se aplica** em
> `docs/deploy/deploy-<destino>.md`. Os demais agentes usam a lista para
> apontar riscos cedo.

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

## Observabilidade

- [ ] Logs em stdout e stderr.
- [ ] Log group com retenção definida (ECS) ou coleta configurada (AKS).
- [ ] Métricas e alertas mínimos em `<ferramenta-de-observabilidade>`.

## Processo

- [ ] Análise (`docs/deploy/analise.md`) sem perguntas abertas bloqueantes.
- [ ] Decisões específicas registradas como ADR em `docs/adr/`.
- [ ] Deploy feito via PR (AKS) ou pipeline (ECS), nunca manual.
- [ ] Responsável pela aplicação definido: `<time-responsavel>`.
