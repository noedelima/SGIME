#!/bin/bash
# Script de backup do banco de dados do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

set -e

# Configurações
BACKUP_DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups"
DB_BACKUP_FILE="${BACKUP_DIR}/sgime_db_${BACKUP_DATE}.sql"
LOG_FILE="/var/log/sgime/backup_db.log"

# Função para log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Iniciando backup do banco de dados..."

# Verificar variáveis de ambiente
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ] || [ -z "$POSTGRES_PASSWORD" ]; then
    log "ERRO: Variáveis de ambiente do PostgreSQL não configuradas"
    exit 1
fi

# Verificar conectividade com o banco
log "Verificando conectividade com o banco de dados..."
if ! PGPASSWORD="$POSTGRES_PASSWORD" pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then
    log "ERRO: Não foi possível conectar ao banco de dados"
    exit 1
fi

# Executar backup
log "Executando backup do banco de dados..."
if PGPASSWORD="$POSTGRES_PASSWORD" pg_dump \
    -h "$POSTGRES_HOST" \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    --verbose \
    --no-password \
    --format=custom \
    --file="$DB_BACKUP_FILE" 2>> "$LOG_FILE"; then
    
    # Comprimir backup
    log "Comprimindo backup..."
    gzip "$DB_BACKUP_FILE"
    DB_BACKUP_FILE="${DB_BACKUP_FILE}.gz"
    
    # Verificar arquivo criado
    if [ -f "$DB_BACKUP_FILE" ]; then
        BACKUP_SIZE=$(du -h "$DB_BACKUP_FILE" | cut -f1)
        log "✅ Backup do banco concluído com sucesso!"
        log "📁 Arquivo: $DB_BACKUP_FILE"
        log "📏 Tamanho: $BACKUP_SIZE"
        
        # Limpeza de backups antigos
        log "Limpando backups antigos..."
        find "$BACKUP_DIR" -name "sgime_db_*.sql.gz" -type f -mtime +${BACKUP_RETENTION_DAYS:-30} -delete
        
        # Estatísticas
        TOTAL_BACKUPS=$(find "$BACKUP_DIR" -name "sgime_db_*.sql.gz" -type f | wc -l)
        log "📊 Total de backups do banco: $TOTAL_BACKUPS"
        
    else
        log "❌ ERRO: Arquivo de backup não foi criado"
        exit 1
    fi
else
    log "❌ ERRO: Falha na execução do pg_dump"
    exit 1
fi

log "Backup do banco de dados finalizado."
