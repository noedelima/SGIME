# Configurações do SGIME
# Sistema de Gestão Integrada de Engenharia

production:
  # Configurações específicas do SGIME
  sgime:
    version: "1.6"
    organization_name: "<%= ENV['ORGANIZATION_NAME'] || 'Colégio Pedro II' %>"
    department_name: "<%= ENV['DEPARTMENT_NAME'] || 'Seção de Engenharia' %>"
    contact_email: "<%= ENV['SGIME_CONTACT_EMAIL'] || 'engenharia@cp2.g12.br' %>"
    base_url: "<%= ENV['SGIME_BASE_URL'] || 'https://sgime.cp2.g12.br' %>"

  # Configurações de email
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: "<%= ENV['SMTP_HOST'] %>"
      port: <%= ENV['SMTP_PORT'] || 587 %>
      domain: "<%= ENV['SMTP_DOMAIN'] %>"
      authentication: "<%= ENV['SMTP_AUTHENTICATION'] || 'login' %>"
      user_name: "<%= ENV['SMTP_USER'] %>"
      password: "<%= ENV['SMTP_PASS'] %>"
      enable_starttls_auto: <%= ENV['SMTP_ENABLE_STARTTLS_AUTO'] == 'true' %>

  # Configurações de cache (Redis)
  cache_store: :redis_cache_store
  cache_store_options:
    url: "redis://redis:6379/0"
    expires_in: 1.hour

  # Configurações de sessão
  session_store: :redis_session_store
  session_options:
    redis_server: "redis://redis:6379/1"
    expire_after: 24.hours

  # Configurações de log
  log_level: :info
  log_formatter: ::Logger::Formatter.new

development:
  # Herdar configurações de produção
  <<: *production
  
  # Sobrescrever configurações específicas para desenvolvimento
  sgime:
    base_url: "http://localhost:3000"
    
  log_level: :debug

test:
  # Configurações mínimas para testes
  sgime:
    version: "1.6"
    organization_name: "Colégio Pedro II - Teste"
