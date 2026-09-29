# engine/src/engine

Pacote Python principal. Um módulo por responsabilidade:

- `app.py`: recebe o webhook do Zabbix.
- `config.py`: lê configurações do `.env`.
- `rules.py`: carrega e aplica as regras de `engine/rules/`.
- `state.py`: estado (evento ↔ chamado, tentativas, cooldown).
- `actions/`: integrações com o mundo externo (Ansible, Remedy, e-mail).

Evite um `utils.py` genérico: prefira módulos com nome que diga o que fazem.
