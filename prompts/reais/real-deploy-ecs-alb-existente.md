Use o deployer para gerar o deploy desta aplicação para ECS Fargate, na
ferramenta de IaC definida em docs/deploy/contexto.md, com base em
docs/deploy/analise.md.

Dados do ambiente:
$ARGUMENTS

Restrições:
- Cluster, VPC, subnets privadas e ALB já existem: receba tudo por variável
  (<cluster-name>, <vpc-id>, <subnet-ids>, <alb-listener-arn>), não crie.
- Exponha a aplicação pelo host <dominio> com uma listener rule no ALB
  existente e um target group do tipo ip.
- Segredos no Secrets Manager referenciados por ARN em secrets.valueFrom.
  A execution role só pode ler esses ARNs.
- Task role sem nenhuma policy se a análise não mostrar uso de serviços AWS.
- Log group com retenção de <dias-de-retencao> dias.
- Circuit breaker com rollback habilitado no service.
- Imagem com tag imutável, nunca latest.
- Rode só a validação permitida para a ferramenta. Nada de plan, preview,
  what-if, deploy ou apply.
