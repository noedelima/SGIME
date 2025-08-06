#!/bin/bash
# Script de Teste para Instalação Limpa do SGIME
# Simula uma instalação do zero para validar todos os scripts
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              SGIME - Teste de Instalação Limpa                  ║"
echo "║       Este script testa a instalação completa do zero           ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}ATENÇÃO: Este script irá:${NC}"
echo "1. Parar todos os containers SGIME"
echo "2. Remover todos os volumes Docker"
echo "3. Limpar todos os plugins baixados"
echo "4. Executar instalação limpa completa"
echo "5. Testar se tudo funciona"
echo ""
echo -e "${RED}⚠️  ISTO IRÁ APAGAR TODOS OS DADOS DO SGIME! ⚠️${NC}"
echo ""

read -p "Deseja continuar? [y/N]: " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelado pelo usuário."
    exit 0
fi

echo ""
echo -e "${BLUE}[FASE 1]${NC} Limpeza do ambiente..."

# Parar containers
echo "Parando containers..."
docker compose down --remove-orphans 2>/dev/null || true

# Remover volumes
echo "Removendo volumes Docker..."
docker volume rm sgime_postgres_data sgime_redmine_files sgime_redis_data 2>/dev/null || true

# Limpar plugins baixados (manter apenas customizações)
echo "Limpando plugins baixados..."
find plugins/ -maxdepth 1 -type d -name "redmine_*" -exec rm -rf {} + 2>/dev/null || true
find plugins/ -maxdepth 1 -type d -name "simple_*" -exec rm -rf {} + 2>/dev/null || true

# Limpar arquivos de configuração temporários
echo "Limpando configurações temporárias..."
rm -f config/.env 2>/dev/null || true
rm -rf logs/* 2>/dev/null || true

echo -e "${GREEN}✓ Limpeza concluída${NC}"
echo ""

echo -e "${BLUE}[FASE 2]${NC} Executando instalação limpa..."

# Executar setup
if ./setup.sh; then
    echo -e "${GREEN}✓ Instalação concluída com sucesso${NC}"
else
    echo -e "${RED}✗ Falha na instalação${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[FASE 3]${NC} Aguardando inicialização completa..."

# Aguardar containers ficarem saudáveis
max_attempts=60
attempt=0

while [ $attempt -lt $max_attempts ]; do
    healthy_containers=$(docker compose ps --format "table {{.Service}}\t{{.Status}}" | grep "healthy" | wc -l)
    
    if [ "$healthy_containers" -ge 2 ]; then
        echo -e "${GREEN}✓ Containers inicializados e saudáveis${NC}"
        break
    fi
    
    echo "Aguardando containers... ($((attempt+1))/$max_attempts)"
    sleep 5
    ((attempt++))
done

if [ $attempt -eq $max_attempts ]; then
    echo -e "${RED}✗ Timeout: Containers não ficaram saudáveis${NC}"
    echo "Status atual:"
    docker compose ps
    exit 1
fi

echo ""
echo -e "${BLUE}[FASE 4]${NC} Executando testes de validação..."

# Executar teste de instalação
if ./scripts/test-installation.sh; then
    echo -e "${GREEN}✓ Todos os testes passaram${NC}"
else
    echo -e "${RED}✗ Alguns testes falharam${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[FASE 5]${NC} Testes funcionais avançados..."

# Teste de conectividade HTTP
echo "Testando conectividade HTTP..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|302"; then
    echo -e "${GREEN}✓ Redmine respondendo na porta 3000${NC}"
else
    echo -e "${RED}✗ Redmine não está respondendo${NC}"
    exit 1
fi

# Teste de conectividade via Nginx (se configurado)
echo "Testando conectividade via Nginx..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302"; then
    echo -e "${GREEN}✓ Nginx respondendo na porta 80${NC}"
else
    echo -e "${YELLOW}⚠ Nginx não configurado ou não respondendo (normal se não configurado)${NC}"
fi

# Verificar plugins carregados
echo "Verificando plugins carregados..."
if docker compose exec -T redmine bundle exec rails runner "puts Redmine::Plugin.all.map(&:id)" 2>/dev/null | grep -q "sgime_customizations"; then
    echo -e "${GREEN}✓ Plugin sgime_customizations carregado${NC}"
else
    echo -e "${RED}✗ Plugin sgime_customizations não carregado${NC}"
fi

if docker compose exec -T redmine bundle exec rails runner "puts Redmine::Plugin.all.map(&:id)" 2>/dev/null | grep -q "redmine_dmsf"; then
    echo -e "${GREEN}✓ Plugin redmine_dmsf carregado${NC}"
else
    echo -e "${YELLOW}⚠ Plugin redmine_dmsf não carregado${NC}"
fi

# Teste de banco de dados
echo "Testando conectividade do banco de dados..."
if docker compose exec -T postgres pg_isready -U sgime_user >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL funcionando${NC}"
else
    echo -e "${RED}✗ PostgreSQL com problemas${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                   🎉 INSTALAÇÃO LIMPA CONCLUÍDA! 🎉               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Resumo da instalação:${NC}"
echo "• Todos os containers estão funcionando"
echo "• Plugins essenciais carregados"
echo "• Sistema respondendo nas portas configuradas"
echo "• Banco de dados operacional"
echo ""
echo -e "${YELLOW}Acesse o sistema:${NC}"
echo "• URL: http://localhost:3000"
echo "• Usuário: admin"
echo "• Senha: admin123"
echo ""
echo -e "${YELLOW}Comandos úteis:${NC}"
echo "• Status: ./scripts/manage.sh status"
echo "• Logs: ./scripts/manage.sh logs"
echo "• Backup: ./scripts/manage.sh backup"
echo ""
echo -e "${GREEN}✅ SGIME está pronto para uso!${NC}"
