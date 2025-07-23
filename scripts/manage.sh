#!/bin/bash
# Script de Gerenciamento do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia
# Versão: 1.6

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SGIME:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERRO:${NC} $1"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] AVISO:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Verificar se Docker Compose está disponível
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
else
    error "Docker Compose não encontrado. Instale docker-compose ou docker compose plugin."
fi

# Verificar se estamos no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    error "Arquivo docker-compose.yml não encontrado. Execute este script no diretório raiz do SGIME."
fi

# Função para mostrar ajuda
show_help() {
    echo "
╔══════════════════════════════════════════════════════════════════╗
║                     SGIME - Gerenciamento                       ║
║           Sistema de Gestão Integrada de Engenharia             ║
╚══════════════════════════════════════════════════════════════════╝

Uso: $0 [COMANDO]

COMANDOS DISPONÍVEIS:

  start          Iniciar todos os serviços do SGIME
  stop           Parar todos os serviços do SGIME  
  restart        Reiniciar todos os serviços do SGIME
  status         Verificar status dos serviços
  logs           Visualizar logs em tempo real
  logs-service   Visualizar logs de um serviço específico
  
  backup         Fazer backup completo do sistema
  backup-db      Fazer backup apenas do banco de dados
  backup-files   Fazer backup apenas dos arquivos
  
  restore        Restaurar backup completo
  restore-db     Restaurar backup do banco de dados
  
  update         Atualizar sistema para nova versão
  reset          Resetar sistema (CUIDADO: remove todos os dados)
  
  shell          Acessar shell do container Redmine
  db-shell       Acessar shell do PostgreSQL
  
  help           Mostrar esta ajuda

EXEMPLOS:

  $0 start                    # Iniciar o sistema
  $0 logs redmine            # Ver logs do Redmine
  $0 backup                  # Fazer backup completo
  $0 restore backup.tar.gz   # Restaurar backup

Para mais informações, consulte o README.md
"
}

# Função para iniciar serviços
start_services() {
    log "Iniciando serviços do SGIME..."
    $DOCKER_COMPOSE_CMD up -d
    
    # Aguardar inicialização
    sleep 10
    
    log "Verificando status dos serviços..."
    $DOCKER_COMPOSE_CMD ps
    
    # Verificar se o Redmine está respondendo
    log "Testando conectividade..."
    for i in {1..12}; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/ | grep -q "200\|302"; then
            log "✅ SGIME iniciado com sucesso!"
            info "Acesse: https://localhost"
            return 0
        fi
        log "Aguardando serviços ficarem prontos... ($i/12)"
        sleep 10
    done
    
    warning "Serviços iniciados, mas podem ainda estar inicializando. Verifique os logs."
}

# Função para parar serviços
stop_services() {
    log "Parando serviços do SGIME..."
    $DOCKER_COMPOSE_CMD down
    log "✅ Serviços parados com sucesso!"
}

# Função para reiniciar serviços
restart_services() {
    log "Reiniciando serviços do SGIME..."
    $DOCKER_COMPOSE_CMD restart
    log "✅ Serviços reiniciados com sucesso!"
}

# Função para verificar status
check_status() {
    log "Status dos serviços do SGIME:"
    echo
    $DOCKER_COMPOSE_CMD ps
    echo
    
    # Verificar conectividade
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/ | grep -q "200\|302"; then
        echo -e "${GREEN}✅ Sistema acessível em: https://localhost${NC}"
    else
        echo -e "${RED}❌ Sistema não está respondendo${NC}"
    fi
}

# Função para visualizar logs
show_logs() {
    if [ -n "$2" ]; then
        log "Mostrando logs do serviço: $2"
        $DOCKER_COMPOSE_CMD logs -f "$2"
    else
        log "Mostrando logs de todos os serviços..."
        $DOCKER_COMPOSE_CMD logs -f
    fi
}

# Função para backup completo
backup_full() {
    local backup_date=$(date +"%Y%m%d_%H%M%S")
    local backup_file="backups/sgime_backup_${backup_date}.tar.gz"
    
    log "Iniciando backup completo..."
    
    # Criar diretório temporário
    local temp_dir="backups/temp_${backup_date}"
    mkdir -p "$temp_dir"
    
    # Backup do banco de dados
    log "Fazendo backup do banco de dados..."
    $DOCKER_COMPOSE_CMD exec -T postgres pg_dump -U sgime_user sgime_production > "$temp_dir/database.sql"
    
    # Backup dos arquivos do Redmine
    log "Fazendo backup dos arquivos..."
    $DOCKER_COMPOSE_CMD exec -T redmine tar czf - /usr/src/redmine/files > "$temp_dir/redmine_files.tar.gz"
    
    # Backup das configurações
    log "Fazendo backup das configurações..."
    cp -r config "$temp_dir/"
    
    # Criar arquivo tar.gz final
    log "Compactando backup..."
    tar czf "$backup_file" -C "$temp_dir" .
    
    # Limpar diretório temporário
    rm -rf "$temp_dir"
    
    log "✅ Backup completo salvo em: $backup_file"
    info "Tamanho: $(du -h "$backup_file" | cut -f1)"
}

# Função para backup do banco
backup_db() {
    local backup_date=$(date +"%Y%m%d_%H%M%S")
    local backup_file="backups/sgime_db_${backup_date}.sql"
    
    log "Fazendo backup do banco de dados..."
    $DOCKER_COMPOSE_CMD exec -T postgres pg_dump -U sgime_user sgime_production > "$backup_file"
    
    log "✅ Backup do banco salvo em: $backup_file"
    info "Tamanho: $(du -h "$backup_file" | cut -f1)"
}

# Função para backup dos arquivos
backup_files() {
    local backup_date=$(date +"%Y%m%d_%H%M%S")
    local backup_file="backups/sgime_files_${backup_date}.tar.gz"
    
    log "Fazendo backup dos arquivos..."
    $DOCKER_COMPOSE_CMD exec -T redmine tar czf - /usr/src/redmine/files > "$backup_file"
    
    log "✅ Backup dos arquivos salvo em: $backup_file"
    info "Tamanho: $(du -h "$backup_file" | cut -f1)"
}

# Função para restaurar backup completo
restore_backup() {
    if [ -z "$2" ]; then
        error "Especifique o arquivo de backup: $0 restore <arquivo_backup.tar.gz>"
    fi
    
    local backup_file="$2"
    
    if [ ! -f "$backup_file" ]; then
        error "Arquivo de backup não encontrado: $backup_file"
    fi
    
    warning "⚠️  ATENÇÃO: Esta operação irá SOBRESCREVER todos os dados atuais!"
    read -p "Tem certeza que deseja continuar? Digite 'CONFIRMO' para prosseguir: " -r
    
    if [ "$REPLY" != "CONFIRMO" ]; then
        log "Operação cancelada pelo usuário."
        exit 0
    fi
    
    log "Iniciando restauração do backup: $backup_file"
    
    # Parar serviços
    log "Parando serviços..."
    $DOCKER_COMPOSE_CMD down
    
    # Extrair backup
    local temp_dir="backups/restore_temp"
    mkdir -p "$temp_dir"
    tar xzf "$backup_file" -C "$temp_dir"
    
    # Iniciar apenas o banco para restauração
    log "Iniciando banco de dados..."
    $DOCKER_COMPOSE_CMD up -d postgres
    sleep 10
    
    # Restaurar banco
    log "Restaurando banco de dados..."
    $DOCKER_COMPOSE_CMD exec -T postgres psql -U sgime_user -d sgime_production < "$temp_dir/database.sql"
    
    # Iniciar Redmine
    log "Iniciando Redmine..."
    $DOCKER_COMPOSE_CMD up -d redmine
    sleep 15
    
    # Restaurar arquivos
    if [ -f "$temp_dir/redmine_files.tar.gz" ]; then
        log "Restaurando arquivos..."
        $DOCKER_COMPOSE_CMD exec -T redmine tar xzf - -C / < "$temp_dir/redmine_files.tar.gz"
    fi
    
    # Restaurar configurações
    if [ -d "$temp_dir/config" ]; then
        log "Restaurando configurações..."
        cp -r "$temp_dir/config/"* config/
    fi
    
    # Iniciar todos os serviços
    log "Iniciando todos os serviços..."
    $DOCKER_COMPOSE_CMD up -d
    
    # Limpar arquivos temporários
    rm -rf "$temp_dir"
    
    log "✅ Restauração concluída com sucesso!"
}

# Função para acessar shell do Redmine
redmine_shell() {
    log "Acessando shell do container Redmine..."
    $DOCKER_COMPOSE_CMD exec redmine bash
}

# Função para acessar shell do PostgreSQL
db_shell() {
    log "Acessando shell do PostgreSQL..."
    $DOCKER_COMPOSE_CMD exec postgres psql -U sgime_user -d sgime_production
}

# Função para resetar sistema
reset_system() {
    warning "⚠️  ATENÇÃO: Esta operação irá REMOVER TODOS OS DADOS permanentemente!"
    warning "Isso inclui banco de dados, arquivos, configurações e volumes Docker."
    echo
    read -p "Tem certeza? Digite 'RESET_TUDO' para confirmar: " -r
    
    if [ "$REPLY" != "RESET_TUDO" ]; then
        log "Operação cancelada pelo usuário."
        exit 0
    fi
    
    log "Parando e removendo todos os containers..."
    $DOCKER_COMPOSE_CMD down -v --remove-orphans
    
    log "Removendo volumes Docker..."
    docker volume prune -f
    
    log "Removendo arquivos de dados locais..."
    rm -rf data/
    rm -rf logs/
    
    log "✅ Sistema resetado completamente!"
    info "Execute './scripts/install.sh' para reinstalar o sistema."
}

# Função principal
main() {
    case "${1:-help}" in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        status)
            check_status
            ;;
        logs)
            show_logs "$@"
            ;;
        logs-service)
            show_logs "$@"
            ;;
        backup)
            backup_full
            ;;
        backup-db)
            backup_db
            ;;
        backup-files)
            backup_files
            ;;
        restore)
            restore_backup "$@"
            ;;
        shell)
            redmine_shell
            ;;
        db-shell)
            db_shell
            ;;
        reset)
            reset_system
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Comando desconhecido: $1"
            echo "Use '$0 help' para ver os comandos disponíveis."
            ;;
    esac
}

# Verificar se não há argumentos e mostrar help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Executar função principal
main "$@"
