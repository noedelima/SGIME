#!/bin/bash
# SGIME Plugin Manager
# Script para gerenciar plugins do Redmine de forma dinâmica

set -e

PLUGINS_DIR="plugins"
DOCKER_COMPOSE_FILE="docker-compose.yml"
CONTAINER_NAME="sgime-redmine"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para mostrar uso
show_usage() {
    echo -e "${BLUE}SGIME Plugin Manager${NC}"
    echo "Uso: $0 {install|enable|disable|list|status} [plugin_name]"
    echo ""
    echo "Comandos:"
    echo "  install <plugin_name> <git_url>  - Instala um plugin do Git"
    echo "  enable <plugin_name>             - Habilita um plugin"
    echo "  disable <plugin_name>            - Desabilita um plugin"
    echo "  list                             - Lista plugins disponíveis"
    echo "  status                           - Mostra status dos plugins"
    echo ""
    echo "Exemplos:"
    echo "  $0 install redmine_checklists https://github.com/nodecarter/redmine_checklists.git"
    echo "  $0 enable redmine_checklists"
    echo "  $0 disable redmine_checklists"
}

# Função para verificar se o docker compose está rodando
check_docker_running() {
    if ! docker compose ps | grep -q "$CONTAINER_NAME.*Up"; then
        echo -e "${YELLOW}Aviso: Container Redmine não está rodando${NC}"
        return 1
    fi
    return 0
}

# Função para instalar plugin
install_plugin() {
    local plugin_name="$1"
    local git_url="$2"
    
    if [ -z "$plugin_name" ] || [ -z "$git_url" ]; then
        echo -e "${RED}Erro: Nome do plugin e URL do Git são obrigatórios${NC}"
        show_usage
        exit 1
    fi
    
    if [ -d "$PLUGINS_DIR/$plugin_name" ]; then
        echo -e "${YELLOW}Plugin $plugin_name já existe${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Instalando plugin $plugin_name...${NC}"
    cd "$PLUGINS_DIR"
    git clone "$git_url" "$plugin_name"
    cd ..
    
    echo -e "${GREEN}Plugin $plugin_name instalado com sucesso!${NC}"
    echo -e "${YELLOW}Para habilitá-lo, execute: $0 enable $plugin_name${NC}"
}

# Função para habilitar plugin
enable_plugin() {
    local plugin_name="$1"
    
    if [ -z "$plugin_name" ]; then
        echo -e "${RED}Erro: Nome do plugin é obrigatório${NC}"
        show_usage
        exit 1
    fi
    
    if [ ! -d "$PLUGINS_DIR/$plugin_name" ]; then
        echo -e "${RED}Erro: Plugin $plugin_name não encontrado${NC}"
        exit 1
    fi
    
    # Verificar se já está habilitado (linha não comentada)
    if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
        echo -e "${YELLOW}Plugin $plugin_name já está habilitado${NC}"
        exit 0
    fi
    
    echo -e "${BLUE}Habilitando plugin $plugin_name...${NC}"
    
    # Se existe linha comentada, descomentá-la
    if grep -q "^[[:space:]]*# - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
        sed -i "s|^[[:space:]]*# - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name|      - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name|" "$DOCKER_COMPOSE_FILE"
    else
        # Adicionar nova linha no docker compose.yml
        sed -i "/# Uncomment lines below to enable specific plugins:/a\\      - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"
    fi
    
    echo -e "${GREEN}Plugin $plugin_name habilitado!${NC}"
    echo -e "${YELLOW}Reiniciando container Redmine...${NC}"
    
    docker compose restart redmine
    
    echo -e "${GREEN}Plugin $plugin_name ativo!${NC}"
}

# Função para desabilitar plugin
disable_plugin() {
    local plugin_name="$1"
    
    if [ -z "$plugin_name" ]; then
        echo -e "${RED}Erro: Nome do plugin é obrigatório${NC}"
        show_usage
        exit 1
    fi
    
    # Verificar se está habilitado (linha não comentada)
    if ! grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
        echo -e "${YELLOW}Plugin $plugin_name já está desabilitado${NC}"
        exit 0
    fi
    
    echo -e "${BLUE}Desabilitando plugin $plugin_name...${NC}"
    
    # Comentar linha no docker compose.yml
    sed -i "s|^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name|      # - ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name|" "$DOCKER_COMPOSE_FILE"
    
    echo -e "${GREEN}Plugin $plugin_name desabilitado!${NC}"
    echo -e "${YELLOW}Reiniciando container Redmine...${NC}"
    
    docker compose restart redmine
    
    echo -e "${GREEN}Plugin $plugin_name desativado!${NC}"
}

# Função para listar plugins
list_plugins() {
    echo -e "${BLUE}Plugins disponíveis:${NC}"
    
    if [ ! -d "$PLUGINS_DIR" ] || [ -z "$(ls -A $PLUGINS_DIR 2>/dev/null | grep -v README.md)" ]; then
        echo "Nenhum plugin instalado"
        return
    fi
    
    for plugin in "$PLUGINS_DIR"/*; do
        if [ -d "$plugin" ]; then
            plugin_name=$(basename "$plugin")
            # Verificar se está habilitado (linha não comentada)
            if grep -q "^[[:space:]]*- ./plugins/$plugin_name:/usr/src/redmine/plugins/$plugin_name" "$DOCKER_COMPOSE_FILE"; then
                echo -e "  ${GREEN}✓${NC} $plugin_name (habilitado)"
            else
                echo -e "  ${RED}✗${NC} $plugin_name (desabilitado)"
            fi
        fi
    done
}

# Função para mostrar status
show_status() {
    echo -e "${BLUE}Status do Sistema SGIME:${NC}"
    
    if check_docker_running; then
        echo -e "Container Redmine: ${GREEN}Rodando${NC}"
    else
        echo -e "Container Redmine: ${RED}Parado${NC}"
    fi
    
    echo ""
    list_plugins
}

# Main
case "$1" in
    install)
        install_plugin "$2" "$3"
        ;;
    enable)
        enable_plugin "$2"
        ;;
    disable)
        disable_plugin "$2"
        ;;
    list)
        list_plugins
        ;;
    status)
        show_status
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
