#!/bin/bash
# SGIME Shutdown Script
# Para parar o sistema de forma limpa

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] SHUTDOWN:${NC} $1"
}

warning() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] AVISO:${NC} $1"
}

# Banner
echo -e "${BLUE}"
echo "=================================="
echo "  SGIME - Sistema Shutdown"
echo "  Parando serviços de forma limpa"
echo "=================================="
echo -e "${NC}"

# Verificar se há containers rodando
if ! docker-compose ps -q &>/dev/null; then
    warning "Nenhum container SGIME detectado rodando."
    exit 0
fi

# Mostrar status atual
log "Status atual dos serviços:"
docker-compose ps

echo ""

# Fazer backup rápido se solicitado
if [ "$1" = "--backup" ] || [ "$1" = "-b" ]; then
    log "Fazendo backup antes de parar..."
    ./scripts/manage.sh backup || warning "Backup falhou, continuando shutdown..."
fi

# Parar serviços graciosamente
log "Parando serviços SGIME..."
docker-compose down

# Verificar se parou
sleep 2
if docker-compose ps -q &>/dev/null && [ $(docker-compose ps -q | wc -l) -gt 0 ]; then
    warning "Alguns containers ainda estão rodando. Forçando parada..."
    docker-compose down --remove-orphans
else
    log "Todos os serviços foram parados com sucesso."
fi

# Limpar volumes órfãos se solicitado
if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
    log "Limpando volumes órfãos..."
    docker system prune -f --volumes
fi

echo ""
log "Sistema SGIME parado com sucesso!"
echo ""
echo -e "${YELLOW}Para retomar:${NC}"
echo "1. Execute: ./scripts/setup-environment.sh"
echo "2. Execute: docker-compose up -d"
echo ""
echo -e "${BLUE}Opções de shutdown:${NC}"
echo "  --backup (-b)  Fazer backup antes de parar"
echo "  --clean (-c)   Limpar volumes órfãos Docker"
echo ""
