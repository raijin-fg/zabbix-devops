# ansible/inventories/lab

Inventário do laboratório.

- `hosts.yml`: hosts de teste, agrupados por tipo (`linux`, `windows`, `network`, `database`).
- `group_vars/`: variáveis por grupo (usuário de conexão, método, portas).

Não commite senhas. Use Ansible Vault ou variáveis de ambiente.
