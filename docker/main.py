from fastapi import FastAPI

app = FastAPI(title="Zabbix Automation Middleware")

@app.get("/")
def home():
    return {"status": "ok", "message": "API de Automação Ativa!"}

@app.post("/webhook")
def receive_webhook(payload: dict):
    print("Recebido evento do Zabbix:", payload)
    # Futuramente aqui você chama as playbooks do Ansible
    return {
        "status": "success",
        "action": "webhook_received",
        "data": payload
    }
