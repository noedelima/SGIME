#!/bin/bash
# Script de Instalação do SGIME
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
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] SGIME INSTALL:${NC} $1"
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

# Banner de boas-vindas
echo "
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
║   Versão 1.6 - Julho 2025                                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
"

log "Iniciando instalação do SGIME..."

# Verificar se está executando como root ou com sudo
if [ "$EUID" -eq 0 ]; then
    warning "Executando como root. Recomenda-se usar um usuário normal com sudo."
fi

# Verificar sistema operacional
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    log "Sistema detectado: $OS $VER"
else
    error "Não foi possível detectar o sistema operacional."
fi

# Verificar se os comandos necessários estão disponíveis
check_command() {
    if ! command -v $1 &> /dev/null; then
        error "Comando '$1' não encontrado. Instale $1 e tente novamente."
    fi
}

log "Verificando pré-requisitos..."

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    info "Docker não encontrado. Instalando Docker..."
    
    if [[ "$OS" == *"Ubuntu"* ]]; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    elif [[ "$OS" == *"Fedora"* ]]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    else
        error "Sistema operacional não suportado para instalação automática do Docker."
    fi
    
    # Iniciar e habilitar Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    # Adicionar usuário atual ao grupo docker
    sudo usermod -aG docker $USER
    log "Docker instalado com sucesso. IMPORTANTE: Faça logout e login novamente para aplicar as permissões."
fi

# Verificar se o Docker Compose está disponível
if ! docker compose version &> /dev/null; then
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose não encontrado. Instale docker-compose e tente novamente."
    else
        # Usar docker-compose legacy
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
else
    DOCKER_COMPOSE_CMD="docker compose"
fi

check_command git
check_command curl

log "Todos os pré-requisitos atendidos."

# Verificar se já existe uma instalação
if [ -f "docker-compose.yml" ]; then
    warning "Instalação existente detectada."
    read -p "Deseja continuar e sobrescrever a instalação existente? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        log "Instalação cancelada pelo usuário."
        exit 0
    fi
fi

# Criar arquivo de ambiente se não existir
if [ ! -f "config/.env" ]; then
    log "Criando arquivo de configuração de ambiente..."
    cp config/env.example config/.env
    
    # Gerar chave secreta aleatória
    SECRET_KEY=$(openssl rand -hex 64)
    sed -i "s/sua_chave_secreta_muito_segura_aqui_com_pelo_menos_64_caracteres/$SECRET_KEY/" config/.env
    
    # Gerar senha do banco aleatória
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    sed -i "s/sgime_senha_segura_2025!/$DB_PASSWORD/" config/.env
    
    info "Arquivo config/.env criado. Edite-o conforme necessário antes de prosseguir."
else
    log "Arquivo de configuração existente encontrado."
fi

# Criar diretórios necessários
log "Criando estrutura de diretórios..."
mkdir -p backups
mkdir -p logs/{nginx,redmine,backup}
mkdir -p config/nginx/ssl
mkdir -p data/{postgres,redis}

# Gerar certificado SSL auto-assinado se não existir
if [ ! -f "config/nginx/ssl/sgime.crt" ]; then
    log "Gerando certificado SSL auto-assinado..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout config/nginx/ssl/sgime.key \
        -out config/nginx/ssl/sgime.crt \
        -subj "/C=BR/ST=RJ/L=Rio de Janeiro/O=Colégio Pedro II/OU=Seção de Engenharia/CN=sgime.cp2.g12.br"
fi

# Construir imagens Docker
log "Construindo imagens Docker..."
$DOCKER_COMPOSE_CMD build --no-cache

# Iniciar serviços
log "Iniciando serviços do SGIME..."
$DOCKER_COMPOSE_CMD up -d

# Aguardar serviços ficarem prontos
log "Aguardando inicialização dos serviços..."
sleep 30

# Verificar se os serviços estão rodando
if $DOCKER_COMPOSE_CMD ps | grep -q "Up"; then
    log "Serviços iniciados com sucesso!"
    
    # Mostrar informações de acesso
    echo "
╔══════════════════════════════════════════════════════════════════╗
║                    INSTALAÇÃO CONCLUÍDA                         ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  🌐 Acesso ao Sistema:                                           ║
║     https://localhost (HTTPS)                                    ║
║     http://localhost (HTTP - redireciona para HTTPS)             ║
║                                                                  ║
║  👤 Credenciais Padrão:                                          ║
║     Usuário: admin                                               ║
║     Senha: admin123                                              ║
║                                                                  ║
║  ⚠️  IMPORTANTE:                                                  ║
║     1. Altere a senha padrão imediatamente                       ║
║     2. Configure o arquivo config/.env conforme necessário       ║
║     3. Para produção, substitua o certificado SSL               ║
║                                                                  ║
║  📖 Documentação:                                                ║
║     README.md - Guia completo                                    ║
║     docs/ - Documentação detalhada                               ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
"
    
    info "Para gerenciar o sistema, use o script: ./scripts/manage.sh"
    info "Para logs em tempo real: $DOCKER_COMPOSE_CMD logs -f"
    info "Para parar o sistema: $DOCKER_COMPOSE_CMD down"
    
else
    error "Falha na inicialização dos serviços. Verifique os logs: $DOCKER_COMPOSE_CMD logs"
fi

log "Instalação do SGIME finalizada!"
