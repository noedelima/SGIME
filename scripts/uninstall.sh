#!/bin/bash
# Script de Desinstalação do SGIME
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
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SGIME UNINSTALL:${NC} $1"
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

# Banner de aviso
echo "
╔══════════════════════════════════════════════════════════════════╗
║                      ⚠️  DESINSTALAÇÃO SGIME  ⚠️                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║   Este script irá REMOVER COMPLETAMENTE o SGIME e todos os       ║
║   dados associados, incluindo:                                   ║
║                                                                  ║
║   • Todos os dados do banco de dados                             ║
║   • Arquivos de documentos e anexos                              ║
║   • Configurações personalizadas                                 ║
║   • Containers e imagens Docker                                  ║
║   • Volumes e redes Docker                                       ║
║                                                                  ║
║   ⚠️  ESTA AÇÃO É IRREVERSÍVEL! ⚠️                                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
"

# Verificar se Docker Compose está disponível
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
elif command -v docker compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    error "Docker Compose não encontrado."
fi

# Verificar se estamos no diretório correto
if [ ! -f "docker compose.yml" ]; then
    error "Arquivo docker compose.yml não encontrado. Execute este script no diretório raiz do SGIME."
fi

# Primeira confirmação
echo
warning "Você está prestes a REMOVER COMPLETAMENTE o SGIME!"
warning "Todos os dados serão PERDIDOS PERMANENTEMENTE!"
echo
read -p "Tem certeza que deseja continuar? Digite 'SIM' para prosseguir: " -r
echo

if [ "$REPLY" != "SIM" ]; then
    log "Desinstalação cancelada pelo usuário."
    exit 0
fi

# Segunda confirmação mais específica
echo
warning "ÚLTIMA CHANCE!"
warning "Esta ação irá:"
warning "  - Parar e remover todos os containers"
warning "  - Deletar todos os volumes Docker (dados do banco, arquivos)"
warning "  - Remover imagens Docker do SGIME"
warning "  - Deletar arquivos de backup e logs"
warning "  - Remover configurações locais"
echo
read -p "Digite 'CONFIRMO_REMOCAO_COMPLETA' para prosseguir: " -r
echo

if [ "$REPLY" != "CONFIRMO_REMOCAO_COMPLETA" ]; then
    log "Desinstalação cancelada pelo usuário."
    exit 0
fi

log "Iniciando desinstalação completa do SGIME..."

# Parar e remover containers
log "Parando e removendo containers..."
$DOCKER_COMPOSE_CMD down -v --remove-orphans || true

# Remover imagens específicas do SGIME
log "Removendo imagens Docker do SGIME..."
docker images | grep sgime | awk '{print $3}' | xargs -r docker rmi -f || true

# Remover volumes nomeados
log "Removendo volumes Docker..."
docker volume ls | grep sgime | awk '{print $2}' | xargs -r docker volume rm || true

# Remover rede personalizada
log "Removendo rede Docker..."
docker network ls | grep sgime | awk '{print $1}' | xargs -r docker network rm || true

# Remover arquivos de dados locais
log "Removendo arquivos de dados locais..."
rm -rf data/ || true
rm -rf logs/ || true
rm -rf backups/ || true

# Remover configurações sensíveis (manter exemplos)
log "Removendo configurações sensíveis..."
rm -f config/.env
rm -f config/nginx/ssl/sgime.key
rm -f config/nginx/ssl/sgime.crt

# Limpar arquivos temporários
log "Limpando arquivos temporários..."
rm -rf tmp/ || true
rm -rf .tmp/ || true

# Limpeza geral do Docker (opcional - com confirmação)
echo
read -p "Deseja executar limpeza geral do Docker (remove containers/volumes/imagens não utilizados)? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    log "Executando limpeza geral do Docker..."
    docker system prune -a -f --volumes || true
fi

# Verificar se ainda existem recursos relacionados
log "Verificando restos de instalação..."

remaining_containers=$(docker ps -a | grep sgime | wc -l)
remaining_volumes=$(docker volume ls | grep sgime | wc -l)
remaining_images=$(docker images | grep sgime | wc -l)

if [ "$remaining_containers" -gt 0 ] || [ "$remaining_volumes" -gt 0 ] || [ "$remaining_images" -gt 0 ]; then
    warning "Alguns recursos ainda podem estar presentes:"
    warning "  - Containers: $remaining_containers"
    warning "  - Volumes: $remaining_volumes"  
    warning "  - Imagens: $remaining_images"
    info "Execute 'docker system prune -a -f --volumes' para limpeza adicional."
else
    log "✅ Todos os recursos Docker foram removidos com sucesso."
fi

# Mensagem final
echo "
╔══════════════════════════════════════════════════════════════════╗
║                   DESINSTALAÇÃO CONCLUÍDA                       ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ✅ O SGIME foi completamente removido do sistema.               ║
║                                                                  ║
║  📁 Arquivos mantidos:                                           ║
║     • README.md e documentação                                   ║
║     • Scripts de instalação                                      ║
║     • Arquivos de configuração exemplo                           ║
║                                                                  ║
║  🔄 Para reinstalar:                                             ║
║     ./scripts/install.sh                                         ║
║                                                                  ║
║  📧 Suporte: geeng@cp2.g12.br                               ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
"

log "Desinstalação do SGIME finalizada!"

# Verificar se o usuário quer remover também os arquivos do projeto
echo
read -p "Deseja remover também os arquivos de código do projeto (exceto esta pasta)? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    warning "Removendo arquivos do projeto..."
    cd ..
    rm -rf SGIME/
    log "Projeto SGIME removido completamente!"
fi
