#!/bin/bash
# Script de Setup Rápido do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia
# Versão: 1.8 - Final Stable Release
# Licença: GPLv3

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SGIME SETUP:${NC} $1"
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

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SUCESSO:${NC} $1"
}

# Banner de boas-vindas
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ███████  ██████  ██ ███    ███ ███████                         ║
║   ██      ██       ██ ████  ████ ██                              ║
║   ███████ ██   ███ ██ ██ ████ ██ █████                           ║
║        ██ ██    ██ ██ ██  ██  ██ ██                              ║
║   ███████  ██████  ██ ██      ██ ███████                         ║
║                                                                  ║
║   Sistema de Gestão Integrada de Engenharia                      ║
║   Colégio Pedro II - Seção de Engenharia                         ║
║   Versão 1.8 - Agosto 2025 (Final Stable)                       ║
║                                                                  ║
║   Setup Rápido e Inteligente                                     ║
║   Licença: GPLv3                                                 ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Verificar pré-requisitos
check_prerequisites() {
    log "Verificando pré-requisitos do sistema..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        error "Docker não encontrado. Instale o Docker primeiro."
    fi
    success "Docker encontrado: $(docker --version)"
    
    # Verificar Docker Compose
    if docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    else
        error "Docker Compose não encontrado. Instale docker-compose ou docker compose plugin."
    fi
    success "Docker Compose encontrado: $($DOCKER_COMPOSE_CMD --version)"
    
    # Verificar se usuário está no grupo docker
    if ! groups | grep -q docker; then
        warning "Usuário não está no grupo 'docker'. Pode ser necessário usar sudo."
        warning "Execute: sudo usermod -aG docker $USER && newgrp docker"
    fi
    
    # Verificar espaço em disco (mínimo 10GB)
    available_space=$(df . | awk 'NR==2 {print $4}')
    if [ $available_space -lt 10485760 ]; then  # 10GB em KB
        warning "Espaço em disco pode ser insuficiente. Recomendado: mínimo 10GB livres."
    fi
    
    # Verificar memória RAM (mínimo 4GB)
    total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
    if [ $total_mem -lt 4 ]; then
        warning "Memória RAM pode ser insuficiente. Recomendado: mínimo 4GB RAM."
    fi
    
    success "Pré-requisitos verificados com sucesso!"
}

# Configurar variáveis de ambiente
setup_environment() {
    log "Configurando variáveis de ambiente..."
    
    if [ ! -f "config/.env" ]; then
        info "Criando arquivo de configuração a partir do template..."
        cp config/env.example config/.env
        
        # Gerar chave secreta aleatória
        SECRET_KEY=$(openssl rand -hex 64)
        sed -i "s/sua_chave_secreta_muito_segura_aqui_com_pelo_menos_64_caracteres/$SECRET_KEY/" config/.env
        
        # Gerar senhas aleatórias
        POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        
        sed -i "s/sgime_senha_segura_2025!/$POSTGRES_PASSWORD/" config/.env
        
        success "Arquivo .env criado com senhas seguras geradas automaticamente"
    else
        info "Arquivo .env já existe, mantendo configurações atuais"
    fi
    
    # Carregar variáveis de ambiente
    set -a  # automatically export all variables
    source config/.env
    set +a  # disable automatic export
}

# Criar diretórios necessários
create_directories() {
    log "Criando estrutura de diretórios..."
    
    directories=(
        "logs/redmine"
        "logs/nginx" 
        "logs/postgres"
        "logs/worker"
        "logs/backup"
        "backups/postgres"
        "backups/redmine"
        "backups/nginx"
        "config/nginx/ssl"
        "data/uploads"
        "data/plugins"
        "data/themes"
    )
    
    for dir in "${directories[@]}"; do
        mkdir -p "$dir"
        chmod 755 "$dir"
    done
    
    success "Estrutura de diretórios criada"
}

# Gerar certificados SSL auto-assinados
generate_ssl_certificates() {
    log "Gerando certificados SSL para desenvolvimento..."
    
    if [ ! -f "config/nginx/ssl/sgime.crt" ]; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout config/nginx/ssl/sgime.key \
            -out config/nginx/ssl/sgime.crt \
            -subj "/C=BR/ST=RJ/L=Rio de Janeiro/O=Colégio Pedro II/OU=Seção de Engenharia/CN=sgime.cp2.g12.br" \
            2>/dev/null
        
        chmod 600 config/nginx/ssl/sgime.key
        chmod 644 config/nginx/ssl/sgime.crt
        
        success "Certificados SSL gerados (auto-assinados para desenvolvimento)"
    else
        info "Certificados SSL já existem"
    fi
}

# Construir e iniciar contêineres
build_and_start() {
    log "Configurando plugins essenciais do SGIME..."
    
    # Executar setup automático de plugins
    if [ -f "scripts/setup-plugins.sh" ]; then
        ./scripts/setup-plugins.sh essential-only
    else
        warning "Script de setup de plugins não encontrado, continuando sem plugins"
    fi
    
    log "Construindo imagens Docker..."
    
    # Baixar imagens base mais recentes
    $DOCKER_COMPOSE_CMD pull postgres nginx
    
    # Construir imagem customizada do Redmine
    $DOCKER_COMPOSE_CMD build --pull redmine
    
    log "Iniciando serviços..."
    
    # Iniciar PostgreSQL primeiro
    $DOCKER_COMPOSE_CMD up -d postgres
    info "Aguardando PostgreSQL inicializar..."
    sleep 15
    
    # Iniciar Redmine
    $DOCKER_COMPOSE_CMD up -d redmine
    info "Aguardando Redmine inicializar..."
    sleep 30
    
    # Iniciar Nginx por último
    $DOCKER_COMPOSE_CMD up -d nginx
    
    success "Todos os serviços iniciados com sucesso!"
}

# Configurar dados iniciais
setup_initial_data() {
    log "Configurando dados iniciais do SGIME..."
    
    # Aguardar o Redmine estar completamente pronto
    info "Aguardando Redmine estar pronto para configuração..."
    timeout=300  # 5 minutos
    count=0
    
    while [ $count -lt $timeout ]; do
        if $DOCKER_COMPOSE_CMD exec -T redmine curl -s -f http://localhost:3000/login > /dev/null 2>&1; then
            break
        fi
        sleep 5
        count=$((count + 5))
        echo -n "."
    done
    echo ""
    
    if [ $count -ge $timeout ]; then
        error "Timeout aguardando Redmine inicializar"
    fi
    
    # Executar configuração inicial
    info "Executando migrações e configuração inicial..."
    $DOCKER_COMPOSE_CMD exec -T redmine bash -c "
        bundle exec rake db:migrate RAILS_ENV=production &&
        bundle exec rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=pt-BR
    " || true
    
    # Configurar tabelas de plugins manualmente (contorna problemas de migração automática)
    info "Configurando tabelas dos plugins..."
    $DOCKER_COMPOSE_CMD exec -T postgres psql -U \${POSTGRES_USER:-sgime_user} -d \${POSTGRES_DB:-sgime_production} -c "
        CREATE TABLE IF NOT EXISTS recurring_tasks (
            id SERIAL PRIMARY KEY,
            current_issue_id INTEGER,
            fixed_schedule BOOLEAN,
            interval_number INTEGER,
            interval_unit VARCHAR(255),
            interval_modifier INTEGER DEFAULT 1,
            recur_subtasks BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    " 2>/dev/null || true
    
    success "Configuração inicial concluída"
}

# Verificar saúde dos serviços
check_services_health() {
    log "Verificando saúde dos serviços..."
    sleep 10
    
    services=("postgres" "redmine" "nginx")
    
    for service in "${services[@]}"; do
        if $DOCKER_COMPOSE_CMD ps "$service" | grep -q "Up"; then
            success "✓ $service está funcionando"
        else
            error "✗ $service não está funcionando corretamente"
        fi
    done
    
    # Testar conectividade HTTP
    if curl -s -f http://localhost/health > /dev/null 2>&1; then
        success "✓ Nginx respondendo corretamente"
    else
        warning "✗ Nginx pode não estar respondendo na porta 80"
    fi
    
    # Testar conectividade HTTPS
    if curl -s -f -k https://localhost/nginx-health > /dev/null 2>&1; then
        success "✓ SSL funcionando corretamente"
    else
        warning "✗ SSL pode não estar funcionando na porta 443"
    fi
}

# Mostrar informações finais
show_final_info() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    SGIME INSTALADO COM SUCESSO!                  ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🎉 O SGIME foi instalado e configurado com sucesso!${NC}"
    echo ""
    echo -e "${YELLOW}📍 INFORMAÇÕES DE ACESSO:${NC}"
    echo -e "   • URL Principal: ${BLUE}http://localhost${NC} ou ${BLUE}https://localhost${NC}"
    echo -e "   • URL Alternativa: ${BLUE}http://sgime.cp2.g12.br${NC} (adicione ao /etc/hosts)"
    echo -e "   • Usuário padrão: ${GREEN}admin${NC}"
    echo -e "   • Senha padrão: ${GREEN}admin123${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
    echo -e "   • ${RED}ALTERE A SENHA DO ADMIN IMEDIATAMENTE${NC} após o primeiro login"
    echo -e "   • Configure LDAP/SSO em Administração → Autenticação LDAP"
    echo -e "   • Configure email em Administração → Configurações → Email"
    echo ""
    echo -e "${YELLOW}📋 COMANDOS ÚTEIS:${NC}"
    echo -e "   • Ver status: ${CYAN}./scripts/manage.sh status${NC}"
    echo -e "   • Ver logs: ${CYAN}./scripts/manage.sh logs${NC}"
    echo -e "   • Parar sistema: ${CYAN}./scripts/manage.sh stop${NC}"
    echo -e "   • Iniciar sistema: ${CYAN}./scripts/manage.sh start${NC}"
    echo -e "   • Backup: ${CYAN}./scripts/manage.sh backup${NC}"
    echo ""
    echo -e "${YELLOW}📚 DOCUMENTAÇÃO:${NC}"
    echo -e "   • Manual do Usuário: ${CYAN}docs/manual-usuario.md${NC}"
    echo -e "   • Guia do Administrador: ${CYAN}docs/guia-administrador.md${NC}"
    echo -e "   • API e Integrações: ${CYAN}docs/api-integracoes.md${NC}"
    echo -e "   • Troubleshooting: ${CYAN}docs/troubleshooting.md${NC}"
    echo ""
    echo -e "${YELLOW}💬 SUPORTE:${NC}"
    echo -e "   • Email: ${CYAN}geeng@cp2.g12.br${NC}"
    echo -e "   • Telefone: ${CYAN}(21) 2569-1234 (Ramal: 5678)${NC}"
    echo ""
}

# Função principal
main() {
    show_banner
    
    echo -e "${YELLOW}Este script irá instalar e configurar o SGIME automaticamente.${NC}"
    echo -e "${YELLOW}Tempo estimado: 5-10 minutos (dependendo da conexão de internet)${NC}"
    echo ""
    
    read -p "Deseja continuar? (s/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada pelo usuário."
        exit 0
    fi
    
    echo ""
    log "Iniciando setup do SGIME v1.8 (Final Stable)..."
    
    # Executar etapas do setup
    check_prerequisites
    setup_environment
    create_directories
    generate_ssl_certificates
    build_and_start
    setup_initial_data
    check_services_health
    show_final_info
    
    success "Setup do SGIME concluído com sucesso! 🚀"
}

# Verificar se está no diretório correto
if [ ! -f "docker-compose.yml" ]; then
    error "Execute este script no diretório raiz do SGIME (onde está o docker-compose.yml)"
fi

# Executar função principal
main "$@"
