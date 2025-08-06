# COMANDOS RÁPIDOS - Continuação Amanhã

## Para retomar rapidamente:
```bash
cd /home/noedelima/source/SGIME
./retomar-tarefas-recorrentes.sh
```

## Para implementar versão corrigida:
```bash
# Backup da configuração atual
cp docker-compose.yml docker-compose-4plugins.backup

# Editar docker-compose.yml - adicionar linha:
#   - ./plugins/redmine_recurring_tasks_clean:/usr/src/redmine/plugins/recurring_tasks

# Restart system
docker compose down
docker compose up -d

# Verificar logs
docker compose logs redmine --tail 20
```

## Para verificar o sistema:
```bash
docker compose ps
curl -I http://localhost:3000
```

## Arquivos importantes:
- `CHECKPOINT-TAREFAS-RECORRENTES.md` - Status completo
- `plugins/redmine_recurring_tasks_clean/` - Plugin corrigido 
- `docker-compose.yml` - Configuração atual estável
