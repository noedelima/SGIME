# SGIME - Configuração Consolidada
## Sistema de Gestão Integrada de Engenharia

**Data:** 24 de Julho de 2025  
**Status:** Configuração Base Estável  
**Versão:** 1.6 - Base Limpa  

---

## 🎯 Objetivo

Esta é a configuração base consolidada do SGIME após reset e limpeza. O sistema está configurado para rodar de forma estável com:

- ✅ **Redmine 5.1** (versão estável testada)
- ✅ **PostgreSQL 16** (banco de dados principal)
- ✅ **Nginx** (proxy reverso)
- ✅ **Configurações de ambiente** essenciais

---

## 📁 Estrutura do Projeto

```
SGIME/
├── config/
│   ├── .env                    # Variáveis de ambiente principais
│   ├── nginx/                  # Configurações do Nginx
│   └── postgres/               # Configurações do PostgreSQL
├── docker-compose.yml          # Orquestração principal
├── plugins/                    # Diretório para plugins (vazio inicialmente)
└── scripts/                    # Scripts de automação
```

---

## 🔧 Configurações Essenciais

### Versões dos Serviços
- **Redmine:** 5.1 (estável, compatível com plugins)
- **PostgreSQL:** 16 (mais recente, compatível)
- **Nginx:** 1.25 (mais recente)
- **Redis:** 7 (cache opcional)

### Variáveis de Ambiente Críticas
```env
REDMINE_VERSION=5.1
POSTGRES_DB=sgime_production
POSTGRES_USER=sgime_user
REDMINE_SECRET_KEY_BASE=[chave_gerada_automaticamente]
RAILS_ENV=production
```

---

## 🚀 Comandos Essenciais

### Iniciar o Sistema
```bash
docker-compose up -d
```

### Verificar Status
```bash
docker-compose ps
docker-compose logs redmine
```

### Parar o Sistema
```bash
docker-compose down
```

### Backup do Banco
```bash
docker exec sgime_postgres pg_dump -U sgime_user sgime_production > backup.sql
```

---

## 📋 Próximos Passos

1. **Testar Sistema Base** ✅
2. **Implementar Plugins Essenciais**
   - sgime_customizations (plugin próprio)
   - Plugins compatíveis com Redmine 5.1
3. **Configurar Monitoramento**
4. **Documentar Procedimentos**

---

## 🔍 Verificações de Sistema

### Saúde dos Serviços
- **PostgreSQL:** Health check em pg_isready
- **Redmine:** Health check em HTTP 3000
- **Nginx:** Health check em HTTP 80

### Logs de Sistema
- **Redmine:** `./logs/redmine/`
- **Nginx:** `./logs/nginx/`
- **PostgreSQL:** Docker logs

---

## 📚 Documentação de Referência

- [Redmine Official Documentation](https://www.redmine.org/guide)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [SGIME Internal Documentation](./docs/)

---

**Última Atualização:** 24/07/2025 19:30  
**Responsável:** GitHub Copilot  
**Status:** ✅ Pronto para implementação de plugins  
