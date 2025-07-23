# API e Integrações - SGIME

## Sistema de Gestão Integrada de Engenharia
**Colégio Pedro II - Seção de Engenharia**  
**Versão:** 1.6  
**Data:** Julho de 2025  
**Licença:** GPLv3

---

## Índice

1. [Introdução](#introdução)
2. [Autenticação da API](#autenticação-da-api)
3. [Endpoints Principais](#endpoints-principais)
4. [Integrações Externas](#integrações-externas)
5. [Webhooks](#webhooks)
6. [Exemplos de Uso](#exemplos-de-uso)
7. [SDKs e Bibliotecas](#sdks-e-bibliotecas)
8. [Limitações e Quotas](#limitações-e-quotas)

---

## Introdução

O SGIME oferece uma API REST completa baseada na API do Redmine, com extensões específicas para as necessidades da Seção de Engenharia do Colégio Pedro II.

### URL Base da API

```
https://sgime.cp2.g12.br/api/v1
```

### Formatos Suportados

- **JSON** (recomendado)
- **XML**

### Versionamento

A API utiliza versionamento semântico. A versão atual é **v1**.

---

## Autenticação da API

### Chave de API

Cada usuário possui uma chave de API única que pode ser obtida em:
`Minha Conta → Chave de acesso da API`

### Métodos de Autenticação

#### 1. Header de Autorização (Recomendado)

```http
Authorization: Bearer sua_chave_api_aqui
```

#### 2. Parâmetro na URL

```http
GET /api/v1/issues.json?key=sua_chave_api_aqui
```

#### 3. Header X-Redmine-API-Key

```http
X-Redmine-API-Key: sua_chave_api_aqui
```

---

## Endpoints Principais

### Projetos

#### Listar Projetos

```http
GET /api/v1/projects.json
```

**Parâmetros:**
- `include`: campos adicionais (trackers, issue_categories, enabled_modules)
- `limit`: limite de resultados (padrão: 25, máximo: 100)
- `offset`: deslocamento para paginação

**Resposta de Exemplo:**

```json
{
  "projects": [
    {
      "id": 1,
      "name": "Projeto Exemplo",
      "identifier": "projeto-exemplo",
      "description": "Descrição do projeto",
      "status": 1,
      "created_on": "2025-01-15T10:00:00Z",
      "updated_on": "2025-07-23T15:30:00Z"
    }
  ],
  "total_count": 1,
  "offset": 0,
  "limit": 25
}
```

#### Obter Projeto Específico

```http
GET /api/v1/projects/{id}.json
```

#### Criar Projeto

```http
POST /api/v1/projects.json
Content-Type: application/json

{
  "project": {
    "name": "Novo Projeto",
    "identifier": "novo-projeto",
    "description": "Descrição do novo projeto",
    "enabled_module_names": [
      "issue_tracking",
      "time_tracking",
      "news",
      "documents",
      "files",
      "wiki",
      "repository",
      "boards",
      "calendar",
      "gantt"
    ]
  }
}
```

### Issues (Tarefas)

#### Listar Issues

```http
GET /api/v1/issues.json
```

**Parâmetros de Filtro:**
- `project_id`: ID do projeto
- `tracker_id`: ID do tipo de issue
- `status_id`: ID do status
- `assigned_to_id`: ID do responsável
- `priority_id`: ID da prioridade
- `created_on`: data de criação (formato: YYYY-MM-DD)
- `updated_on`: data de atualização (formato: YYYY-MM-DD)

**Exemplo com Filtros:**

```http
GET /api/v1/issues.json?project_id=1&status_id=open&assigned_to_id=me
```

#### Criar Issue

```http
POST /api/v1/issues.json
Content-Type: application/json

{
  "issue": {
    "project_id": 1,
    "tracker_id": 1,
    "subject": "Nova tarefa de engenharia",
    "description": "Descrição detalhada da tarefa",
    "priority_id": 2,
    "assigned_to_id": 5,
    "start_date": "2025-07-24",
    "due_date": "2025-08-15",
    "custom_fields": [
      {
        "id": 1,
        "value": "Valor customizado"
      }
    ]
  }
}
```

#### Atualizar Issue

```http
PUT /api/v1/issues/{id}.json
Content-Type: application/json

{
  "issue": {
    "status_id": 3,
    "notes": "Atualização realizada via API",
    "private_notes": false
  }
}
```

### Usuários

#### Listar Usuários

```http
GET /api/v1/users.json
```

#### Obter Usuário Atual

```http
GET /api/v1/users/current.json
```

### Time Entries (Apontamento de Horas)

#### Listar Apontamentos

```http
GET /api/v1/time_entries.json?project_id=1&spent_on=2025-07-23
```

#### Criar Apontamento

```http
POST /api/v1/time_entries.json
Content-Type: application/json

{
  "time_entry": {
    "project_id": 1,
    "issue_id": 15,
    "hours": 2.5,
    "activity_id": 9,
    "comments": "Desenvolvimento de funcionalidade",
    "spent_on": "2025-07-23"
  }
}
```

---

## Integrações Externas

### Microsoft Entra ID (Azure AD)

O SGIME está integrado com o Microsoft Entra ID para autenticação SSO.

#### Configuração

1. Registre uma aplicação no Azure Portal
2. Configure as URLs de callback:
   - `https://sgime.cp2.g12.br/auth/azure_oauth2/callback`
3. Defina as variáveis de ambiente:

```bash
AZURE_CLIENT_ID=seu_client_id
AZURE_CLIENT_SECRET=seu_client_secret
AZURE_TENANT_ID=seu_tenant_id
```

### LDAP/Active Directory

#### Configuração LDAP

```bash
LDAP_HOST=ldap.cp2.g12.br
LDAP_PORT=389
LDAP_BASE_DN=DC=cp2,DC=g12,DC=br
LDAP_BIND_DN=CN=sgime-service,OU=Service Accounts,DC=cp2,DC=g12,DC=br
LDAP_BIND_PASSWORD=senha_service_account
```

---

## Webhooks

O SGIME suporta webhooks para notificar sistemas externos sobre eventos.

### Eventos Suportados

- `issue_created`: Nova issue criada
- `issue_updated`: Issue atualizada
- `issue_closed`: Issue fechada
- `project_created`: Novo projeto criado
- `user_created`: Novo usuário criado

### Configuração de Webhook

```http
POST /api/v1/webhooks.json
Content-Type: application/json
Authorization: Bearer sua_chave_api

{
  "webhook": {
    "url": "https://seu-sistema.exemplo.com/webhook",
    "events": ["issue_created", "issue_updated"],
    "secret": "chave_secreta_para_verificacao",
    "active": true
  }
}
```

### Payload do Webhook

```json
{
  "event": "issue_created",
  "timestamp": "2025-07-23T15:30:00Z",
  "data": {
    "issue": {
      "id": 123,
      "subject": "Nova issue",
      "project": {
        "id": 1,
        "name": "Projeto Exemplo"
      },
      "author": {
        "id": 5,
        "name": "João Silva"
      }
    }
  },
  "signature": "sha256=hash_da_assinatura"
}
```

### Verificação de Assinatura

```python
import hmac
import hashlib

def verify_webhook_signature(payload, signature, secret):
    expected_signature = hmac.new(
        secret.encode('utf-8'),
        payload.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(
        signature.replace('sha256=', ''),
        expected_signature
    )
```

---

## Exemplos de Uso

### Python

```python
import requests
import json

# Configuração
BASE_URL = "https://sgime.cp2.g12.br/api/v1"
API_KEY = "sua_chave_api_aqui"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Listar projetos
response = requests.get(f"{BASE_URL}/projects.json", headers=headers)
projects = response.json()

print(f"Total de projetos: {projects['total_count']}")

# Criar nova issue
issue_data = {
    "issue": {
        "project_id": 1,
        "tracker_id": 1,
        "subject": "Issue criada via Python",
        "description": "Descrição da issue",
        "priority_id": 2
    }
}

response = requests.post(
    f"{BASE_URL}/issues.json",
    headers=headers,
    data=json.dumps(issue_data)
)

if response.status_code == 201:
    issue = response.json()
    print(f"Issue criada com ID: {issue['issue']['id']}")
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

const sgimeAPI = axios.create({
  baseURL: 'https://sgime.cp2.g12.br/api/v1',
  headers: {
    'Authorization': 'Bearer sua_chave_api_aqui',
    'Content-Type': 'application/json'
  }
});

// Função para listar issues
async function listarIssues(projectId) {
  try {
    const response = await sgimeAPI.get('/issues.json', {
      params: { project_id: projectId }
    });
    
    return response.data.issues;
  } catch (error) {
    console.error('Erro ao listar issues:', error.response.data);
    throw error;
  }
}

// Função para criar issue
async function criarIssue(dadosIssue) {
  try {
    const response = await sgimeAPI.post('/issues.json', {
      issue: dadosIssue
    });
    
    return response.data.issue;
  } catch (error) {
    console.error('Erro ao criar issue:', error.response.data);
    throw error;
  }
}

// Exemplo de uso
(async () => {
  try {
    const issues = await listarIssues(1);
    console.log(`Encontradas ${issues.length} issues`);
    
    const novaIssue = await criarIssue({
      project_id: 1,
      tracker_id: 1,
      subject: 'Issue criada via Node.js',
      description: 'Descrição da issue'
    });
    
    console.log(`Issue criada com ID: ${novaIssue.id}`);
  } catch (error) {
    console.error('Erro:', error.message);
  }
})();
```

### cURL

```bash
#!/bin/bash

API_KEY="sua_chave_api_aqui"
BASE_URL="https://sgime.cp2.g12.br/api/v1"

# Listar projetos
curl -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     "$BASE_URL/projects.json"

# Criar issue
curl -X POST \
     -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "issue": {
         "project_id": 1,
         "tracker_id": 1,
         "subject": "Issue criada via cURL",
         "description": "Descrição da issue"
       }
     }' \
     "$BASE_URL/issues.json"
```

---

## SDKs e Bibliotecas

### Bibliotecas Recomendadas

#### Python
- `python-redmine`: Biblioteca oficial do Redmine para Python
- `requests`: Para chamadas HTTP diretas

```bash
pip install python-redmine requests
```

#### JavaScript/Node.js
- `axios`: Cliente HTTP robusto
- `redmine-js`: Wrapper para API do Redmine

```bash
npm install axios redmine-js
```

#### PHP
- `guzzlehttp/guzzle`: Cliente HTTP para PHP
- `kbsali/redmine-api`: Wrapper para API do Redmine

```bash
composer require guzzlehttp/guzzle kbsali/redmine-api
```

---

## Limitações e Quotas

### Rate Limiting

- **Limite por usuário**: 1000 requisições por hora
- **Limite por IP**: 5000 requisições por hora
- **Limite para webhooks**: 100 requisições por minuto

### Headers de Rate Limit

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 995
X-RateLimit-Reset: 1690196400
```

### Tamanhos Máximos

- **Payload da requisição**: 10MB
- **Upload de arquivos**: 100MB
- **Número de issues por requisição**: 100
- **Timeout de requisição**: 30 segundos

### Paginação

- **Limite padrão**: 25 itens
- **Limite máximo**: 100 itens por página
- **Offset máximo**: 10000

---

## Códigos de Erro

| Código | Significado | Descrição |
|--------|-------------|-----------|
| 200 | OK | Requisição bem-sucedida |
| 201 | Created | Recurso criado com sucesso |
| 400 | Bad Request | Parâmetros inválidos |
| 401 | Unauthorized | Chave de API inválida ou expirada |
| 403 | Forbidden | Sem permissão para o recurso |
| 404 | Not Found | Recurso não encontrado |
| 422 | Unprocessable Entity | Dados de entrada inválidos |
| 429 | Too Many Requests | Rate limit excedido |
| 500 | Internal Server Error | Erro interno do servidor |

### Exemplo de Resposta de Erro

```json
{
  "error": {
    "code": 422,
    "message": "Validation failed",
    "details": [
      "Subject can't be blank",
      "Project must exist"
    ]
  }
}
```

---

## Suporte e Recursos Adicionais

### Documentação Oficial
- **Redmine API**: https://www.redmine.org/projects/redmine/wiki/Rest_api
- **SGIME Docs**: https://sgime.cp2.g12.br/docs

### Contato Técnico
- **E-mail**: geeng@cp2.g12.br
- **Telefone**: (21) 2569-1234 (Ramal: 5678)

### Ambiente de Testes
- **URL**: https://sgime-dev.cp2.g12.br
- **Credenciais de teste disponíveis mediante solicitação**

---

**Última atualização:** 23 de julho de 2025  
**Versão do documento:** 1.6.0

---

*Este documento é parte da documentação oficial do SGIME - Sistema de Gestão Integrada de Engenharia do Colégio Pedro II. Para sugestões e correções, entre em contato com a Seção de Engenharia.*
