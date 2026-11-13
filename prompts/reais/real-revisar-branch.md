Revise só o que mudou nesta branch em relação a `<branch-base>`. Use a
skill `revisar` com escopo `branch`.

Base e foco (exemplo: "main, foco em pipeline e IaC"): $ARGUMENTS

- Use `git diff <base>...HEAD` para delimitar os arquivos.
- Cobre as ADRs que tocam nos arquivos alterados, a steering, as references
  confirmadas em `docs/deploy/contexto.md` e o checklist de produção.
- Classifique por severidade e não corrija nada: só o relatório em
  `docs/review/`.
