# 🔧 INSTALAÇÃO DO SGIME v1.8

## 🎯 Instalação Automatizada (Recomendada)

### **Pré-requisitos**
- **Docker**: 20.x ou superior
- **Docker Compose**: 2.x ou superior  
- **Git**: Para clone do repositório
- **Sistema**: Linux (Ubuntu/Debian/CentOS/RHEL)
- **Hardware**: 4GB RAM, 20GB disco, 2 CPUs

### **Instalação Rápida (5 minutos)**

```bash
# 1. Clone do repositório
git clone https://github.com/colegiopedro2/sgime.git
cd sgime

# 2. Executar setup automatizado
./setup.sh

# 3. Aguardar conclusão (5-10 minutos)
# O script irá:
# - Configurar ambiente Docker
# - Criar containers PostgreSQL + Redmine + Nginx
# - Instalar e configurar todos os 6 plugins
# - Executar migrações do banco
# - Configurar permissões e usuários
```

### **Acesso ao Sistema**
- **URL**: http://localhost
- **Usuário**: admin
- **Senha**: admin (alterar no primeiro acesso)

---

## 🐳 **Instalação Manual (Docker)**

### **1. Preparação do Ambiente**

```bash
# Clone do repositório
git clone https://github.com/colegiopedro2/sgime.git
cd sgime

# Copiar arquivo de configuração
cp config/env.example .env

# Editar configurações (opcional)
nano .env
```

### **2. Configurações de Banco**

```bash
# Arquivo .env - principais configurações:
POSTGRES_DB=sgime_production
POSTGRES_USER=sgime
POSTGRES_PASSWORD=sgime123!@#
POSTGRES_HOST=postgres

REDMINE_SECRET_KEY_BASE=sua_chave_secreta_aqui
REDMINE_DB_ADAPTER=postgresql
```

### **3. Inicialização dos Containers**

```bash
# Construir e iniciar containers
docker compose up -d

# Verificar status
docker compose ps

# Logs em tempo real
docker compose logs -f redmine
```

### **4. Configuração Inicial**

```bash
# Executar migrações
docker compose exec redmine bundle exec rake db:migrate RAILS_ENV=production

# Configurar plugins
docker compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production

# Carregar dados iniciais
docker compose exec redmine bundle exec rake redmine:load_default_data RAILS_ENV=production REDMINE_LANG=pt-BR

# Criar usuário admin
docker compose exec redmine bundle exec rake redmine:create_admin RAILS_ENV=production
```

---

## 💻 **Instalação Nativa (Sem Docker)**

### **1. Pré-requisitos**

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y ruby3.3 ruby3.3-dev nodejs npm postgresql postgresql-contrib
sudo apt install -y build-essential libpq-dev imagemagick libmagickwand-dev

# CentOS/RHEL
sudo yum install -y ruby ruby-devel nodejs npm postgresql postgresql-server postgresql-devel
sudo yum groupinstall -y "Development Tools"
```

### **2. Configuração do PostgreSQL**

```bash
# Inicializar PostgreSQL
sudo postgresql-setup initdb
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Criar usuário e banco
sudo -u postgres createuser -s sgime
sudo -u postgres createdb sgime_production -O sgime
sudo -u postgres psql -c "ALTER USER sgime PASSWORD 'sgime123';"
```

### **3. Configuração do Redmine**

```bash
# Clone e configuração
git clone https://github.com/colegiopedro2/sgime.git /opt/sgime
cd /opt/sgime

# Instalar dependências Ruby
gem install bundler
bundle install --without development test

# Configurar banco
cp config/database.yml.example config/database.yml
# Editar database.yml com credenciais PostgreSQL

# Configurar aplicação
cp config/configuration.yml.example config/configuration.yml
export RAILS_ENV=production

# Migrações e setup
bundle exec rake generate_secret_token
bundle exec rake db:migrate
bundle exec rake redmine:plugins:migrate
bundle exec rake redmine:load_default_data REDMINE_LANG=pt-BR
```

---

## 🌐 **Configuração do Nginx**

### **Docker (Automático)**
O Nginx já está configurado no docker-compose.yml.

### **Instalação Nativa**

```bash
# Instalar Nginx
sudo apt install nginx  # Ubuntu/Debian
sudo yum install nginx  # CentOS/RHEL

# Copiar configuração
sudo cp config/nginx/nginx.conf /etc/nginx/sites-available/sgime
sudo ln -s /etc/nginx/sites-available/sgime /etc/nginx/sites-enabled/

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

---

## 🔐 **Configuração SSL (Produção)**

### **Certificado Let's Encrypt**

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d sgime.colegiopedro2.edu.br

# Renovação automática
sudo crontab -e
# Adicionar: 0 12 * * * /usr/bin/certbot renew --quiet
```

### **Certificado Próprio**

```bash
# Gerar certificado autoassinado
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/sgime.key \
  -out /etc/ssl/certs/sgime.crt

# Atualizar configuração Nginx
# Descomentar linhas SSL em config/nginx/nginx.conf
```

---

## 📊 **Verificação da Instalação**

### **Checklist Pós-Instalação**

```bash
# 1. Verificar containers (Docker)
docker compose ps
# Todos devem estar "healthy"

# 2. Verificar conectividade
curl -I http://localhost
# Deve retornar 200 OK

# 3. Verificar plugins
curl http://localhost/admin/plugins
# Deve listar 6 plugins ativos

# 4. Verificar logs
tail -f logs/redmine/production.log
# Sem erros críticos

# 5. Teste de login
# Acessar http://localhost
# Login: admin / admin
```

### **Scripts de Validação**

```bash
# Usar script de verificação
./verificar-sistema.sh

# Verificar status dos serviços
./scripts/manage.sh status

# Teste de performance
./scripts/manage.sh test
```

---

## 🔧 **Troubleshooting**

### **Problemas Comuns**

#### **Docker não inicia**
```bash
# Verificar logs
docker compose logs redmine postgres nginx

# Reiniciar containers
docker compose down
docker compose up -d
```

#### **Banco não conecta**
```bash
# Verificar PostgreSQL
docker compose exec postgres psql -U sgime -d sgime_production -c "\l"

# Recriar banco se necessário
./scripts/manage.sh reset-db
```

#### **Plugins não carregam**
```bash
# Forçar migração de plugins
docker compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production

# Verificar logs específicos
docker compose logs redmine | grep -i plugin
```

#### **Performance lenta**
```bash
# Verificar recursos
docker stats

# Otimizar configurações
# Editar docker-compose.yml - aumentar memória
# Editar config/additional_environment.rb - pool de conexões
```

---

## 📞 **Suporte**

### **Documentação**
- `README.md` - Visão geral
- `PLUGINS.md` - Detalhes dos plugins
- `docs/` - Documentação técnica completa

### **Logs**
- `logs/redmine/` - Logs do Redmine
- `logs/nginx/` - Logs do Nginx  
- `logs/postgres/` - Logs do PostgreSQL

### **Comunidade**
- Issues GitHub
- Documentação Redmine oficial
- Fórum da comunidade

**Sistema pronto para produção! 🚀**
