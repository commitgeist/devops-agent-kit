Use explicitamente a skill analisar-repo. Quero refazer a análise porque o
time de dev afirma que a aplicação depende de um Redis, mas eu não encontrei
nada no código.

Informações do time:
$ARGUMENTS

Restrições:
- Procure qualquer sinal de Redis ou cache distribuído: bibliotecas cliente
  nos manifestos de dependência, variáveis como REDIS_*, CACHE_*, strings de
  conexão, configuração de sessão distribuída e docker-compose.
- Se encontrar, registre na seção de dependências externas com arquivo e
  linha.
- Se não encontrar, registre "informado pelo time, não encontrado no
  código" e crie perguntas objetivas: qual funcionalidade usa o Redis, em
  qual branch ou versão está o código, e se o Redis é obrigatório para a
  aplicação subir.
- Não altere nada fora de docs/deploy/.
