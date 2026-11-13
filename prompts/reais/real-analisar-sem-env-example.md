Use o analyzer para analisar este repositório. O time de dev não mandou
.env.example e só disse informalmente quais variáveis a aplicação usa.

O que o time disse:
$ARGUMENTS

Restrições:
- Levante todas as variáveis lidas pelo código (leitura direta de ambiente,
  arquivos de configuração por ambiente, docker-compose, testes) e informe
  arquivo e linha de cada uma.
- Separe config de segredo. Na dúvida, trate como segredo e gere pergunta.
- Compare com o que o time disse: variáveis citadas e não encontradas, e
  variáveis encontradas e não citadas, viram perguntas abertas.
- Registre a falta do .env.example em "Riscos e pontos de atenção".
- Só leitura no código. Escreva apenas docs/deploy/analise.md.
