# ansible/inventories

Inventários separados por ambiente:

- `lab/`: servidores de teste. Aqui se desenvolve e valida tudo.
- `prod/`: produção. Só a estrutura; nada de senha em texto puro (use Ansible Vault).

Cada ambiente tem `hosts.yml` (hosts agrupados por tipo: linux, windows, network, database)
e `group_vars/` com as variáveis de cada grupo.
