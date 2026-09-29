# ansible

Tudo o que o Ansible precisa para executar as remediações e diagnósticos.

- `ansible.cfg`: configuração local do Ansible.
- `requirements.yml`: collections necessárias (`ansible-galaxy collection install -r requirements.yml`).
- `inventories/`: hosts e variáveis, separados por ambiente (`lab` e `prod`).
- `playbooks/`: playbooks organizados por tipo de equipamento.

Regra de ouro: rode primeiro no `lab`. Segredos ficam no Ansible Vault ou no `.env`, nunca em texto puro aqui.
