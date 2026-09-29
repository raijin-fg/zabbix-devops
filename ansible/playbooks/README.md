# ansible/playbooks

Playbooks organizados por tipo de equipamento:

- `linux/`, `windows/`: remediações (ex.: reinício de serviço).
- `network/`, `database/`: diagnósticos somente leitura (nível N1).

Convenções: nomes em minúsculas com underscore (`restart_service.yml`), parâmetros por
variáveis (ex.: `service_name`) e sempre idempotentes.
