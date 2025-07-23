#!/bin/bash
# Health check para serviço de backup do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

set -e

LOG_FILE="/var/log/sgime/backup_healthcheck.log"
BACKUP_DIR="/backups"

# Função para log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] HEALTHCHECK: $1" >> "$LOG_FILE"
}

# Verificar se o cron está rodando
if ! pgrep crond > /dev/null; then
    log "ERRO: Processo cron não está rodando"
    exit 1
fi

# Verificar se o diretório de backup existe e é gravável
if [ ! -d "$BACKUP_DIR" ]; then
    log "ERRO: Diretório de backup não existe: $BACKUP_DIR"
    exit 1
fi

if [ ! -w "$BACKUP_DIR" ]; then
    log "ERRO: Diretório de backup não é gravável: $BACKUP_DIR"
    exit 1
fi

# Verificar se houve backup recente (últimas 25 horas para backup diário)
RECENT_DB_BACKUP=$(find "$BACKUP_DIR" -name "sgime_db_*.sql.gz" -type f -mtime -1 | wc -l)
RECENT_FILES_BACKUP=$(find "$BACKUP_DIR" -name "sgime_files_*.tar.gz" -type f -mtime -1 | wc -l)

# Para backup de arquivos que é semanal, verificar últimos 8 dias
RECENT_FILES_BACKUP_WEEKLY=$(find "$BACKUP_DIR" -name "sgime_files_*.tar.gz" -type f -mtime -8 | wc -l)

# Health check é considerado OK se:
# 1. Cron está rodando
# 2. Diretório de backup existe e é gravável
# 3. Existe pelo menos um backup de banco recente OU um backup de arquivos recente

if [ "$RECENT_DB_BACKUP" -gt 0 ] || [ "$RECENT_FILES_BACKUP_WEEKLY" -gt 0 ]; then
    log "OK: Serviço de backup funcionando corretamente"
    echo "OK: Backup service healthy"
    exit 0
else
    log "AVISO: Nenhum backup recente encontrado"
    echo "WARNING: No recent backups found"
    
    # Não falhar completamente se for uma instalação nova
    TOTAL_BACKUPS=$(find "$BACKUP_DIR" -name "sgime_*.gz" -o -name "sgime_*.tar.gz" | wc -l)
    if [ "$TOTAL_BACKUPS" -eq 0 ]; then
        # Verificar se a instalação é muito recente (menos de 2 horas)
        CONTAINER_START_TIME=$(stat -c %Y /proc/1 2>/dev/null || echo 0)
        CURRENT_TIME=$(date +%s)
        CONTAINER_AGE=$((CURRENT_TIME - CONTAINER_START_TIME))
        
        if [ "$CONTAINER_AGE" -lt 7200 ]; then  # 2 horas
            log "OK: Instalação recente, aguardando primeiro backup"
            echo "OK: New installation, waiting for first backup"
            exit 0
        fi
    fi
    
    log "ERRO: Nenhum backup encontrado em instalação não recente"
    exit 1
fi
