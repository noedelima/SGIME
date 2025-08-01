#!/bin/bash
# SGIME Setup Script
# Configura ambiente para desenvolvimento/produção

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] SETUP:${NC} $1"
}

warning() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] AVISO:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERRO:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO:${NC} $1"
}

# Banner
echo -e "${BLUE}"
echo "=================================="
echo "  SGIME - Setup Environment"
echo "  Sistema de Gestão de Engenharia"
echo "  Colégio Pedro II"
echo "=================================="
echo -e "${NC}"

# Verificar se Docker está rodando
if ! docker info >/dev/null 2>&1; then
    error "Docker não está rodando. Inicie o Docker primeiro."
    exit 1
fi

# Criar arquivo .env se não existir
if [ ! -f ".env" ]; then
    log "Criando arquivo .env a partir do template..."
    cp .env.example .env
    warning "Arquivo .env criado. IMPORTANTE: Edite as senhas antes de continuar!"
    warning "Execute: nano .env (ou seu editor preferido)"
    
    # Gerar uma chave secreta aleatória
    SECRET_KEY=$(openssl rand -hex 64)
    sed -i "s|sua_chave_secreta_muito_segura_aqui_com_pelo_menos_64_caracteres_1234567890|$SECRET_KEY|g" .env
    log "Chave secreta gerada automaticamente."
else
    info "Arquivo .env já existe."
fi

# Verificar se há arquivo de configuração específico
if [ ! -f "config/.env" ]; then
    log "Copiando configurações para config/..."
    cp config/env.example config/.env 2>/dev/null || true
fi

# Criar diretórios necessários
log "Criando diretórios necessários..."
mkdir -p {logs,backups,data/postgres,data/redmine,data/redis}
mkdir -p config/nginx/ssl

# Gerar certificados SSL se não existirem
if [ ! -f "config/nginx/ssl/sgime.crt" ] || [ ! -f "config/nginx/ssl/sgime.key" ]; then
    log "Gerando certificados SSL auto-assinados para desenvolvimento..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout config/nginx/ssl/sgime.key \
        -out config/nginx/ssl/sgime.crt \
        -subj "/C=BR/ST=RJ/L=Rio de Janeiro/O=Colegio Pedro II/OU=SGIME/CN=localhost" \
        >/dev/null 2>&1
    log "Certificados SSL criados em config/nginx/ssl/"
    warning "ATENÇÃO: Certificados auto-assinados são apenas para desenvolvimento!"
else
    info "Certificados SSL já existem."
fi

# Ajustar permissões
log "Ajustando permissões..."
chmod +x scripts/*.sh 2>/dev/null || true
chmod 600 config/nginx/ssl/sgime.key 2>/dev/null || true

# Verificar plugins
log "Verificando plugins..."
if [ ! -d "plugins/simple_checklists" ]; then
    warning "Plugins não encontrados. Execute ./scripts/setup-plugins.sh após iniciar."
fi

# Status dos serviços
info "Status atual dos serviços:"
if docker compose ps >/dev/null 2>&1; then
    docker compose ps
else
    info "Nenhum serviço rodando."
fi

echo ""
log "Setup concluído!"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo "1. Edite o arquivo .env se necessário: nano .env"
echo "2. Inicie os serviços: docker compose up -d"
echo "3. Verifique os logs: docker compose logs -f"
echo "4. Acesse: http://localhost:3000"
echo ""
echo -e "${BLUE}Comandos úteis:${NC}"
echo "  ./scripts/plugin-manager.sh list       - Lista plugins"
echo "  ./scripts/manage.sh status            - Status do sistema"
echo "  ./scripts/manage.sh backup            - Backup dos dados"
echo ""
