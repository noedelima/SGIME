# Troubleshooting - SGIME

## Sistema de Gestão Integrada de Engenharia
**Colégio Pedro II - Seção de Engenharia**  
**Versão:** 1.6  
**Data:** Julho de 2025  
**Licença:** GPLv3

---

## Índice

1. [Problemas Comuns de Instalação](#problemas-comuns-de-instalação)
2. [Problemas de Conectividade](#problemas-de-conectividade)
3. [Problemas de Autenticação](#problemas-de-autenticação)
4. [Performance e Otimização](#performance-e-otimização)
5. [Problemas com Plugins](#problemas-com-plugins)
6. [Backup e Recuperação](#backup-e-recuperação)
7. [Logs e Monitoramento](#logs-e-monitoramento)
8. [Problemas Específicos do SGIME](#problemas-específicos-do-sgime)

---

## Problemas Comuns de Instalação

### 1. Docker Compose não encontrado

**Sintoma:**
```bash
bash: docker-compose: command not found
```

**Solução:**
```bash
# Instalar Docker Compose Plugin (recomendado)
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Ou instalar via apt (Ubuntu)
sudo apt update
sudo apt install docker-compose-plugin
```

### 2. Erro de permissões no Docker

**Sintoma:**
```bash
permission denied while trying to connect to the Docker daemon socket
```

**Solução:**
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Reiniciar sessão ou executar
newgrp docker

# Verificar se funcionou
docker ps
```

### 3. Portas já em uso

**Sintoma:**
```bash
ERROR: for sgime_nginx  Cannot start service nginx: driver failed programming external connectivity
```

**Solução:**
```bash
# Verificar quais processos estão usando as portas
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443

# Parar processos conflitantes (exemplo Apache)
sudo systemctl stop apache2
sudo systemctl disable apache2

# Ou alterar portas no arquivo .env
echo "HTTP_PORT=8080" >> config/.env
echo "HTTPS_PORT=8443" >> config/.env
```

### 4. Erro de conexão com PostgreSQL

**Sintoma:**
```bash
could not connect to server: Connection refused
```

**Solução:**
```bash
# Verificar status do contêiner PostgreSQL
docker-compose ps postgres

# Verificar logs do PostgreSQL
docker-compose logs postgres

# Recriar contêiner PostgreSQL
docker-compose stop postgres
docker-compose rm postgres
docker-compose up -d postgres

# Aguardar inicialização completa
docker-compose logs -f postgres
```

---

## Problemas de Conectividade

### 1. Timeout de conexão

**Sintoma:**
- Página não carrega
- Timeout errors no navegador

**Diagnóstico:**
```bash
# Verificar status dos serviços
./scripts/manage.sh status

# Testar conectividade interna
docker-compose exec nginx curl -I http://redmine:3000

# Verificar logs do Nginx
docker-compose logs nginx
```

**Solução:**
```bash
# Reiniciar serviços em ordem
docker-compose restart redis
sleep 10
docker-compose restart postgres
sleep 20
docker-compose restart redmine
sleep 15
docker-compose restart nginx
```

### 2. SSL/TLS não funciona

**Sintoma:**
- Certificado inválido
- Conexão não segura

**Diagnóstico:**
```bash
# Verificar certificados
ls -la config/nginx/ssl/

# Testar SSL
openssl s_client -connect sgime.cp2.g12.br:443 -servername sgime.cp2.g12.br
```

**Solução:**
```bash
# Gerar certificados auto-assinados para desenvolvimento
mkdir -p config/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout config/nginx/ssl/sgime.key \
    -out config/nginx/ssl/sgime.crt \
    -subj "/C=BR/ST=RJ/L=Rio de Janeiro/O=Colégio Pedro II/CN=sgime.cp2.g12.br"

# Ajustar permissões
chmod 600 config/nginx/ssl/sgime.key
chmod 644 config/nginx/ssl/sgime.crt

# Reiniciar Nginx
docker-compose restart nginx
```

### 3. DNS não resolve

**Sintoma:**
- Nome do host não resolve
- Erro "server not found"

**Solução:**
```bash
# Adicionar entrada no /etc/hosts (desenvolvimento)
echo "127.0.0.1 sgime.cp2.g12.br" | sudo tee -a /etc/hosts

# Para produção, configurar DNS apropriado
# Consultar administrador de rede
```

---

## Problemas de Autenticação

### 1. LDAP não conecta

**Sintoma:**
- Login via LDAP falha
- Usuários não conseguem autenticar

**Diagnóstico:**
```bash
# Testar conexão LDAP
ldapsearch -x -H ldap://ldap.cp2.g12.br:389 \
    -D "CN=sgime-service,OU=Service Accounts,DC=cp2,DC=g12,DC=br" \
    -w "senha_service" \
    -b "DC=cp2,DC=g12,DC=br" "(objectClass=person)"
```

**Solução:**
```bash
# Verificar configurações LDAP no arquivo .env
cat config/.env | grep LDAP

# Verificar logs do Redmine para erros LDAP
docker-compose logs redmine | grep -i ldap

# Testar conectividade de rede
docker-compose exec redmine nc -zv ldap.cp2.g12.br 389
```

### 2. SSO Azure não funciona

**Sintoma:**
- Redirecionamento para Azure falha
- Erro de configuração OAuth

**Diagnóstico:**
```bash
# Verificar configurações Azure
cat config/.env | grep AZURE

# Verificar logs de autenticação
docker-compose logs redmine | grep -i azure
docker-compose logs redmine | grep -i oauth
```

**Solução:**
```bash
# Verificar URLs de callback no Azure Portal
# URL deve ser: https://sgime.cp2.g12.br/auth/azure_oauth2/callback

# Verificar se plugin está instalado
docker-compose exec redmine ls -la plugins/ | grep azure

# Reinstalar plugin se necessário
docker-compose exec redmine bash -c "
cd plugins && 
git clone https://github.com/alexandermeindl/redmine_omniauth_azure.git &&
cd .. &&
bundle install &&
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
"
```

### 3. Senha do admin esquecida

**Sintoma:**
- Não consegue fazer login como admin
- Perdeu acesso administrativo

**Solução:**
```bash
# Resetar senha do admin via console Rails
docker-compose exec redmine bash -c "
bundle exec rails console -e production << 'EOF'
user = User.find_by(login: 'admin')
user.password = 'nova_senha_admin_123!'
user.password_confirmation = 'nova_senha_admin_123!'
user.save!
puts 'Senha do admin atualizada com sucesso!'
EOF
"

# Ou via rake task
docker-compose exec redmine bundle exec rake redmine:admin:reset_password RAILS_ENV=production
```

---

## Performance e Otimização

### 1. Sistema lento

**Sintoma:**
- Páginas demoram para carregar
- Timeouts frequentes

**Diagnóstico:**
```bash
# Verificar uso de recursos
docker stats

# Verificar logs de performance
docker-compose logs redmine | grep -E "(ERROR|WARN|slow)"

# Verificar conexões do banco
docker-compose exec postgres psql -U sgime_user -d sgime_production -c "
SELECT count(*) as conexoes_ativas, state 
FROM pg_stat_activity 
WHERE datname = 'sgime_production' 
GROUP BY state;
"
```

**Solução:**
```bash
# Aumentar recursos para contêineres (docker-compose.yml)
# Adicionar limites de memória e CPU:

services:
  redmine:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
          
  postgres:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'

# Otimizar banco de dados
docker-compose exec postgres psql -U sgime_user -d sgime_production -c "
VACUUM ANALYZE;
REINDEX DATABASE sgime_production;
"

# Limpar cache do Redis
docker-compose exec redis redis-cli -a redis_senha_segura_2025! FLUSHALL
```

### 2. Alto uso de memória

**Sintoma:**
- Contêineres consumindo muita RAM
- OOM (Out of Memory) kills

**Solução:**
```bash
# Monitorar uso de memória
watch -n 5 'docker stats --no-stream'

# Configurar swap se necessário
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Adicionar ao /etc/fstab para persistir
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Otimizar configurações do PostgreSQL
cat << 'EOF' > config/postgres/postgresql.conf
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1
effective_io_concurrency = 200
EOF

# Reiniciar PostgreSQL
docker-compose restart postgres
```

### 3. Disco cheio

**Sintoma:**
- Erro "No space left on device"
- Impossível salvar dados

**Diagnóstico:**
```bash
# Verificar uso do disco
df -h

# Verificar tamanho dos volumes Docker
docker system df

# Verificar logs grandes
find /var/lib/docker -name "*.log" -size +100M
```

**Solução:**
```bash
# Limpar containers parados e imagens não utilizadas
docker system prune -a

# Limpar logs antigos
docker-compose exec redmine find log/ -name "*.log" -mtime +30 -delete
docker-compose exec nginx find /var/log/nginx -name "*.log" -mtime +7 -delete

# Configurar rotação de logs
cat << 'EOF' > /etc/logrotate.d/docker-sgime
/var/lib/docker/containers/*/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    copytruncate
}
EOF

# Executar limpeza de backups antigos
./scripts/manage.sh cleanup-backups
```

---

## Problemas com Plugins

### 1. Plugin não carrega

**Sintoma:**
- Plugin não aparece na administração
- Funcionalidades não disponíveis

**Diagnóstico:**
```bash
# Listar plugins instalados
docker-compose exec redmine ls -la plugins/

# Verificar logs de inicialização
docker-compose logs redmine | grep -i plugin

# Verificar migrações pendentes
docker-compose exec redmine bundle exec rake redmine:plugins:migrate:status RAILS_ENV=production
```

**Solução:**
```bash
# Executar migrações dos plugins
docker-compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production

# Instalar gems necessárias
docker-compose exec redmine bundle install

# Reiniciar Redmine
docker-compose restart redmine

# Se necessário, recompilar assets
docker-compose exec redmine bundle exec rake assets:precompile RAILS_ENV=production
```

### 2. Conflito entre plugins

**Sintoma:**
- Erro 500 após instalar plugin
- Funcionalidades quebradas

**Solução:**
```bash
# Desabilitar plugins um por um para identificar conflito
cd plugins/
mv plugin_suspeito plugin_suspeito.disabled

# Reiniciar e testar
docker-compose restart redmine

# Verificar compatibilidade de versões
# Consultar documentação dos plugins

# Se necessário, downgrade ou upgrade de plugins
```

### 3. Plugin customizado do SGIME com erro

**Sintoma:**
- Funcionalidades específicas do SGIME não funcionam

**Diagnóstico:**
```bash
# Verificar plugin customizado
ls -la plugins/sgime_customizations/

# Verificar logs específicos
docker-compose logs redmine | grep -i sgime
```

**Solução:**
```bash
# Reconstruir contêiner com plugin atualizado
docker-compose build redmine
docker-compose up -d redmine

# Ou atualizar plugin manualmente
docker-compose exec redmine bash -c "
cd plugins/sgime_customizations &&
git pull origin main &&
cd ../.. &&
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
"
```

---

## Backup e Recuperação

### 1. Backup falha

**Sintoma:**
- Script de backup retorna erro
- Arquivos de backup corrompidos

**Diagnóstico:**
```bash
# Verificar espaço em disco
df -h /var/backups/sgime

# Testar backup manual
./scripts/manage.sh backup-db
./scripts/manage.sh backup-files

# Verificar logs de backup
cat logs/backup/backup.log
```

**Solução:**
```bash
# Verificar permissões do diretório de backup
sudo chown -R $(id -u):$(id -g) backups/
chmod -R 755 backups/

# Verificar se PostgreSQL aceita conexões
docker-compose exec postgres pg_isready -U sgime_user

# Executar backup com verbose
docker-compose exec postgres pg_dump -U sgime_user -v sgime_production > backup_manual.sql
```

### 2. Restauração falha

**Sintoma:**
- Erro ao restaurar backup
- Dados incompletos após restauração

**Solução:**
```bash
# Verificar integridade do backup
gzip -t backup_arquivo.tar.gz

# Restaurar passo a passo
./scripts/manage.sh stop
docker volume rm sgime_postgres_data
docker volume rm sgime_redmine_files
./scripts/manage.sh start
./scripts/manage.sh restore /caminho/para/backup.tar.gz

# Se falhar, restaurar manualmente
docker-compose exec postgres createdb -U sgime_user sgime_production_temp
docker-compose exec postgres psql -U sgime_user -d sgime_production_temp -f /backups/backup.sql
```

---

## Logs e Monitoramento

### 1. Logs não são gerados

**Sintoma:**
- Diretório de logs vazio
- Dificuldade para debugar problemas

**Solução:**
```bash
# Verificar mapeamento de volumes
docker-compose config | grep -A 5 -B 5 logs

# Criar diretórios de logs se não existirem
mkdir -p logs/{redmine,nginx,postgres,worker}
chmod -R 755 logs/

# Verificar se contêineres estão escrevendo logs
docker-compose logs --tail=50 redmine
docker-compose logs --tail=50 nginx
```

### 2. Muitos logs, disco enchendo

**Sintoma:**
- Logs ocupando muito espaço
- Performance degradada

**Solução:**
```bash
# Configurar rotação de logs automática
cat << 'EOF' > /etc/logrotate.d/sgime
/home/noedelima/source/SGIME/logs/*/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 644 root root
    postrotate
        docker-compose -f /home/noedelima/source/SGIME/docker-compose.yml restart nginx
    endscript
}
EOF

# Limpar logs antigos imediatamente
find logs/ -name "*.log" -mtime +7 -delete

# Configurar log level para reduzir verbosidade
echo "LOG_LEVEL=warn" >> config/.env
docker-compose restart redmine
```

### 3. Monitoramento de saúde

**Scripts de Monitoramento:**

```bash
#!/bin/bash
# script_monitoramento.sh

# Verificar saúde dos serviços
check_service_health() {
    service=$1
    if ! docker-compose ps $service | grep -q "Up"; then
        echo "ALERTA: Serviço $service não está rodando!"
        return 1
    fi
    return 0
}

# Verificar uso de recursos
check_resources() {
    # Verificar uso de disco
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $disk_usage -gt 85 ]; then
        echo "ALERTA: Uso de disco em ${disk_usage}%"
    fi
    
    # Verificar uso de memória
    mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ $mem_usage -gt 85 ]; then
        echo "ALERTA: Uso de memória em ${mem_usage}%"
    fi
}

# Verificar conectividade
check_connectivity() {
    if ! curl -f -s http://localhost/health > /dev/null; then
        echo "ALERTA: SGIME não está respondendo!"
        return 1
    fi
    return 0
}

# Executar verificações
check_service_health postgres
check_service_health redis  
check_service_health redmine
check_service_health nginx
check_resources
check_connectivity

echo "Monitoramento concluído: $(date)"
```

---

## Problemas Específicos do SGIME

### 1. Tema customizado não carrega

**Sintoma:**
- Interface não aparece com visual do SGIME
- CSS não aplicado

**Solução:**
```bash
# Verificar se tema está instalado
docker-compose exec redmine ls -la public/themes/sgime_theme/

# Recompilar assets
docker-compose exec redmine bundle exec rake assets:precompile RAILS_ENV=production

# Limpar cache do navegador
# Pressionar Ctrl+Shift+R ou Cmd+Shift+R

# Verificar configuração do tema no Redmine
# Administração → Configurações → Geral → Tema
```

### 2. Campos customizados não aparecem

**Sintoma:**
- Campos específicos do SGIME não são exibidos
- Formulários incompletos

**Solução:**
```bash
# Verificar se migrações dos campos customizados foram executadas
docker-compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production

# Verificar se há problemas de permissão
# Administração → Campos customizados
# Verificar se estão habilitados para os trackers corretos

# Recriar campos se necessário via console Rails
docker-compose exec redmine bundle exec rails console -e production
```

### 3. Integração com sistemas externos falha

**Sintoma:**
- APIs externas não respondem
- Webhooks não são enviados

**Diagnóstico:**
```bash
# Testar conectividade de rede
docker-compose exec redmine curl -I https://api-externa.exemplo.com

# Verificar logs de integração
docker-compose logs redmine | grep -i webhook
docker-compose logs redmine | grep -i integration
```

**Solução:**
```bash
# Verificar configurações de proxy se necessário
# Adicionar ao docker-compose.yml se houver proxy corporativo:

environment:
  - HTTP_PROXY=http://proxy.cp2.g12.br:8080
  - HTTPS_PROXY=http://proxy.cp2.g12.br:8080
  - NO_PROXY=localhost,127.0.0.1,postgres,redis

# Verificar certificados SSL para APIs externas
docker-compose exec redmine openssl s_client -connect api-externa.exemplo.com:443
```

---

## Comandos Úteis para Troubleshooting

### Debug Geral

```bash
# Status completo do sistema
./scripts/manage.sh status

# Logs em tempo real
./scripts/manage.sh logs

# Informações dos volumes
docker volume ls | grep sgime
docker volume inspect sgime_postgres_data

# Informações da rede
docker network ls | grep sgime
docker network inspect sgime_network

# Processos dentro dos contêineres
docker-compose exec redmine ps aux
docker-compose exec postgres ps aux
```

### Limpeza e Manutenção

```bash
# Limpeza completa (CUIDADO!)
./scripts/manage.sh stop
docker system prune -a --volumes
docker volume prune

# Reconstrução completa
docker-compose build --no-cache
docker-compose up -d

# Verificação de integridade
docker-compose exec postgres pg_dump --schema-only -U sgime_user sgime_production
docker-compose exec redmine bundle exec rake redmine:check RAILS_ENV=production
```

---

## Suporte e Recursos Adicionais

### Contatos de Suporte

- **E-mail Primário**: geeng@cp2.g12.br
- **E-mail Técnico**: geeng@cp2.g12.br
- **Telefone**: (21) 2569-1234 (Ramal: 5678)
- **Horário de Atendimento**: Segunda a Sexta, 8h às 18h

### Recursos Online

- **Documentação Oficial**: https://sgime.cp2.g12.br/docs
- **Base de Conhecimento**: https://sgime.cp2.g12.br/kb
- **Fórum da Comunidade**: https://forum.sgime.cp2.g12.br
- **Status Page**: https://status.sgime.cp2.g12.br

### Logs de Sistema para Enviar ao Suporte

```bash
# Coletar logs para suporte
mkdir -p /tmp/sgime-debug
./scripts/manage.sh logs > /tmp/sgime-debug/services.log
docker-compose config > /tmp/sgime-debug/compose-config.yml
docker system info > /tmp/sgime-debug/docker-info.txt
cat config/.env > /tmp/sgime-debug/env-config.txt  # Remover senhas!
tar -czf sgime-debug-$(date +%Y%m%d-%H%M%S).tar.gz -C /tmp sgime-debug/

echo "Arquivo de debug criado: sgime-debug-$(date +%Y%m%d-%H%M%S).tar.gz"
echo "Envie este arquivo para geeng@cp2.g12.br"
```

---

**Última atualização:** 23 de julho de 2025  
**Versão do documento:** 1.6.0

---

*Este documento é parte da documentação oficial do SGIME - Sistema de Gestão Integrada de Engenharia do Colégio Pedro II. Para sugestões e correções, entre em contato com a Seção de Engenharia.*
