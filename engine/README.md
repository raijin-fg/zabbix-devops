# engine

O "despachante" do projeto (Python): recebe o evento do Zabbix, aplica as regras,
aciona o Ansible, abre/fecha chamados no Remedy e envia e-mails.

- `src/engine/`: código (pacote Python).
- `rules/`: regras em YAML, uma por tipo de equipamento.
- `tests/`: testes automatizados.

Adicionar uma automação nova = uma regra em `rules/` + um playbook em `ansible/playbooks/`.
