#!/bin/bash
# Script de Teste da Instalação do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia
# Versão: 1.0

# Removido set -e para permitir que testes falhem sem parar o script

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Função para log colorido
test_log() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

test_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
    ((TESTS_TOTAL++))
}

test_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
    ((TESTS_TOTAL++))
}

test_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Banner
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    SGIME - Teste de Instalação                  ║"
echo "║           Sistema de Gestão Integrada de Engenharia             ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

test_log "Iniciando testes de instalação do SGIME..."

# Teste 1: Verificar se Docker está instalado e rodando
test_log "1. Verificando Docker..."
if command -v docker &> /dev/null && docker info &> /dev/null; then
    test_pass "Docker está instalado e rodando"
else
    test_fail "Docker não está instalado ou não está rodando"
fi

# Teste 2: Verificar se Docker Compose está disponível
test_log "2. Verificando Docker Compose..."
if docker compose version &> /dev/null; then
    test_pass "Docker Compose está disponível"
else
    test_fail "Docker Compose não está disponível"
fi

# Teste 3: Verificar arquivos essenciais
test_log "3. Verificando arquivos essenciais..."
essential_files=(
    "setup.sh"
    "docker-compose.yml"
    "config/env.example"
    "scripts/setup-plugins.sh"
    "scripts/manage.sh"
)

for file in "${essential_files[@]}"; do
    if [ -f "$file" ]; then
        test_pass "Arquivo encontrado: $file"
    else
        test_fail "Arquivo não encontrado: $file"
    fi
done

# Teste 4: Verificar permissões de scripts
test_log "4. Verificando permissões de scripts..."
scripts=(
    "setup.sh"
    "scripts/setup-plugins.sh"
    "scripts/manage.sh"
    "scripts/install.sh"
)

for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        test_pass "Script executável: $script"
    else
        test_fail "Script não executável: $script"
    fi
done

# Teste 5: Verificar plugin customizado
test_log "5. Verificando plugin customizado SGIME..."
if [ -d "plugins/sgime_customizations" ]; then
    test_pass "Plugin sgime_customizations encontrado"
    
    # Verificar arquivos do plugin
    plugin_files=(
        "plugins/sgime_customizations/init.rb"
        "plugins/sgime_customizations/assets/stylesheets/sgime_custom.css"
    )
    
    for file in "${plugin_files[@]}"; do
        if [ -f "$file" ]; then
            test_pass "Arquivo do plugin encontrado: $(basename $file)"
        else
            test_fail "Arquivo do plugin não encontrado: $file"
        fi
    done
else
    test_fail "Plugin sgime_customizations não encontrado"
fi

# Teste 6: Verificar se containers estão rodando (se sistema já foi inicializado)
test_log "6. Verificando containers (se sistema estiver rodando)..."
if docker compose ps &> /dev/null; then
    containers=$(docker compose ps --services --filter "status=running" 2>/dev/null || true)
    if [ ! -z "$containers" ]; then
        test_pass "Sistema SGIME está rodando"
        
        # Testar conectividade HTTP
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|302\|401"; then
            test_pass "Redmine está respondendo na porta 3000"
        else
            test_fail "Redmine não está respondendo na porta 3000"
        fi
        
        # Verificar saúde dos containers
        healthy_containers=$(docker compose ps --filter "status=running" --format "table {{.Service}}\t{{.Status}}" | grep "healthy" | wc -l)
        if [ "$healthy_containers" -gt 0 ]; then
            test_pass "$healthy_containers containers estão saudáveis"
        else
            test_warn "Nenhum container reportando status de saúde"
        fi
    else
        test_warn "Sistema SGIME não está rodando (normal se ainda não foi inicializado)"
    fi
else
    test_warn "Docker Compose não configurado (normal se ainda não foi instalado)"
fi

# Teste 7: Verificar estrutura de diretórios
test_log "7. Verificando estrutura de diretórios..."
directories=(
    "plugins"
    "scripts"
    "config"
    "docs"
    "docker"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        test_pass "Diretório encontrado: $dir"
    else
        test_fail "Diretório não encontrado: $dir"
    fi
done

# Teste 8: Verificar documentação
test_log "8. Verificando documentação..."
docs=(
    "README.md"
    "INICIO-RAPIDO.md"
    "docs/plugins.md"
    "docs/guia-administrador.md"
)

for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        test_pass "Documentação encontrada: $(basename $doc)"
    else
        test_fail "Documentação não encontrada: $doc"
    fi
done

# Relatório final
echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                        RELATÓRIO FINAL                          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Total de testes: ${BLUE}$TESTS_TOTAL${NC}"
echo -e "Testes passou: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Testes falharam: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ SUCESSO: Todos os testes passaram!${NC}"
    echo -e "${GREEN}   O SGIME está pronto para instalação/uso.${NC}"
    echo ""
    echo -e "${YELLOW}Próximos passos:${NC}"
    if ! docker compose ps &> /dev/null || [ -z "$(docker compose ps --services --filter 'status=running' 2>/dev/null)" ]; then
        echo "1. Execute: ./setup.sh"
        echo "2. Aguarde a instalação completa"
        echo "3. Acesse: http://localhost:3000"
    else
        echo "1. Sistema já está rodando"
        echo "2. Acesse: http://localhost:3000"
        echo "3. Use: ./scripts/manage.sh para gerenciar"
    fi
    exit 0
else
    echo ""
    echo -e "${RED}❌ FALHA: $TESTS_FAILED teste(s) falharam.${NC}"
    echo -e "${RED}   Verifique os problemas acima antes de prosseguir.${NC}"
    exit 1
fi
