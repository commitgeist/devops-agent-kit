Recebi este repositório de outro time para preparar o deploy. Rode o fluxo
completo do subir-app.

Contexto que o time de dev passou (pode conter informação que não está no
código, confira tudo):
$ARGUMENTS

Restrições:
- Tudo que o time afirmou e não aparecer no código deve ser marcado como
  "informado pelo time, não encontrado no código" e virar pergunta aberta.
  Exemplo típico: o dev diz que a app usa Redis, mas não há cliente Redis nem
  variável de conexão no código.
- Se o .env.example não existir, levante as variáveis direto do código.
- Me mostre a análise e as perguntas abertas e espere minha confirmação
  antes de gerar Dockerfile e deploy.
- Não faça commit e não aplique nada.
