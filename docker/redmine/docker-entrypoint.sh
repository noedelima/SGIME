#!/bin/bash
# Script de entrada personalizado para o Redmine do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

set -e

# Função para log
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] SGIME: $1"
}

log "Iniciando configuração do SGIME..."

# Aguardar o banco de dados estar disponível
log "Aguardando conexão com o banco de dados..."
until PGPASSWORD=$REDMINE_DB_PASSWORD psql -h "$REDMINE_DB_POSTGRES" -U "$REDMINE_DB_USERNAME" -d "$REDMINE_DB_DATABASE" -c '\l' > /dev/null 2>&1; do
    log "Banco de dados não disponível, aguardando..."
    sleep 5
done
log "Conexão com banco de dados estabelecida."

# Executar migrações do banco
log "Executando migrações do banco de dados..."
bundle exec rake db:migrate RAILS_ENV=production

# Executar migrações dos plugins
log "Executando migrações dos plugins..."
bundle exec rake redmine:plugins:migrate RAILS_ENV=production

# Copiar assets dos plugins (necessário para servir /plugin_assets/* em produção)
log "Instalando assets dos plugins em public/plugin_assets..."
bundle exec rake redmine:plugins:assets RAILS_ENV=production

# Configurar dados iniciais se for primeira execução
if [ ! -f /usr/src/redmine/config/.sgime_initialized ]; then
    log "Primeira execução detectada. Configurando dados iniciais..."
    
    # Carregar dados padrão do Redmine
    bundle exec rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=pt-BR || true
    
    # Executar script de configuração inicial do SGIME
    bundle exec rake sgime:setup RAILS_ENV=production || true
    
    # Marcar como inicializado
    touch /usr/src/redmine/config/.sgime_initialized
    log "Configuração inicial concluída."
fi

# Compilar assets
log "Compilando assets..."
bundle exec rake assets:precompile RAILS_ENV=production

# Limpar cache
log "Limpando cache..."
bundle exec rake tmp:cache:clear RAILS_ENV=production || true

# Configurar permissões
log "Configurando permissões de arquivos..."
mkdir -p /usr/src/redmine/tmp/pdf
mkdir -p /usr/src/redmine/files
mkdir -p /usr/src/redmine/log

# Definir configurações específicas do SGIME
export RAILS_ENV=production
export REDMINE_LANG=pt-BR

log "Configuração do SGIME finalizada. Iniciando aplicação..."

# Executar comando passado como parâmetro
exec "$@"
