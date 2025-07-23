#!/bin/bash
# Script de backup dos arquivos do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

set -e

# Configurações
BACKUP_DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/backups"
FILES_BACKUP_FILE="${BACKUP_DIR}/sgime_files_${BACKUP_DATE}.tar.gz"
LOG_FILE="/var/log/sgime/backup_files.log"

# Função para log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Iniciando backup dos arquivos..."

# Verificar se os diretórios de origem existem
REDMINE_FILES_DIR="/redmine_files"
if [ ! -d "$REDMINE_FILES_DIR" ]; then
    log "AVISO: Diretório $REDMINE_FILES_DIR não encontrado"
    REDMINE_FILES_DIR=""
fi

# Criar backup dos arquivos
log "Criando backup dos arquivos do Redmine..."

# Lista de diretórios para backup
BACKUP_SOURCES=""
[ -n "$REDMINE_FILES_DIR" ] && BACKUP_SOURCES="$BACKUP_SOURCES $REDMINE_FILES_DIR"

if [ -n "$BACKUP_SOURCES" ]; then
    if tar czf "$FILES_BACKUP_FILE" $BACKUP_SOURCES 2>> "$LOG_FILE"; then
        
        # Verificar arquivo criado
        if [ -f "$FILES_BACKUP_FILE" ]; then
            BACKUP_SIZE=$(du -h "$FILES_BACKUP_FILE" | cut -f1)
            FILE_COUNT=$(tar -tzf "$FILES_BACKUP_FILE" 2>/dev/null | wc -l)
            
            log "✅ Backup dos arquivos concluído com sucesso!"
            log "📁 Arquivo: $FILES_BACKUP_FILE"
            log "📏 Tamanho: $BACKUP_SIZE"
            log "📄 Arquivos: $FILE_COUNT"
            
            # Limpeza de backups antigos
            log "Limpando backups antigos..."
            find "$BACKUP_DIR" -name "sgime_files_*.tar.gz" -type f -mtime +${BACKUP_RETENTION_DAYS:-30} -delete
            
            # Estatísticas
            TOTAL_BACKUPS=$(find "$BACKUP_DIR" -name "sgime_files_*.tar.gz" -type f | wc -l)
            log "📊 Total de backups de arquivos: $TOTAL_BACKUPS"
            
        else
            log "❌ ERRO: Arquivo de backup não foi criado"
            exit 1
        fi
    else
        log "❌ ERRO: Falha na criação do backup"
        exit 1
    fi
else
    log "⚠️  AVISO: Nenhum diretório de arquivos encontrado para backup"
    
    # Criar arquivo vazio para indicar que o backup foi executado
    touch "$FILES_BACKUP_FILE"
    echo "Backup executado em $(date) - Nenhum arquivo encontrado" > "$FILES_BACKUP_FILE"
    
    log "📝 Arquivo de status criado: $FILES_BACKUP_FILE"
fi

log "Backup dos arquivos finalizado."
