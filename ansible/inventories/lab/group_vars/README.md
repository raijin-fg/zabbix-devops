# group_vars (lab)

Um arquivo `.yml` por grupo de tipo, com as variáveis de conexão:

- `all.yml`: valores comuns.
- `linux.yml`: SSH, usuário, become.
- `windows.yml`: WinRM (porta, transporte).
- `network.yml`: método de acesso (ex.: network_cli), usuário somente leitura.
- `database.yml`: usuário/método de acesso ao banco (somente leitura).

Valores sensíveis devem ficar criptografados com Ansible Vault.
