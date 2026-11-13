Use o analyzer para analisar (ou refazer a análise de) este repositório,
conferindo o que o time de dev informou contra o código.

O que o time disse (variáveis, dependências, serviços externos):
$ARGUMENTS

Restrições:
- Levante todas as variáveis lidas pelo código (ambiente, arquivos de
  configuração por ambiente, docker-compose, testes) com arquivo e linha.
  Separe config de segredo; na dúvida, trate como segredo e gere pergunta.
- Para cada dependência citada pelo time (exemplo: Redis), procure clientes
  nos manifestos de dependência, variáveis, strings de conexão e
  docker-compose. Se não encontrar, registre "informado pelo time, não
  encontrado no código" e pergunte qual funcionalidade usa, em qual branch
  está o código e se é obrigatória para a aplicação subir.
- Variáveis citadas e não encontradas, e encontradas e não citadas, viram
  perguntas abertas. Se faltar .env.example, registre em riscos.
- Só leitura no código. Escreva apenas em docs/deploy/.
