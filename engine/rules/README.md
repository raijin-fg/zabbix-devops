# engine/rules

Regras de automação em YAML, um arquivo por tipo de equipamento:
`linux.yml`, `windows.yml`, `network.yml`, `database.yml`.

Cada regra liga um trigger a uma ação: playbook a executar, variáveis, fila do Remedy,
nível de automação (N0/N1/N2) e guardrails (limite de tentativas, cooldown).
