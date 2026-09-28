# 🚀 Zabbix Event-Driven Automation & Observability Pipeline

[![DevOps](https://img.shields.io/badge/DevOps-Practices-blue.svg?style=for-the-badge&logo=dev.to)](https://github.com/)
[![Zabbix](https://img.shields.io/badge/Zabbix-6.0%2F7.4-red.svg?style=for-the-badge&logo=zabbix)](https://www.zabbix.com/)
[![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000.svg?style=for-the-badge&logo=ansible)](https://www.ansible.com/)
[![Python](https://img.shields.io/badge/Python-3.10+-yellow.svg?style=for-the-badge&logo=python)](https://www.python.org/)
[![Grafana](https://img.shields.io/badge/Grafana-Observability-F46800.svg?style=for-the-badge&logo=grafana)](https://grafana.com/)
[![Docker](https://img.shields.io/badge/Docker-Containers-2496ED.svg?style=for-the-badge&logo=docker)](https://www.docker.com/)

## 📌 Visão Geral do Projeto

Este projeto é uma solução de **Automação Guiada por Eventos (Event-Driven Automation)** e **Observabilidade**, integrada ao ecossistema de monitoramento **Zabbix** e à plataforma de ITSM (**BMC Remedy**).

O objetivo principal é reduzir o **MTTR (Mean Time to Repair)** e o tempo gasto em tarefas operacionais repetitivas por meio de:
1. **Auto-remediação (Self-Healing):** Resolução automática de incidentes conhecidos (ex: reinicialização de serviços caídos) via scripts e playbooks sem intervenção humana.
2. **Abertura e Roteamento Inteligente de Chamados:** Integração via API REST com o ITSM para abertura, enriquecimento de dados, direcionamento automático para a fila responsável e encerramento de chamados após normalização.
3. **Observabilidade e Gestão de Incidentes:** Dashboards analíticos no Grafana para identificação de *flapping*, hosts mais críticos e relatórios operacionais agendados.

---

## 🛠️ Arquitetura e Fluxo de Automação
┌───────────────┐        Trigger        ┌───────────────────────┐
│ Servidor Alvo │ ────────────────────> │ Zabbix Server / Proxy │
└───────────────┘                       └───────────┬───────────┘
▲                                           │
│ Executa Ação                              │ Webhook / API
│ Remota (SSH/WinRM)                        ▼
┌───────┴──────────────┐                 ┌───────────────────────┐
│ Engine de Automação  │ <────────────── │ Python Integration    │
│ (Ansible / Python)   │   Trigger Action│ Engine (Middleware)   │
└──────────────────────┘                 └───────────┬───────────┘
│
│ REST API
▼
┌───────────────────────┐
│ ITSM (BMC Remedy)     │
│ - Abertura / Roteio   │
│ - Encerramento Auto   │
└───────────────────────┘

### 🔄 Cenários de Uso

* **Cenário A — Auto-Remediação (Self-Healing):**
  * *Evento:* Serviço crítico parado no SO (Linux/Windows).
  * *Ação:* O Zabbix dispara uma ação para a engine de automação que executa um playbook do Ansible para reiniciar o serviço. O Zabbix valida o restabelecimento e encerra o alerta.

* **Cenário B — Incidentes que Exigem Intervenção Humana:**
  * *Evento:* Alta utilização de CPU por tempo estendido ou Queda de Link.
  * *Ação:* O middleware Python processa os dados do evento, consulta as regras de roteamento e abre um chamado no Remedy na fila correta (ex: *Fila SO* ou *Fila NOC*). No caso de links, envia notificação automática ao provedor.

* **Cenário C — Encerramento Automático:**
  * *Evento:* Recuperação do incidente detectada pelo Zabbix.
  * *Ação:* O Zabbix envia um evento de recuperação (*OK*) que atualiza e encerra o chamado no ITSM.

---

## 🧰 Tecnologias Utilizadas

* **Monitoramento & Observabilidade:** Zabbix (6.x / 7.x), Grafana
* **Automação & Gestão de Configuração:** Ansible, Python 3
* **Containerização:** Docker & Docker Compose
* **Controle de Versão:** Git / GitHub
* **Integração ITSM:** BMC Remedy (REST API)

---

## 📂 Estrutura do Repositório

```text
.
├── ansible/               # Playbooks e roles do Ansible para self-healing
│   ├── playbooks/
│   └── inventory/
├── docker/                # Dockerfiles e docker-compose do ambiente local
├── integrations/          # Scripts Python de integração (Zabbix <-> ITSM)
│   ├── zabbix_to_remedy.py
│   └── utils/
├── grafana/               # Dashboards exportados (JSON) e configurações
│   └── dashboards/
├── docs/                  # Documentações técnicas e diagramas
├── .gitignore             # Proteção de segredos e arquivos locais
└── README.md              # Documentação principal

