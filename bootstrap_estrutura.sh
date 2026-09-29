#!/usr/bin/env bash
# =============================================================================
# bootstrap_estrutura.sh
# Cria a estrutura de pastas e arquivos placeholder do projeto zabbix-devops.
#
# Uso (na raiz do repositório):
#   bash bootstrap_estrutura.sh          # cria na pasta atual
#   bash bootstrap_estrutura.sh /caminho # cria em outra pasta
#
# Seguro para rodar mais de uma vez: NUNCA sobrescreve arquivos que já existem.
# No Windows, rode pelo Git Bash ou WSL.
# =============================================================================
set -euo pipefail

ROOT="${1:-.}"
CRIADOS=0
EXISTENTES=0

# put <caminho-relativo>  (conteúdo via stdin; só cria se o arquivo não existir)
put() {
  local f="$ROOT/$1"
  mkdir -p "$(dirname "$f")"
  if [ -e "$f" ]; then
    cat >/dev/null
    EXISTENTES=$((EXISTENTES + 1))
    echo "  = já existe: $1"
  else
    cat >"$f"
    CRIADOS=$((CRIADOS + 1))
    echo "  + criado:    $1"
  fi
}

# vazio <caminho-relativo>  (cria arquivo vazio)
vazio() { put "$1" </dev/null; }

echo "Criando estrutura em: $(cd "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"
mkdir -p "$ROOT"

# =============================================================================
# RAIZ
# =============================================================================
echo
echo "== Raiz =="

put ".gitignore" <<'EOF'
# --- Segredos (NUNCA versionar) ---
.env
.env.*
!.env.example
*.pem
*.key
.vault_pass*
vault_pass*
*.vault-password

# --- Python ---
.venv/
venv/
__pycache__/
*.pyc
.pytest_cache/
.ruff_cache/
.mypy_cache/
*.egg-info/

# --- Ansible ---
*.retry
.ansible/

# --- Estado local e logs da engine ---
*.db
*.sqlite
*.sqlite3
*.log
logs/
state/

# --- Editor / SO ---
.vscode/
.idea/
.DS_Store
Thumbs.db
EOF

put ".gitattributes" <<'EOF'
# Evita problemas de quebra de linha ao alternar entre Windows e Linux
* text=auto
*.sh text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.py text eol=lf
EOF

put ".env.example" <<'EOF'
# Copie para .env e preencha. NUNCA commite o .env real.

# --- Zabbix ---
ZABBIX_URL=https://zabbix.exemplo.local
ZABBIX_API_TOKEN=troque-me

# --- BMC Remedy (usar ambiente de TESTE durante o desenvolvimento) ---
REMEDY_BASE_URL=https://remedy-teste.exemplo.local
REMEDY_USER=troque-me
REMEDY_PASSWORD=troque-me

# --- SMTP (e-mail ao ISP e relatórios) ---
SMTP_HOST=smtp.exemplo.local
SMTP_PORT=25
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=automacao@exemplo.local

# --- Engine ---
ENGINE_PORT=8080
LOG_LEVEL=INFO
STATE_DB_PATH=./state/engine.sqlite3

# --- Ansible ---
ANSIBLE_INVENTORY=ansible/inventories/lab/hosts.yml
EOF

put "requirements.txt" <<'EOF'
# Dependências de execução da engine (fixe as versões quando escolher o framework web).
# Exemplos, a definir: fastapi / flask, requests, pyyaml, python-dotenv, ansible-runner
EOF

put "requirements-dev.txt" <<'EOF'
-r requirements.txt
# Ferramentas de desenvolvimento, a definir: pytest, ruff, ansible-lint
EOF

put "Makefile" <<'EOF'
# Atalhos opcionais (preencher conforme o projeto crescer).
# Exemplos futuros: make lint, make test, make run
EOF

put "README.md" <<'EOF'
# Zabbix Event-Driven Automation & Observability Pipeline

(Placeholder criado pelo bootstrap. Substitua pelo README do projeto.)
EOF

# =============================================================================
# .github
# =============================================================================
echo
echo "== .github =="

# ATENÇÃO: não criar README.md dentro de .github/ (o GitHub o exibiria no lugar
# do README da raiz) nem dentro de .github/ISSUE_TEMPLATE/ (apareceria como
# modelo de issue). Por isso a explicação fica em LEIAME.md.
put ".github/LEIAME.md" <<'EOF'
# .github

Configurações do GitHub para o repositório.

- `ISSUE_TEMPLATE/`: modelos de issue (arquivos `.md` ou `.yml`). Tudo o que
  estiver lá aparece como opção ao clicar em "New issue". Por isso **não** coloque
  README dentro dessa pasta. Modelo atual: `nova-automacao.md` (fila de automações).
- `workflows/`: pipelines do GitHub Actions (`.yml`). Ainda vazio; os workflows de
  lint/testes entram no M6.

Obs.: este arquivo se chama LEIAME.md de propósito. Um `README.md` dentro de
`.github/` teria prioridade sobre o README da raiz na página do repositório.
EOF

put ".github/ISSUE_TEMPLATE/nova-automacao.md" <<'EOF'
---
name: Nova automação
about: Automatizar um trigger para um tipo de equipamento
title: "[Automação] <tipo> - <trigger>"
labels: automacao
---

## Tipo e nível alvo
(ex.: Windows, N2)

## Trigger
(qual trigger do Zabbix)

## Ação
(o que o playbook/rotina faz)

## Guardrails
(limite de tentativas, cooldown, condições para NÃO agir)

## Pronto quando
- [ ] Trigger de teste disparado
- [ ] Ação executada com sucesso
- [ ] Chamado aberto/fechado na fila correta
- [ ] Matriz de cobertura atualizada (`docs/matriz-cobertura.md`)
EOF

put ".github/workflows/README.md" <<'EOF'
# .github/workflows

Pipelines do GitHub Actions (arquivos `.yml`).

Ainda vazio. Planejado para o M6: lint de Python (ruff), lint de Ansible
(ansible-lint) e execução dos testes de `engine/tests/`.
Só adicione um workflow quando ele estiver completo: um `.yml` incompleto aqui
aparece como "falha" na aba Actions.
EOF

# =============================================================================
# ANSIBLE
# =============================================================================
echo
echo "== ansible =="

put "ansible/README.md" <<'EOF'
# ansible

Tudo o que o Ansible precisa para executar as remediações e diagnósticos.

- `ansible.cfg`: configuração local do Ansible.
- `requirements.yml`: collections necessárias (`ansible-galaxy collection install -r requirements.yml`).
- `inventories/`: hosts e variáveis, separados por ambiente (`lab` e `prod`).
- `playbooks/`: playbooks organizados por tipo de equipamento.

Regra de ouro: rode primeiro no `lab`. Segredos ficam no Ansible Vault ou no `.env`, nunca em texto puro aqui.
EOF

put "ansible/ansible.cfg" <<'EOF'
[defaults]
# Inventário padrão: laboratório. Para produção, passe -i explicitamente.
inventory = inventories/lab/hosts.yml
retry_files_enabled = False
EOF

put "ansible/requirements.yml" <<'EOF'
---
# Collections do Ansible. Ajuste conforme o fabricante dos equipamentos de rede
# e o método de acesso ao banco (ver docs/adr/ e docs/matriz-cobertura.md).
collections: []
# Exemplos, a confirmar:
#   - name: ansible.windows
#   - name: community.windows
#   - name: ansible.netcommon
#   - name: community.general
EOF

put "ansible/inventories/README.md" <<'EOF'
# ansible/inventories

Inventários separados por ambiente:

- `lab/`: servidores de teste. Aqui se desenvolve e valida tudo.
- `prod/`: produção. Só a estrutura; nada de senha em texto puro (use Ansible Vault).

Cada ambiente tem `hosts.yml` (hosts agrupados por tipo: linux, windows, network, database)
e `group_vars/` com as variáveis de cada grupo.
EOF

put "ansible/inventories/lab/README.md" <<'EOF'
# ansible/inventories/lab

Inventário do laboratório.

- `hosts.yml`: hosts de teste, agrupados por tipo (`linux`, `windows`, `network`, `database`).
- `group_vars/`: variáveis por grupo (usuário de conexão, método, portas).

Não commite senhas. Use Ansible Vault ou variáveis de ambiente.
EOF

put "ansible/inventories/lab/hosts.yml" <<'EOF'
---
all:
  children:
    linux: {}
    windows: {}
    network: {}
    database: {}
EOF

put "ansible/inventories/lab/group_vars/README.md" <<'EOF'
# group_vars (lab)

Um arquivo `.yml` por grupo de tipo, com as variáveis de conexão:

- `all.yml`: valores comuns.
- `linux.yml`: SSH, usuário, become.
- `windows.yml`: WinRM (porta, transporte).
- `network.yml`: método de acesso (ex.: network_cli), usuário somente leitura.
- `database.yml`: usuário/método de acesso ao banco (somente leitura).

Valores sensíveis devem ficar criptografados com Ansible Vault.
EOF

for g in all linux windows network database; do
  put "ansible/inventories/lab/group_vars/$g.yml" <<'EOF'
---
# Variáveis deste grupo. Segredos: use Ansible Vault.
EOF
done

put "ansible/inventories/prod/README.md" <<'EOF'
# ansible/inventories/prod

Inventário de PRODUÇÃO. Só use depois de validar tudo no `lab`.

- Mantenha aqui apenas estrutura e hosts. Credenciais sempre no Ansible Vault.
- Rede e banco começam em modo somente leitura (nível N1).
EOF

put "ansible/inventories/prod/hosts.yml" <<'EOF'
---
all:
  children:
    linux: {}
    windows: {}
    network: {}
    database: {}
EOF

put "ansible/playbooks/README.md" <<'EOF'
# ansible/playbooks

Playbooks organizados por tipo de equipamento:

- `linux/`, `windows/`: remediações (ex.: reinício de serviço).
- `network/`, `database/`: diagnósticos somente leitura (nível N1).

Convenções: nomes em minúsculas com underscore (`restart_service.yml`), parâmetros por
variáveis (ex.: `service_name`) e sempre idempotentes.
EOF

put "ansible/playbooks/linux/README.md" <<'EOF'
# playbooks/linux

Playbooks para servidores Linux (SSH). Remediações como reinício de serviço, limpeza de disco.
Arquivos `.yml` parametrizados por variável (ex.: `service_name`).
EOF

put "ansible/playbooks/linux/restart_service.yml" <<'EOF'
---
# Reinicia um serviço Linux e valida o resultado. (placeholder)
EOF

put "ansible/playbooks/windows/README.md" <<'EOF'
# playbooks/windows

Playbooks para servidores Windows (WinRM). Remediações como reinício de serviço (ex.: Spooler).
Arquivos `.yml` parametrizados por variável.
EOF

put "ansible/playbooks/windows/restart_service.yml" <<'EOF'
---
# Reinicia um serviço Windows e valida o resultado. (placeholder)
EOF

put "ansible/playbooks/network/README.md" <<'EOF'
# playbooks/network

Roteadores e switches. Aqui só entram playbooks de DIAGNÓSTICO somente leitura
(estado de interface, erros, vizinhança). Nada que altere configuração sem aprovação.
EOF

put "ansible/playbooks/network/diag_interface.yml" <<'EOF'
---
# Coleta diagnóstico de interface/link (somente leitura). (placeholder)
EOF

put "ansible/playbooks/database/README.md" <<'EOF'
# playbooks/database

Bancos de dados. Aqui só entram rotinas de DIAGNÓSTICO somente leitura
(status do listener, uso de tablespace, sessões). Ações que alterem o banco
exigem aprovação do DBA e ficam para o Backlog.
EOF

put "ansible/playbooks/database/diag_basico.yml" <<'EOF'
---
# Diagnóstico básico do banco (somente leitura). (placeholder)
EOF

# =============================================================================
# ZABBIX
# =============================================================================
echo
echo "== zabbix =="

put "zabbix/README.md" <<'EOF'
# zabbix

Tudo o que é configurado dentro do Zabbix e precisa estar versionado:
templates, media types (webhook) e actions. Assim o ambiente pode ser recriado
e as mudanças ficam rastreáveis.
EOF

put "zabbix/templates/README.md" <<'EOF'
# zabbix/templates

Exports de templates do Zabbix (`.yaml` ou `.json`). Exporte pelo frontend
(Data collection > Templates > Export) e commite o arquivo.
EOF

put "zabbix/media_types/README.md" <<'EOF'
# zabbix/media_types

Media types do tipo Webhook: o script JavaScript que envia o evento para a engine
e o export do media type. Guarde aqui o `.js` e o `.yaml`/`.json` exportado.
EOF

put "zabbix/media_types/webhook_engine.js" <<'EOF'
// Script do Webhook do Zabbix que envia o evento para a engine. (placeholder)
EOF

put "zabbix/actions/README.md" <<'EOF'
# zabbix/actions

Documentação/export das Actions do Zabbix (condições e operações que disparam
a remediação ou o webhook). Use `.yaml`/`.json` exportados ou um `.md` descrevendo
a configuração quando o export não for possível.
EOF

# =============================================================================
# ENGINE (antigo "integrations")
# =============================================================================
echo
echo "== engine =="

put "engine/README.md" <<'EOF'
# engine

O "despachante" do projeto (Python): recebe o evento do Zabbix, aplica as regras,
aciona o Ansible, abre/fecha chamados no Remedy e envia e-mails.

- `src/engine/`: código (pacote Python).
- `rules/`: regras em YAML, uma por tipo de equipamento.
- `tests/`: testes automatizados.

Adicionar uma automação nova = uma regra em `rules/` + um playbook em `ansible/playbooks/`.
EOF

put "engine/src/README.md" <<'EOF'
# engine/src

Raiz do código-fonte (layout "src"). Contém apenas o pacote `engine/`.
EOF

put "engine/src/engine/README.md" <<'EOF'
# engine/src/engine

Pacote Python principal. Um módulo por responsabilidade:

- `app.py`: recebe o webhook do Zabbix.
- `config.py`: lê configurações do `.env`.
- `rules.py`: carrega e aplica as regras de `engine/rules/`.
- `state.py`: estado (evento ↔ chamado, tentativas, cooldown).
- `actions/`: integrações com o mundo externo (Ansible, Remedy, e-mail).

Evite um `utils.py` genérico: prefira módulos com nome que diga o que fazem.
EOF

put "engine/src/engine/__init__.py" <<'EOF'
"""Engine de automação Zabbix."""
EOF

put "engine/src/engine/app.py" <<'EOF'
"""Recebe o webhook do Zabbix. (placeholder)"""
EOF

put "engine/src/engine/config.py" <<'EOF'
"""Leitura de configurações a partir do .env. (placeholder)"""
EOF

put "engine/src/engine/rules.py" <<'EOF'
"""Carrega e aplica as regras de engine/rules/. (placeholder)"""
EOF

put "engine/src/engine/state.py" <<'EOF'
"""Estado: vínculo evento-chamado, tentativas e cooldown. (placeholder)"""
EOF

put "engine/src/engine/actions/README.md" <<'EOF'
# engine/src/engine/actions

Módulos que executam ações no mundo externo:

- `ansible_runner.py`: executa playbooks do Ansible.
- `remedy.py`: abre, atualiza e fecha chamados no BMC Remedy.
- `mailer.py`: envia e-mails (ex.: aviso ao ISP).

Cada módulo expõe funções simples e trata seus próprios erros.
EOF

put "engine/src/engine/actions/__init__.py" <<'EOF'
"""Ações externas da engine."""
EOF

put "engine/src/engine/actions/ansible_runner.py" <<'EOF'
"""Executa playbooks do Ansible. (placeholder)"""
EOF

put "engine/src/engine/actions/remedy.py" <<'EOF'
"""Integração com a API REST do BMC Remedy. (placeholder)"""
EOF

put "engine/src/engine/actions/mailer.py" <<'EOF'
"""Envio de e-mails via SMTP. (placeholder)"""
EOF

put "engine/rules/README.md" <<'EOF'
# engine/rules

Regras de automação em YAML, um arquivo por tipo de equipamento:
`linux.yml`, `windows.yml`, `network.yml`, `database.yml`.

Cada regra liga um trigger a uma ação: playbook a executar, variáveis, fila do Remedy,
nível de automação (N0/N1/N2) e guardrails (limite de tentativas, cooldown).
EOF

for t in linux windows network database; do
  put "engine/rules/$t.yml" <<'EOF'
---
# Regras deste tipo de equipamento. (placeholder)
rules: []
EOF
done

put "engine/tests/README.md" <<'EOF'
# engine/tests

Testes automatizados (pytest). Comece pela lógica de regras e guardrails,
que dá para testar sem nenhum servidor. Arquivos `test_*.py`.
EOF

put "engine/tests/__init__.py" <<'EOF'
EOF

put "engine/tests/test_rules.py" <<'EOF'
"""Testes das regras e guardrails. (placeholder)"""
EOF

# =============================================================================
# GRAFANA
# =============================================================================
echo
echo "== grafana =="

put "grafana/README.md" <<'EOF'
# grafana

Configuração versionada do Grafana: dashboards e datasource.
EOF

put "grafana/dashboards/README.md" <<'EOF'
# grafana/dashboards

Dashboards exportados em JSON (Top hosts com incidentes, Flapping, MTTR).
Exporte pelo Grafana ("Export > Export as JSON") e commite o arquivo.
EOF

put "grafana/provisioning/README.md" <<'EOF'
# grafana/provisioning

Arquivos de provisionamento do Grafana (`.yml`), para subir o ambiente já com
datasource e dashboards configurados.
EOF

put "grafana/provisioning/datasources/README.md" <<'EOF'
# grafana/provisioning/datasources

Definição do datasource do Zabbix (`.yml`). Não coloque token/senha aqui:
use variáveis de ambiente.
EOF

# =============================================================================
# DOCKER
# =============================================================================
echo
echo "== docker =="

put "docker/README.md" <<'EOF'
# docker

Ambiente local via Docker Compose (ex.: Grafana e a engine).

- `docker-compose.yml`: serviços do ambiente.
- `engine/`: Dockerfile da engine.
EOF

put "docker/docker-compose.yml" <<'EOF'
# Serviços do ambiente local. (placeholder)
services: {}
EOF

put "docker/engine/README.md" <<'EOF'
# docker/engine

Dockerfile da engine em Python. Constrói a imagem a partir de `engine/` e `requirements.txt`.
EOF

put "docker/engine/Dockerfile" <<'EOF'
# Imagem da engine. (placeholder)
EOF

# =============================================================================
# DOCS
# =============================================================================
echo
echo "== docs =="

put "docs/README.md" <<'EOF'
# docs

Documentação do projeto.

- `architecture/`: diagramas e visão geral.
- `adr/`: decisões de arquitetura (uma por arquivo, numeradas).
- `runbooks/`: procedimentos operacionais (o que fazer quando algo falha).
- `matriz-cobertura.md`: status de cada tipo de equipamento (monitoramento, diagnóstico, remediação).
- `remedy-mapeamento.md`: mapeamento entre campos do Remedy e do evento Zabbix.
EOF

put "docs/architecture/README.md" <<'EOF'
# docs/architecture

Diagramas (Mermaid `.md`, `.png` ou `.svg`) e texto de visão geral da arquitetura.
EOF

put "docs/adr/README.md" <<'EOF'
# docs/adr

ADRs (Architecture Decision Records): uma decisão por arquivo, numerada
(`0001-titulo.md`). Estrutura sugerida: Contexto, Decisão, Consequências.
EOF

put "docs/adr/0001-arquitetura-de-disparo.md" <<'EOF'
# 0001: Arquitetura de disparo da remediação

Status: a decidir

## Contexto
Remote Command/Action direto no Zabbix vs. Webhook → Python → Ansible.

## Decisão
(a preencher)

## Consequências
(a preencher)
EOF

put "docs/adr/0002-niveis-de-automacao.md" <<'EOF'
# 0002: Níveis de automação por tipo de equipamento

Status: a decidir

## Contexto
N0: só abre chamado. N1: chamado com diagnóstico anexado. N2: remediação automática.

## Decisão
(a preencher: nível inicial por tipo e critérios para subir de nível)

## Consequências
(a preencher)
EOF

put "docs/runbooks/README.md" <<'EOF'
# docs/runbooks

Procedimentos operacionais em `.md`: o que fazer quando a automação falha,
como desligá-la com segurança, como adicionar uma nova automação.
EOF

put "docs/matriz-cobertura.md" <<'EOF'
# Matriz de cobertura por tipo de equipamento

| Tipo | Monitorado | Evento chega na engine | Diagnóstico | Remediação | Nível atual |
|---|---|---|---|---|---|
| Linux | | | | | |
| Windows | | | | | |
| Roteador | | | | | |
| Switch | | | | | |
| Banco de dados | | | | | |
EOF

put "docs/remedy-mapeamento.md" <<'EOF'
# Mapeamento de campos: Zabbix ↔ BMC Remedy

| Campo Remedy | Obrigatório | Origem no evento Zabbix |
|---|---|---|
| | | |
EOF

# =============================================================================
echo
echo "Concluído: $CRIADOS criado(s), $EXISTENTES já existente(s) (mantidos)."
echo "Próximo passo: git add -A && git commit -m 'chore: estrutura inicial do repositório'"
