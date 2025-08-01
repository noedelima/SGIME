#!/bin/bash
# SGIME Plugin Auto-Setup Script
# Automatiza download e configuração dos plugins essenciais
# Versão: 1.0
#
# REFERÊNCIAS OFICIAIS:
# - Página oficial de plugins Redmine: https://www.redmine.org/plugins
# - Guia de desenvolvimento de plugins: https://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial
#
# PLUGINS UTILIZADOS:
# - redmine_dashboard: https://www.redmine.org/plugins/dashboard
# - redmine_issue_templates: https://www.redmine.org/plugins/redmine_issue_templates  
# - simple_checklists: Plugin customizado para checklists simples
#
# Para buscar novos plugins: https://www.redmine.org/plugins
# Para documentação dos plugins: consulte os repositórios individuais

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PLUGINS_DIR="plugins"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Plugins essenciais do SGIME com seus repositórios (compatíveis com Redmine 6.0)
declare -A ESSENTIAL_PLUGINS=(
    ["redmine_dashboard"]="https://github.com/jgraichen/redmine_dashboard.git"
    ["simple_checklists"]="https://github.com/Restream/redmine_simple_checklists.git"
)

# Plugins com problemas de compatibilidade (não essenciais)
declare -A PROBLEMATIC_PLUGINS=(
    ["redmine_recurring_tasks"]="https://github.com/nutso/redmine-plugin-recurring-tasks.git"
    ["redmine_issue_templates"]="https://github.com/akiko-pusu/redmine_issue_templates.git"
)

# Plugins opcionais (podem ser habilitados posteriormente)
declare -A OPTIONAL_PLUGINS=(
    ["redmine_dmsf"]="https://github.com/danmunn/redmine_dmsf.git"
    ["redmine_checklists"]="https://github.com/nodecarter/redmine_checklists.git"
    ["redmine_agile"]="https://github.com/RedmineUP/redmine_agile.git"
)

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] PLUGIN SETUP:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERRO:${NC} $1"
}

warning() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] AVISO:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"
}

# Função para baixar plugin se não existir
download_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_path="$PLUGINS_DIR/$plugin_name"
    
    if [ -d "$plugin_path" ]; then
        info "Plugin $plugin_name já existe, verificando atualizações..."
        if [ -d "$plugin_path/.git" ]; then
            cd "$plugin_path"
            git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true
            cd - > /dev/null
            log "Plugin $plugin_name atualizado"
        else
            warning "Plugin $plugin_name existe mas não é um repositório Git"
        fi
    else
        log "Baixando plugin $plugin_name de $plugin_url..."
        mkdir -p "$PLUGINS_DIR"
        if git clone "$plugin_url" "$PLUGINS_DIR/$plugin_name" 2>/dev/null; then
            log "Plugin $plugin_name baixado com sucesso"
        else
            error "Falha ao baixar plugin $plugin_name"
            return 1
        fi
    fi
}

# Função para habilitar plugin no docker compose.yml
enable_plugin_in_compose() {
    local plugin_name="$1"
    local mount_line="      - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name:Z"
    
    # Verificar se já está habilitado (linha não comentada)
    if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
        info "Plugin $plugin_name já está habilitado no docker compose.yml"
        return 0
    fi
    
    # Se existe linha comentada, descomentá-la
    if grep -q "^[[:space:]]*# - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
        sed -i "s|^[[:space:]]*# - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name|$mount_line|" "$DOCKER_COMPOSE_FILE"
        log "Plugin $plugin_name descomentado no docker compose.yml"
    else
        # Adicionar nova linha após o comentário dos plugins
        sed -i "/# Uncomment lines below to enable specific plugins:/a\\$mount_line" "$DOCKER_COMPOSE_FILE"
        log "Plugin $plugin_name adicionado ao docker compose.yml"
    fi
}

# Função para desabilitar plugin problemático
disable_plugin_in_compose() {
    local plugin_name="$1"
    
    if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
        sed -i "s|^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name|      # - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name:Z|" "$DOCKER_COMPOSE_FILE"
        warning "Plugin $plugin_name desabilitado devido a problemas de compatibilidade"
    fi
}

# Função para criar tabelas necessárias via SQL
create_plugin_tables() {
    local plugin_name="$1"
    
    case "$plugin_name" in
        "redmine_recurring_tasks")
            log "Criando tabelas para recurring_tasks..."
            docker exec -i sgime-postgres psql -U sgime_user -d sgime_production << 'EOF' || true
CREATE TABLE IF NOT EXISTS recurring_tasks (
    id SERIAL PRIMARY KEY,
    current_issue_id INTEGER,
    fixed_schedule BOOLEAN,
    interval_number INTEGER,
    interval_unit VARCHAR(255),
    interval_modifier INTEGER DEFAULT 1,
    recur_subtasks BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);
EOF
            ;;
        *)
            info "Plugin $plugin_name não requer criação manual de tabelas"
            ;;
    esac
}

# Função principal para configurar plugins essenciais
setup_essential_plugins() {
    log "Configurando plugins essenciais do SGIME..."
    
    for plugin_name in "${!ESSENTIAL_PLUGINS[@]}"; do
        local plugin_url="${ESSENTIAL_PLUGINS[$plugin_name]}"
        
        # Baixar plugin
        if download_plugin "$plugin_name" "$plugin_url"; then
            # Habilitar no docker compose
            enable_plugin_in_compose "$plugin_name"
            
            # Criar tabelas se necessário
            create_plugin_tables "$plugin_name"
        else
            warning "Falha ao configurar plugin essencial: $plugin_name"
        fi
    done
    
    # Desabilitar plugins problemáticos
    disable_plugin_in_compose "redmine_dmsf"
    
    log "Plugins essenciais configurados!"
}

# Função para baixar plugins opcionais (sem habilitar)
download_optional_plugins() {
    log "Baixando plugins opcionais (não habilitados por padrão)..."
    
    for plugin_name in "${!OPTIONAL_PLUGINS[@]}"; do
        local plugin_url="${OPTIONAL_PLUGINS[$plugin_name]}"
        download_plugin "$plugin_name" "$plugin_url" || warning "Falha ao baixar plugin opcional: $plugin_name"
    done
    
    log "Plugins opcionais baixados!"
}

# Função para executar migrações de plugins com configuração correta
migrate_plugins() {
    log "Executando migrações dos plugins..."
    if docker compose exec redmine bash -c "cd /usr/src/redmine && SECRET_KEY_BASE=\$REDMINE_SECRET_KEY_BASE bundle exec rake redmine:plugins:migrate RAILS_ENV=production" >/dev/null 2>&1; then
        log "Migrações de plugins executadas com sucesso"
    else
        warning "Erro ao executar migrações de plugins - será necessário executar manualmente"
    fi
}

# Função para verificar plugins carregados
check_loaded_plugins() {
    log "Verificando plugins carregados no Redmine..."
    if loaded_plugins=$(docker compose exec redmine bash -c "cd /usr/src/redmine && SECRET_KEY_BASE=\$REDMINE_SECRET_KEY_BASE bundle exec rails runner \"puts Redmine::Plugin.all.map(&:id)\"" 2>/dev/null | grep -v "INFO"); then
        echo -e "${GREEN}Plugins carregados:${NC}"
        echo "$loaded_plugins" | while read -r plugin; do
            if [ -n "$plugin" ]; then
                echo -e "  ${GREEN}✓${NC} $plugin"
            fi
        done
    else
        warning "Não foi possível verificar plugins carregados"
    fi
}

# Função para verificar se Docker está rodando
check_docker() {
    if ! docker ps > /dev/null 2>&1; then
        error "Docker não está rodando ou não tem permissões"
        exit 1
    fi
}

# Função para mostrar status final
show_status() {
    echo ""
    echo -e "${BLUE}=== STATUS DOS PLUGINS SGIME ===${NC}"
    echo ""
    
    echo -e "${GREEN}Plugins essenciais (compatíveis com Redmine 6.0):${NC}"
    for plugin_name in "${!ESSENTIAL_PLUGINS[@]}"; do
        if [ -d "$PLUGINS_DIR/$plugin_name" ]; then
            if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
                echo -e "  ${GREEN}✓${NC} $plugin_name (essencial - habilitado)"
            else
                echo -e "  ${YELLOW}!${NC} $plugin_name (essencial - desabilitado)"
            fi
        else
            echo -e "  ${RED}✗${NC} $plugin_name (essencial - não baixado)"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Plugins com problemas de compatibilidade:${NC}"
    for plugin_name in "${!PROBLEMATIC_PLUGINS[@]}"; do
        if [ -d "$PLUGINS_DIR/$plugin_name" ]; then
            if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
                echo -e "  ${RED}⚠${NC} $plugin_name (problemático - habilitado)"
            else
                echo -e "  ${YELLOW}!${NC} $plugin_name (problemático - desabilitado)"
            fi
        else
            echo -e "  ${YELLOW}-${NC} $plugin_name (problemático - não baixado)"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Plugins opcionais disponíveis:${NC}"
    for plugin_name in "${!OPTIONAL_PLUGINS[@]}"; do
        if [ -d "$PLUGINS_DIR/$plugin_name" ]; then
            if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
                echo -e "  ${GREEN}✓${NC} $plugin_name (opcional - habilitado)"
            else
                echo -e "  ${YELLOW}-${NC} $plugin_name (opcional - disponível)"
            fi
        else
            echo -e "  ${RED}-${NC} $plugin_name (opcional - não baixado)"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Para habilitar plugins opcionais:${NC}"
    echo -e "  ./scripts/plugin-manager.sh enable <nome_plugin>"
}

# Função principal
main() {
    log "Iniciando setup automático de plugins SGIME..."
    
    # Verificar pré-requisitos
    check_docker
    
    # Verificar se estamos no diretório correto
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        error "Execute este script no diretório raiz do SGIME"
        exit 1
    fi
    
    # Criar diretório de plugins se não existir
    mkdir -p "$PLUGINS_DIR"
    
    # Configurar plugins essenciais
    setup_essential_plugins
    
    # Baixar plugins opcionais
    download_optional_plugins
    
    # Executar migrações dos plugins
    migrate_plugins
    
    # Verificar plugins carregados
    check_loaded_plugins
    
    # Mostrar status final
    show_status
    
    echo ""
    log "Setup de plugins concluído! Execute 'docker compose restart redmine' para aplicar as alterações."
}

# Verificar argumentos
case "${1:-}" in
    "essential-only")
        log "Configurando apenas plugins essenciais..."
        setup_essential_plugins
        ;;
    "download-only")
        log "Apenas baixando plugins (sem habilitar)..."
        for plugin_name in "${!ESSENTIAL_PLUGINS[@]}"; do
            download_plugin "$plugin_name" "${ESSENTIAL_PLUGINS[$plugin_name]}"
        done
        download_optional_plugins
        ;;
    "status")
        show_status
        ;;
    *)
        main
        ;;
esac
