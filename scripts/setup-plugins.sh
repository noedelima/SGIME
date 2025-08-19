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
# - redmine_checklists: Sistema oficial de checklists (RedmineUP Light)
# - redmine_dmsf: Sistema de gestão de documentos
# - redmine_recurring_tasks: Tarefas recorrentes para manutenção
# - sgime_customizations: Tema e customizações do Colégio Pedro II
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
    ["sgime_customizations"]="local" # Plugin customizado do SGIME
    ["redmine_checklists"]="manual_install" # Plugin comercial - download manual necessário
    ["redmine_dmsf"]="local" # Preferir cópia local corrigida; se ausente, usar fallback oficial
    # Usamos o fork SGIME oficial para tarefas recorrentes
    ["redmine_recurring_tasks_sgime"]="local"
    ["redmine_more_previews"]="https://github.com/HugoHasenbein/redmine_more_previews.git" # Preview avançado de arquivos
)

# URL de fallback para o DMSF caso a cópia local não exista
DMSF_FALLBACK_URL="https://github.com/danmunn/redmine_dmsf.git"

# Plugins removidos da instalação (mantidos no histórico para referência)
declare -A REMOVED_PLUGINS=(
    ["simple_checklists"]="https://github.com/Restream/redmine_simple_checklists.git"
    ["redmine_issue_templates"]="https://github.com/akiko-pusu/redmine_issue_templates.git"
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

# Mensagem de sucesso (alinha com setup.sh)
success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] SUCESSO:${NC} $1"
}

# Função para baixar plugin se não existir
download_plugin() {
    local plugin_name="$1"
    local plugin_url="$2"
    local plugin_path="$PLUGINS_DIR/$plugin_name"
    
    # Plugin local (já existe no repositório)
    if [ "$plugin_url" = "local" ]; then
        if [ -d "$plugin_path" ]; then
            # Tratar caso especial: DMSF presente mas incompleto (sem init.rb)
            if [ "$plugin_name" = "redmine_dmsf" ] && [ ! -f "$plugin_path/init.rb" ]; then
                warning "Diretório $plugin_name encontrado, porém incompleto (sem init.rb). Aplicando fallback do repositório oficial..."
                ts=$(date +%Y%m%d%H%M%S)
                backup_path="${plugin_path}.bak-${ts}"
                mv "$plugin_path" "$backup_path"
                info "Backup criado: $backup_path"
                mkdir -p "$PLUGINS_DIR"
                if git clone "$DMSF_FALLBACK_URL" "$plugin_path" 2>/dev/null; then
                    log "Plugin $plugin_name (fallback) baixado com sucesso"
                    return 0
                else
                    error "Falha ao baixar fallback do $plugin_name"
                    return 1
                fi
            fi
            info "Plugin local $plugin_name já existe"
            return 0
        else
            # Fallback específico: baixar DMSF do repositório oficial se não houver cópia local
            if [ "$plugin_name" = "redmine_dmsf" ] && [ -n "$DMSF_FALLBACK_URL" ]; then
                warning "Cópia local do $plugin_name não encontrada; baixando do repositório oficial..."
                mkdir -p "$PLUGINS_DIR"
                if git clone "$DMSF_FALLBACK_URL" "$plugin_path" 2>/dev/null; then
                    log "Plugin $plugin_name (fallback) baixado com sucesso"
                    return 0
                else
                    error "Falha ao baixar fallback do $plugin_name"
                    return 1
                fi
            fi
            error "Plugin local $plugin_name não encontrado em $plugin_path"
            return 1
        fi
    fi
    
    # Plugin de instalação manual (comercial ou sem repositório público)
    if [ "$plugin_url" = "manual_install" ]; then
        if [ -d "$plugin_path" ]; then
            info "Plugin $plugin_name (instalação manual) já existe"
            return 0
        else
            warning "Plugin $plugin_name requer instalação manual"
            warning "Por favor, baixe e extraia o plugin em: $plugin_path"
            return 1
        fi
    fi
    
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
    # Para recurring_tasks usamos um diretório de destino diferente no container
    local target_name="$plugin_name"
    if [ "$plugin_name" = "redmine_recurring_tasks_sgime" ]; then
        target_name="recurring_tasks"
    fi
    local mount_line="      - ./plugins/$plugin_name:/usr/src/redmine/plugins/$target_name"
    
    # Verificar se já está habilitado (linha não comentada)
    if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$target_name" "$DOCKER_COMPOSE_FILE"; then
        info "Plugin $plugin_name já está habilitado no docker compose.yml"
        return 0
    fi
    
    # Inserir logo após o volume principal de files do Redmine
    if grep -q "^[[:space:]]*- sgime_redmine_files:/usr/src/redmine/files" "$DOCKER_COMPOSE_FILE"; then
        sed -i "/^[[:space:]]*- sgime_redmine_files:\/usr\/src\/redmine\/files/a \\${mount_line}" "$DOCKER_COMPOSE_FILE"
        log "Plugin $plugin_name adicionado ao docker compose.yml (após sgime_redmine_files)"
    else
        # Fallback: inserir na seção volumes do redmine
        awk -v insert_line="$mount_line" '
            BEGIN{in_redmine=0; in_vols=0}
            /^  redmine:/{in_redmine=1}
            in_redmine && /^    volumes:/{in_vols=1}
            {print}
            in_redmine && in_vols && $0 ~ /^      - / && added!=1 {
                # Inserir após a primeira linha de volume
                print insert_line
                added=1
            }
        ' "$DOCKER_COMPOSE_FILE" > "$DOCKER_COMPOSE_FILE.tmp" && mv "$DOCKER_COMPOSE_FILE.tmp" "$DOCKER_COMPOSE_FILE"
        log "Plugin $plugin_name adicionado ao docker compose.yml (fallback volumes)"
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

# Função para aplicar correções específicas do DMSF
fix_dmsf_plugin() {
    local dmsf_path="plugins/redmine_dmsf"
    
    if [ ! -d "$dmsf_path" ]; then
        return 0
    fi
    
    log "Aplicando correções para compatibilidade do DMSF..."
    
    # 1. Criar Gemfile mínimo apenas se não existir, para não sobrescrever alterações manuais
    if [ ! -f "$dmsf_path/Gemfile" ]; then
        cat > "$dmsf_path/Gemfile" << 'EOF'
# frozen_string_literal: true

# Minimal dependencies for DMSF plugin

source 'https://rubygems.org' do
  gem 'uuidtools'
  gem 'simple_enum'
  gem 'rake' unless Dir.exist?(File.expand_path('../../redmine_dashboard', __FILE__))
end
EOF
        log "Gemfile criado para redmine_dmsf"
    else
        info "Gemfile do redmine_dmsf já existe; não será sobrescrito"
    fi
    
    # 2. Corrigir require do ox em dav4rack.rb
    if [ -f "$dmsf_path/lib/dav4rack.rb" ]; then
        sed -i "s/require 'ox'/# require 'ox'/" "$dmsf_path/lib/dav4rack.rb"
        log "Correção aplicada em dav4rack.rb"
    fi
    
    # 3. Comentar simple_enum em dmsf_lock.rb
    if [ -f "$dmsf_path/app/models/dmsf_lock.rb" ]; then
        sed -i "s/require 'simple_enum'/# require 'simple_enum'  # Commented temporarily to resolve dependency issues/" "$dmsf_path/app/models/dmsf_lock.rb"
        sed -i "s/as_enum :lock_type, %i\[type_write type_other\]/# as_enum :lock_type, %i[type_write type_other]  # Commented temporarily/" "$dmsf_path/app/models/dmsf_lock.rb"
        sed -i "s/as_enum :lock_scope, %i\[scope_exclusive scope_shared\]/# as_enum :lock_scope, %i[scope_exclusive scope_shared]  # Commented temporarily/" "$dmsf_path/app/models/dmsf_lock.rb"
        log "Correção aplicada em dmsf_lock.rb"
    fi
    
    # 4. Garantir require 'zip' no init.rb
    if [ -f "$dmsf_path/init.rb" ]; then
        if ! grep -q "require 'zip'" "$dmsf_path/init.rb"; then
            sed -i "/require 'redmine'/a require 'zip'  # RubyZip dependency" "$dmsf_path/init.rb"
            log "Adicionado require 'zip' no init.rb"
        fi
    fi

    # 5. Ajustar Gemfile: desabilitar ox e grupo :xapian para evitar extensões nativas
    if [ -f "$dmsf_path/Gemfile" ]; then
        # Comentar gem 'ox'
        if grep -q "^[[:space:]]*gem ['\"]ox['\"]" "$dmsf_path/Gemfile"; then
            # Usar delimitador @ para evitar conflito com barras na substituição
            sed -i "s@^[[:space:]]*gem ['\"]ox['\"][^#]*@# &  # desabilitado (evita build nativo ox)@" "$dmsf_path/Gemfile"
            log "Gem 'ox' desabilitada no Gemfile do DMSF"
        fi
        # Comentar bloco do grupo :xapian
        if grep -q "group[[:space:]]*:xapian[[:space:]]*do" "$dmsf_path/Gemfile"; then
            awk 'BEGIN{inblock=0} \
                /group[[:space:]]*:xapian[[:space:]]*do/{inblock=1; print "# "$0; next} \
                inblock && /end/{inblock=0; print "# "$0; next} \
                { if(inblock){print "# "$0} else {print $0} }' "$dmsf_path/Gemfile" > "$dmsf_path/Gemfile.tmp" && mv "$dmsf_path/Gemfile.tmp" "$dmsf_path/Gemfile"
            log "Bloco :xapian comentado no Gemfile do DMSF"
        fi
    fi
    
    success "Correções do DMSF aplicadas com sucesso!"
}

# Função para configurar redmine_recurring_tasks
setup_recurring_tasks() {
    # Considerar ambos nomes possíveis
    local plugin_path="$PLUGINS_DIR/redmine_recurring_tasks_sgime"
    if [ ! -d "$plugin_path" ]; then
        plugin_path="$PLUGINS_DIR/redmine_recurring_tasks"
    fi
    
    if [ ! -d "$plugin_path" ]; then
        warning "Plugin redmine_recurring_tasks não encontrado"
        return 1
    fi
    
    log "Configurando redmine_recurring_tasks..."
    
    # Verificar se o arquivo init.rb existe
    if [ ! -f "$plugin_path/init.rb" ]; then
        warning "Arquivo init.rb não encontrado no plugin recurring_tasks; seguindo em frente"
        return 0
    fi
    
    # O plugin recurring_tasks não requer configurações especiais no código
    # Apenas precisa das migrações padrão do Redmine
    log "Plugin recurring_tasks configurado (utilizará migrações padrão)"
    
    success "Configuração do recurring_tasks concluída!"
}

# Função para criar tabelas necessárias via SQL (removida - usando migrações padrão)
# As tabelas dos plugins são criadas automaticamente pelas migrações do Redmine

# Função principal para configurar plugins essenciais
setup_essential_plugins() {
    log "Configurando plugins essenciais do SGIME..."
    
    for plugin_name in "${!ESSENTIAL_PLUGINS[@]}"; do
        local plugin_url="${ESSENTIAL_PLUGINS[$plugin_name]}"
        
        # Baixar plugin
        if download_plugin "$plugin_name" "$plugin_url"; then
            # Habilitar no docker compose
            enable_plugin_in_compose "$plugin_name"
            
            # Aplicar configurações específicas para cada plugin
            case "$plugin_name" in
                "redmine_dmsf")
                    fix_dmsf_plugin
                    ;;
                "redmine_recurring_tasks")
                    setup_recurring_tasks
                    ;;
            esac
        else
            warning "Falha ao configurar plugin essencial: $plugin_name"
        fi
    done
    
    log "Plugins essenciais configurados!"
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
    echo -e "${YELLOW}Plugins removidos da instalação (para referência):${NC}"
    for plugin_name in "${!REMOVED_PLUGINS[@]}"; do
        echo -e "  ${RED}-${NC} $plugin_name (removido da instalação)"
    done
    
    echo ""
    echo -e "${BLUE}ℹ️  Informações adicionais:${NC}"
    echo -e "  • Plugins essenciais são instalados automaticamente"
    echo -e "  • Para gerenciamento dinâmico use: ./scripts/plugin-manager.sh"
    echo -e "  • Para adicionar novos plugins, edite este script"
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
        log "Apenas baixando plugins essenciais..."
        for plugin_name in "${!ESSENTIAL_PLUGINS[@]}"; do
            download_plugin "$plugin_name" "${ESSENTIAL_PLUGINS[$plugin_name]}"
        done
        ;;
    "status")
        show_status
        ;;
    *)
        main
        ;;
esac
