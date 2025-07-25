# Dockerfile para Redmine customizado do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia
# Licença: GPLv3

# Usar argumentos para versões flexíveis
ARG REDMINE_VERSION=5.1
ARG RUBY_VERSION=3.2

FROM redmine:${REDMINE_VERSION}-alpine

# Metadados do projeto
LABEL maintainer="Seção de Engenharia - Colégio Pedro II <geeng@cp2.g12.br>"
LABEL version="1.6"
LABEL description="SGIME - Sistema de Gestão Integrada de Engenharia baseado em Redmine"

# Definir usuário root temporariamente para instalações
USER root

# Instalar dependências do sistema
RUN apk add --no-cache \
    git \
    curl \
    wget \
    unzip \
    imagemagick \
    ghostscript \
    build-base \
    postgresql-dev \
    nodejs \
    npm \
    && rm -rf /var/cache/apk/*

# Criar diretórios necessários
RUN mkdir -p /usr/src/redmine/plugins \
    && mkdir -p /usr/src/redmine/public/themes \
    && mkdir -p /usr/src/redmine/config/additional_config

# Instalar plugins essenciais do SGIME
WORKDIR /usr/src/redmine/plugins

# Plugin: Redmine Checklists (listas de verificação)
RUN git clone https://github.com/rmantovani68/redmine_checklists.git redmine_checklists

# Plugin: Redmine Recurring Tasks (tarefas recorrentes)
RUN git clone https://github.com/nutso/redmine-plugin-recurring-tasks.git redmine_recurring_tasks

# Plugin: Redmine Dashboard (dashboards customizáveis)
RUN git clone https://github.com/jgraichen/redmine_dashboard.git redmine_dashboard

# Plugin: Redmine DMSF (gestão de documentos)
RUN git clone https://github.com/danmunn/redmine_dmsf.git redmine_dmsf

# Plugin: Redmine Attach Preview (visualização de anexos)
RUN git clone https://github.com/alexandermeindl/redmine_attach_preview.git redmine_attach_preview

# Plugin: Redmine OmniAuth Azure (SSO Microsoft)
RUN git clone https://github.com/alexandermeindl/redmine_omniauth_azure.git redmine_omniauth_azure

# Plugin: Redmine Advanced Roadmap (Gantt avançado)
RUN git clone https://github.com/nanego/redmine_advanced_roadmap.git redmine_advanced_roadmap

# Plugin: Redmine Custom Workflows (fluxos personalizados)  
RUN git clone https://github.com/anteo/redmine_custom_workflows.git redmine_custom_workflows

# Instalar tema responsivo para SGIME
WORKDIR /usr/src/redmine/public/themes
RUN git clone https://github.com/mrliptontea/PurpleMine2.git sgime_theme \
    && cd sgime_theme \
    && git checkout master

# Copiar configurações customizadas
COPY config/redmine/ /usr/src/redmine/config/additional_config/

# Copiar customizações específicas do SGIME (temporariamente comentado)
# COPY plugins/sgime_customizations/ /usr/src/redmine/plugins/sgime_customizations/

# Voltar ao diretório principal do Redmine
WORKDIR /usr/src/redmine

# Instalar gems adicionais necessárias
RUN echo "gem 'omniauth-azure-oauth2'" >> Gemfile.local \
    && echo "gem 'rmagick'" >> Gemfile.local \
    && echo "gem 'dalli'" >> Gemfile.local \
    && echo "gem 'redis'" >> Gemfile.local

# Instalar dependências Ruby
RUN bundle install --without development test

# Definir permissões adequadas
RUN chown -R redmine:redmine /usr/src/redmine \
    && chmod -R 755 /usr/src/redmine/plugins \
    && chmod -R 755 /usr/src/redmine/public/themes

# Voltar ao usuário redmine
USER redmine

# Script de inicialização
COPY docker/redmine/docker-entrypoint.sh /docker-entrypoint.sh
USER root
RUN chmod +x /docker-entrypoint.sh
USER redmine

# Configurar ponto de entrada
ENTRYPOINT ["/docker-entrypoint.sh"]

# Comando padrão
CMD ["rails", "server", "-b", "0.0.0.0"]

# Expor porta do Redmine
EXPOSE 3000

# Health check
HEALTHCHECK --interval=1m --timeout=30s --start-period=2m --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1
