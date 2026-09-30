## Arquitetura e Justificativa Tecnológica

Para o ciclo de vida de auto-remediação e orquestração de incidentes, adotamos a arquitetura **Zabbix → Webhook → Middleware (Python) → Ansible / ITSM**.

### Motivos para a Escolha da Arquitetura

1. **Separação de Responsabilidades:** O Zabbix atua estritamente na detecção de eventos e envio de dados via Webhook. A decisão de negócio e orquestração do incidente fica centralizada no Middleware Python.
2. **Segurança e Privilégios:** Elimina-se a necessidade de permissões de execução remota (`sudo`) diretamente nos agentes Zabbix dos servidores. Toda a comunicação de remediação ocorre via SSH centralizado pela controladora do Ansible.
3. **Gerenciamento de Ciclo de Vida do Incidente:** A arquitetura permite integrar facilmente o fluxo com plataformas de ITSM (abertura, escalonamento para fila de SO após $N$ tentativas e fechamento automático após a verificação do Zabbix).
4. **Idempotência e Manutenibilidade:** A remediação é feita através de Playbooks Ansible declarativas, garantindo que as ações executadas sejam seguras, idênticas e auditáveis.

## Visão da Arquitetura

```mermaid
flowchart LR
    subgraph ALVOS["Infraestrutura monitorada"]
        H["Servidores e equipamentos<br/>Linux, Windows, rede e banco"]
    end

    Z["Zabbix Server<br/>detecção de eventos"]
    M["Middleware Python<br/>regras, decisão e orquestração"]
    A["Ansible Controller<br/>playbooks declarativos"]
    I["ITSM - BMC Remedy<br/>abertura, escalonamento e fechamento"]
    S[("Estado<br/>evento e chamado, tentativas")]

    H -- "coleta de métricas" --> Z
    Z -- "Webhook: PROBLEM e OK" --> M
    M -- "executa playbook" --> A
    A -- "SSH centralizado" --> H
    M -- "abre, escala e fecha chamado" --> I
    M <--> S
```

## Ciclo de Vida do Incidente

```mermaid
sequenceDiagram
    autonumber
    participant H as Host monitorado
    participant Z as Zabbix
    participant M as Middleware Python
    participant A as Ansible
    participant I as ITSM

    H->>Z: Falha detectada
    Z->>M: Webhook (PROBLEM)
    M->>M: Consulta regras e estado

    loop Até N tentativas
        M->>A: Executa playbook de remediação
        A->>H: Ação via SSH
        A-->>M: Resultado da execução
    end

    alt Remediado
        Z->>M: Webhook (OK / Recovery)
        M->>I: Fecha o chamado, se houver
    else Falhou após N tentativas
        M->>I: Abre chamado e escala para a fila de SO
        Z->>M: Webhook (OK / Recovery) após a correção
        M->>I: Fecha o chamado
    end
```
