# engine/src/engine/actions

Módulos que executam ações no mundo externo:

- `ansible_runner.py`: executa playbooks do Ansible.
- `remedy.py`: abre, atualiza e fecha chamados no BMC Remedy.
- `mailer.py`: envia e-mails (ex.: aviso ao ISP).

Cada módulo expõe funções simples e trata seus próprios erros.
