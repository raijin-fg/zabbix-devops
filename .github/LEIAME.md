# .github

Configurações do GitHub para o repositório.

- `ISSUE_TEMPLATE/`: modelos de issue (arquivos `.md` ou `.yml`). Tudo o que
  estiver lá aparece como opção ao clicar em "New issue". Por isso **não** coloque
  README dentro dessa pasta. Modelo atual: `nova-automacao.md` (fila de automações).
- `workflows/`: pipelines do GitHub Actions (`.yml`). Ainda vazio; os workflows de
  lint/testes entram no M6.

Obs.: este arquivo se chama LEIAME.md de propósito. Um `README.md` dentro de
`.github/` teria prioridade sobre o README da raiz na página do repositório.
