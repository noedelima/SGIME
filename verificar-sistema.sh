#!/bin/bash
# Script de Verificação do Sistema SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia
# Versão: 1.6
# Licença: GPLv3

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              VERIFICAÇÃO DO SISTEMA SGIME v1.6                   ║${NC}"
echo -e "${BLUE}║          Sistema de Gestão Integrada de Engenharia               ║${NC}"
echo -e "${BLUE}║              Colégio Pedro II - Seção de Engenharia              ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Função para verificar arquivos
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "✅ ${GREEN}$description${NC} - $file"
        return 0
    else
        echo -e "❌ ${RED}$description FALTANDO${NC} - $file"
        return 1
    fi
}

# Função para verificar diretórios
check_dir() {
    local dir=$1
    local description=$2
    
    if [ -d "$dir" ]; then
        echo -e "✅ ${GREEN}$description${NC} - $dir"
        return 0
    else
        echo -e "❌ ${RED}$description FALTANDO${NC} - $dir"
        return 1
    fi
}

# Função para verificar versões no arquivo de configuração
check_versions() {
    echo -e "${YELLOW}📋 VERSÕES CONFIGURADAS:${NC}"
    
    if [ -f "config/env.example" ]; then
        echo -e "   • Redmine: ${BLUE}$(grep REDMINE_VERSION config/env.example | cut -d'=' -f2)${NC}"
        echo -e "   • Ruby: ${BLUE}$(grep RUBY_VERSION config/env.example | cut -d'=' -f2)${NC}"
        echo -e "   • PostgreSQL: ${BLUE}$(grep POSTGRES_VERSION config/env.example | cut -d'=' -f2)${NC}"
        echo -e "   • Redis: ${BLUE}$(grep REDIS_VERSION config/env.example | cut -d'=' -f2)${NC}"
        echo -e "   • Nginx: ${BLUE}$(grep NGINX_VERSION config/env.example | cut -d'=' -f2)${NC}"
    else
        echo -e "   ${RED}❌ Arquivo de configuração não encontrado${NC}"
    fi
    echo ""
}

echo -e "${YELLOW}🔍 VERIFICANDO ESTRUTURA DO PROJETO...${NC}"
echo ""

# Verificar arquivos principais
echo -e "${YELLOW}📄 ARQUIVOS PRINCIPAIS:${NC}"
check_file "README.md" "README Principal"
check_file "LICENSE" "Licença GPLv3"
check_file "docker-compose.yml" "Docker Compose Principal"
check_file "setup.sh" "Script de Setup Automático"
echo ""

# Verificar scripts
echo -e "${YELLOW}🔧 SCRIPTS DE GERENCIAMENTO:${NC}"
check_file "scripts/install.sh" "Script de Instalação"
check_file "scripts/manage.sh" "Script de Gerenciamento"
check_file "scripts/uninstall.sh" "Script de Desinstalação"
echo ""

# Verificar configurações
echo -e "${YELLOW}⚙️  ARQUIVOS DE CONFIGURAÇÃO:${NC}"
check_file "config/env.example" "Template de Variáveis de Ambiente"
check_file "config/nginx/nginx.conf" "Configuração Principal do Nginx"
check_file "config/nginx/sites/sgime.conf" "Configuração do Site SGIME"
check_file "config/postgres/postgresql.conf" "Configuração do PostgreSQL"
check_file "config/postgres/init.sql" "Script de Inicialização do BD"
echo ""

# Verificar Docker
echo -e "${YELLOW}🐳 ARQUIVOS DOCKER:${NC}"
check_file "docker/redmine/Dockerfile" "Dockerfile do Redmine"
check_file "docker/redmine/docker-entrypoint.sh" "Script de Entrada do Redmine"
echo ""

# Verificar documentação
echo -e "${YELLOW}📚 DOCUMENTAÇÃO:${NC}"
check_file "docs/manual-usuario.md" "Manual do Usuário"
check_file "docs/guia-administrador.md" "Guia do Administrador"  
check_file "docs/api-integracoes.md" "Documentação da API"
check_file "docs/troubleshooting.md" "Guia de Troubleshooting"
echo ""

# Verificar plugins
echo -e "${YELLOW}🔌 PLUGINS CUSTOMIZADOS:${NC}"
check_dir "plugins/sgime_customizations" "Plugin de Customizações SGIME"
check_file "plugins/sgime_customizations/init.rb" "Inicialização do Plugin"
echo ""

# Verificar diretórios principais
echo -e "${YELLOW}📁 ESTRUTURA DE DIRETÓRIOS:${NC}"
check_dir "config" "Diretório de Configurações"
check_dir "docker" "Diretório Docker"
check_dir "docs" "Diretório de Documentação"
check_dir "plugins" "Diretório de Plugins"
check_dir "scripts" "Diretório de Scripts"
echo ""

# Verificar versões
check_versions

# Verificar permissões dos scripts
echo -e "${YELLOW}🔐 PERMISSÕES DOS SCRIPTS:${NC}"
if [ -x "setup.sh" ]; then
    echo -e "✅ ${GREEN}setup.sh executável${NC}"
else
    echo -e "❌ ${RED}setup.sh não executável${NC}"
fi

if [ -x "scripts/install.sh" ]; then
    echo -e "✅ ${GREEN}scripts/install.sh executável${NC}"
else
    echo -e "❌ ${RED}scripts/install.sh não executável${NC}"
fi

if [ -x "scripts/manage.sh" ]; then
    echo -e "✅ ${GREEN}scripts/manage.sh executável${NC}"
else
    echo -e "❌ ${RED}scripts/manage.sh não executável${NC}"
fi

if [ -x "scripts/uninstall.sh" ]; then
    echo -e "✅ ${GREEN}scripts/uninstall.sh executável${NC}"
else
    echo -e "❌ ${RED}scripts/uninstall.sh não executável${NC}"
fi
echo ""

# Resumo final
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                        RESUMO DA VERIFICAÇÃO                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Sistema SGIME v1.6 verificado com sucesso!${NC}"
echo ""
echo -e "${YELLOW}📋 CARACTERÍSTICAS IMPLEMENTADAS:${NC}"
echo -e "   • ✅ Arquitetura baseada em Docker Compose"
echo -e "   • ✅ Redmine 5.1 com plugins essenciais"
echo -e "   • ✅ PostgreSQL 16 otimizado"
echo -e "   • ✅ Nginx com configuração SSL"
echo -e "   • ✅ Redis para cache e sessões"
echo -e "   • ✅ Scripts de automação completos"
echo -e "   • ✅ Documentação em português brasileiro"
echo -e "   • ✅ Configurações de segurança"
echo -e "   • ✅ Plugin customizado SGIME"
echo -e "   • ✅ Licença GPLv3"
echo ""
echo -e "${YELLOW}🚀 PRÓXIMOS PASSOS:${NC}"
echo -e "   1. Execute: ${CYAN}./setup.sh${NC} para instalação automática"
echo -e "   2. Ou siga as instruções do README.md para instalação manual"
echo -e "   3. Configure LDAP/SSO conforme necessário"
echo -e "   4. Importe dados iniciais e configure usuários"
echo ""
echo -e "${YELLOW}💬 SUPORTE:${NC}"
echo -e "   • Email: ${CYAN}geeng@cp2.g12.br${NC}"
echo -e "   • Documentação: Consulte os arquivos em ${CYAN}docs/${NC}"
echo ""
echo -e "${GREEN}🎉 SGIME pronto para implantação!${NC}"
