# Guia do Administrador - SGIME

**Sistema de Gestão Integrada de Engenharia**  
**Colégio Pedro II - Seção de Engenharia**  
**Versão 1.6 - Julho 2025**

---

## Sumário

1. [Visão Geral](#visão-geral)
2. [Instalação e Configuração](#instalação-e-configuração)
3. [Gestão de Usuários](#gestão-de-usuários)
4. [Configuração de Projetos](#configuração-de-projetos)
5. [Personalização do Sistema](#personalização-do-sistema)
6. [Backup e Recuperação](#backup-e-recuperação)
7. [Monitoramento e Logs](#monitoramento-e-logs)
8. [Troubleshooting](#troubleshooting)

---

## Visão Geral

Este guia destina-se aos administradores responsáveis pela instalação, configuração e manutenção do SGIME. Cobre aspectos técnicos avançados e procedimentos administrativos.

### Arquitetura do Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx Proxy   │    │   Redmine App   │    │  PostgreSQL DB  │
│   (Port 80/443) │────│   (Port 3000)   │────│   (Port 5432)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         │              ┌─────────────────┐    ┌─────────────────┐
         │              │   Redis Cache   │    │  Backup Service │
         └──────────────│   (Port 6379)   │    │   (Automated)   │
                        └─────────────────┘    └─────────────────┘
```

### Componentes Principais

- **Redmine 5.1.x**: Plataforma base
- **PostgreSQL 16.x**: Banco de dados principal
- **Nginx**: Proxy reverso e SSL termination
- **Redis**: Cache e sessões
- **Docker/Kubernetes**: Containerização

## Instalação e Configuração

### Pré-requisitos do Sistema

#### Hardware Mínimo
- **Desenvolvimento**: 4GB RAM, 2 CPU cores, 20GB disco
- **Produção**: 16GB RAM, 8 CPU cores, 200GB disco SSD

#### Software Base
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y docker.io docker-compose git

# Fedora/RHEL
sudo dnf install -y docker docker-compose git

# Inicializar Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### Instalação Automatizada

```bash
# Clone do repositório
git clone https://github.com/noedelima/SGIME.git
cd SGIME

# Executar instalação
chmod +x scripts/install.sh
./scripts/install.sh
```

### Configuração Manual

#### 1. Variáveis de Ambiente

Edite `config/.env`:

```bash
# Banco de dados
POSTGRES_DB=sgime_production
POSTGRES_USER=sgime_user
POSTGRES_PASSWORD=SuaSenhaSegura2025!

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_USER=sgime@cp2.g12.br
SMTP_PASS=senha_aplicacao

# LDAP/AD
LDAP_HOST=ldap.cp2.g12.br
LDAP_BASE_DN=DC=cp2,DC=g12,DC=br

# SSL
SSL_CERT_PATH=/etc/ssl/certs/sgime.crt
SSL_KEY_PATH=/etc/ssl/private/sgime.key
```

#### 2. Certificados SSL

Para produção, substitua os certificados auto-assinados:

```bash
# Copiar certificados válidos
cp seu_certificado.crt config/nginx/ssl/sgime.crt
cp sua_chave_privada.key config/nginx/ssl/sgime.key

# Ajustar permissões
chmod 644 config/nginx/ssl/sgime.crt
chmod 600 config/nginx/ssl/sgime.key
```

#### 3. Inicialização

```bash
# Construir e iniciar containers
docker-compose up -d

# Verificar status
docker-compose ps

# Configurar dados iniciais
docker-compose exec redmine bundle exec rake redmine:setup RAILS_ENV=production
```

## Gestão de Usuários

### Integração com Active Directory

#### Configuração LDAP

1. Acesse **Administração → Autenticação LDAP**
2. Clique em **"Novo modo de autenticação"**
3. Configure:

```
Nome: Active Directory CP2
Host: ldap.cp2.g12.br
Porta: 389
LDAPS: Não (use 636 para LDAPS)
Conta: CN=sgime-service,OU=Service Accounts,DC=cp2,DC=g12,DC=br
Senha: [senha da conta de serviço]
DN base: DC=cp2,DC=g12,DC=br
Filtro LDAP: (objectClass=person)
Timeout: 5

Mapeamento de atributos:
- Login: samaccountname
- Nome: displayname
- Sobrenome: sn  
- Email: mail
```

#### Single Sign-On (SSO)

Para configurar SSO com Microsoft Entra ID:

1. Configure o plugin `redmine_omniauth_azure`
2. Em `config/.env`, defina:

```bash
AZURE_CLIENT_ID=seu_client_id
AZURE_CLIENT_SECRET=seu_client_secret  
AZURE_TENANT_ID=seu_tenant_id
```

3. Reinicie o sistema: `docker-compose restart redmine`

### Perfis e Permissões

#### Perfis Padrão do SGIME

| Perfil | Descrição | Permissões Principais |
|--------|-----------|----------------------|
| **Administrador** | Acesso completo | Todas as permissões |
| **Gerente de Manutenção** | Gestão completa de manutenção | Gerenciar ativos, OS, relatórios |
| **Técnico de Manutenção** | Execução de manutenção | Visualizar ativos, executar listas |
| **Prefeito de Campus** | Visão gerencial do campus | Visualizar relatórios do campus |
| **Gerente de Projeto** | Gestão de documentos | Gerenciar documentos, aprovar |
| **Consulta** | Apenas visualização | Apenas visualizar |

#### Criando Perfis Customizados

1. **Administração → Perfis e permissões**
2. **"Novo perfil"**
3. Configure permissões específicas:

```
Módulo SGIME Manutenção:
□ Visualizar ativos
□ Gerenciar ativos  
□ Visualizar manutenção
□ Gerenciar manutenção
□ Visualizar ordens de serviço
□ Gerenciar ordens de serviço
□ Gerar relatórios

Módulo SGIME Documentos:
□ Visualizar documentos
□ Gerenciar documentos
□ Aprovar documentos
□ Baixar pacotes
```

## Configuração de Projetos

### Estrutura Hierárquica

O SGIME usa a estrutura de projetos do Redmine para representar a hierarquia física:

```
Colégio Pedro II (Projeto Raiz)
├── Campus Centro (Subprojeto)
│   ├── Edifício Principal (Subprojeto)
│   │   ├── Bloco A (Subprojeto)
│   │   └── Bloco B (Subprojeto)
│   └── Edifício Anexo (Subprojeto)
└── Campus Humaitá II (Subprojeto)
    ├── Prédio Administrativo (Subprojeto)
    └── Pavilhão Esportivo (Subprojeto)
```

### Criando a Hierarquia

#### 1. Projeto Raiz
```
Nome: Colégio Pedro II
Identificador: cp2
Descrição: Projeto raiz do SGIME
Público: Não
Módulos habilitados:
☑ Problemas
☑ SGIME Manutenção  
☑ SGIME Documentos
☑ Calendário
☑ Documentos (DMSF)
☑ Dashboard
```

#### 2. Subprojetos (Campus)
```
Nome: Campus Centro
Identificador: campus-centro
Projeto pai: Colégio Pedro II
Herdar membros: Sim
```

### Configuração de Rastreadores

#### Rastreadores Essenciais do SGIME

1. **ATIVO**
   - Usado para cadastrar equipamentos e instalações
   - Campos obrigatórios: Código do Ativo, Localização, Disciplina

2. **LISTA DE VERIFICAÇÃO**
   - Para rotinas de manutenção preventiva
   - Integra com plugin Checklists
   - Gera OS automaticamente para não conformidades

3. **ORDEM DE SERVIÇO**
   - Para manutenção corretiva
   - Fluxo de trabalho completo
   - Controle de orçamento e cronograma

#### Configurando Rastreadores

1. **Administração → Rastreadores**
2. Para cada rastreador, configure:
   - **Campos personalizados** apropriados
   - **Fluxo de trabalho** específico
   - **Estados** permitidos

### Campos Personalizados

#### Campos Essenciais para Ativos

```sql
-- Código do Ativo (Texto, obrigatório)
Nome: codigo_ativo
Formato: Texto
Obrigatório: Sim
Para todos os projetos: Sim

-- Localização (Texto longo)
Nome: localizacao  
Formato: Texto longo
Obrigatório: Sim

-- Disciplina (Lista de valores)
Nome: disciplina
Formato: Lista
Valores possíveis:
- Elétrica
- Hidráulica  
- Ar Condicionado
- Civil
- Prevenção e Combate a Incêndio
- Elevadores
- Comunicação e Dados
```

#### Campos para Manutenção

```sql
-- Status de Conformidade
Nome: status_conformidade
Formato: Lista
Valores: Conforme|Não Conforme|N/A

-- Tipo de Manutenção
Nome: tipo_manutencao
Formato: Lista  
Valores: Preventiva|Preditiva|Corretiva|Emergencial

-- Fabricante
Nome: fabricante
Formato: Texto

-- Modelo
Nome: modelo
Formato: Texto
```

## Personalização do Sistema

### Temas e Interface

#### Aplicando Tema Personalizado

O SGIME inclui tema responsivo customizado:

```bash
# Tema já está instalado em public/themes/sgime_theme
# Para ativar:
# Administração → Configurações → Exibição → Tema: sgime_theme
```

#### Customizações CSS/JS

Edite os arquivos:
- `plugins/sgime_customizations/assets/stylesheets/sgime_custom.css`
- `plugins/sgime_customizations/assets/javascripts/sgime_custom.js`

### Plugin de Customizações

O plugin `sgime_customizations` implementa as três customizações principais:

#### 1. Geração de PDF de Vistoria
- **Localização**: `lib/pdf_report_generator.rb`
- **Função**: Gerar relatórios PDF formatados
- **Ativação**: Automática ao finalizar checklist

#### 2. Geração Automática de OS
- **Localização**: `lib/work_order_generator.rb`
- **Função**: Criar OS para não conformidades
- **Trigger**: Salvar lista de verificação com item "Não Conforme"

#### 3. Download de Pacotes de Documentos
- **Localização**: `lib/document_package_generator.rb`
- **Função**: Empacotar documentos para download
- **Interface**: Botão no DMSF

### Configurações Avançadas

#### Configuração de Email

Edite `config/redmine/additional_environment.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_HOST'],
  port: ENV['SMTP_PORT'],
  domain: ENV['SMTP_DOMAIN'],
  authentication: ENV['SMTP_AUTHENTICATION'],
  user_name: ENV['SMTP_USER'],
  password: ENV['SMTP_PASS'],
  enable_starttls_auto: true
}
```

#### Cache Redis

Para melhor performance:

```ruby
config.cache_store = :redis_cache_store, {
  url: "redis://redis:6379/0",
  expires_in: 1.hour
}
```

## Backup e Recuperação

### Backup Automático

O sistema executa backups automáticos:

```bash
# Verificar status do backup
docker-compose exec backup /scripts/healthcheck.sh

# Listar backups disponíveis
ls -la backups/

# Exemplo de arquivos:
# sgime_db_20250723_020000.sql.gz     - Backup do banco
# sgime_files_20250721_030000.tar.gz  - Backup dos arquivos
```

### Configuração de Backup

#### Cronograma (editável em `docker/backup/crontab`):

```cron
# Backup diário do banco às 02:00
0 2 * * * /scripts/backup_db.sh

# Backup semanal dos arquivos aos domingos às 03:00  
0 3 * * 0 /scripts/backup_files.sh
```

#### Retenção de Backups

Configure em `config/.env`:

```bash
BACKUP_RETENTION_DAYS=30  # Manter backups por 30 dias
```

### Restauração Manual

#### Restaurar Backup Completo

```bash
# Parar sistema
./scripts/manage.sh stop

# Restaurar
./scripts/manage.sh restore backups/sgime_backup_20250723_140000.tar.gz

# Verificar
./scripts/manage.sh status
```

#### Restaurar Apenas Banco

```bash
# Acessar container do PostgreSQL
docker-compose exec postgres bash

# Restaurar dump
pg_restore -U sgime_user -d sgime_production -c backup.sql
```

### Backup para Nuvem

Para backup em nuvem, configure script adicional:

```bash
#!/bin/bash
# Sync para AWS S3
aws s3 sync /backups s3://sgime-backups/$(date +%Y-%m)/

# Ou para Google Cloud
gsutil rsync -r /backups gs://sgime-backups/$(date +%Y-%m)/
```

## Monitoramento e Logs

### Logs do Sistema

#### Localização dos Logs

```bash
# Logs da aplicação
logs/redmine/production.log
logs/redmine/sgime_custom.log

# Logs do Nginx
logs/nginx/access.log
logs/nginx/error.log
logs/nginx/sgime_access.log
logs/nginx/sgime_error.log

# Logs de backup
logs/backup/backup_db.log
logs/backup/backup_files.log
```

#### Visualizando Logs em Tempo Real

```bash
# Todos os containers
docker-compose logs -f

# Container específico
docker-compose logs -f redmine

# Com filtro
docker-compose logs -f redmine | grep ERROR
```

### Monitoramento de Performance

#### Métricas Importantes

- **Tempo de resposta**: < 3 segundos para 95% das requisições
- **Uso de CPU**: < 70% em média
- **Uso de RAM**: < 80% da capacidade
- **Espaço em disco**: < 85% de ocupação
- **Conexões de banco**: < 80% do limite

#### Health Checks

Cada serviço possui health check configurado:

```bash
# Verificar saúde dos containers
docker-compose ps

# Health check manual
curl -f http://localhost/health
```

### Alertas e Notificações

#### Configurar Alertas por Email

Configure script de monitoramento:

```bash
#!/bin/bash
# monitor.sh - Alertas do SGIME

# Verificar se serviços estão rodando
if ! curl -f http://localhost/health >/dev/null 2>&1; then
    echo "ALERTA: SGIME não está respondendo" | \
    mail -s "SGIME - Sistema Indisponível" admin@cp2.g12.br
fi

# Verificar espaço em disco
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 85 ]; then
    echo "ALERTA: Espaço em disco: ${DISK_USAGE}%" | \
    mail -s "SGIME - Espaço em Disco Crítico" admin@cp2.g12.br
fi
```

Adicione ao cron:

```cron
# Verificar a cada 15 minutos
*/15 * * * * /scripts/monitor.sh
```

## Troubleshooting

### Problemas Comuns

#### 1. Sistema não inicia

**Sintomas**: Containers não sobem ou ficam reiniciando

**Diagnóstico**:
```bash
# Verificar logs
docker-compose logs

# Verificar recursos do sistema
free -h
df -h

# Verificar portas em uso
netstat -tlnp | grep -E ':(80|443|3000|5432)'
```

**Soluções**:
- Verificar se portas estão disponíveis
- Aumentar recursos (RAM/CPU)
- Verificar permissões de arquivos

#### 2. Erro de conexão com banco

**Sintomas**: "could not connect to server"

**Diagnóstico**:
```bash
# Verificar se PostgreSQL está rodando
docker-compose exec postgres pg_isready

# Testar conexão
docker-compose exec postgres psql -U sgime_user -d sgime_production -c '\l'
```

**Soluções**:
- Verificar variáveis de ambiente em `config/.env`
- Reiniciar container do banco: `docker-compose restart postgres`
- Verificar logs: `docker-compose logs postgres`

#### 3. Problemas de SSL

**Sintomas**: Certificado inválido ou conexão insegura

**Diagnóstico**:
```bash
# Verificar certificado
openssl x509 -in config/nginx/ssl/sgime.crt -text -noout

# Testar SSL
openssl s_client -connect localhost:443
```

**Soluções**:
- Substituir por certificado válido
- Verificar configuração do Nginx
- Desabilitar HTTPS temporariamente (desenvolvimento)

#### 4. Performance degradada

**Sintomas**: Sistema lento, timeouts

**Diagnóstico**:
```bash
# Verificar recursos
docker stats

# Verificar logs de erro
grep -i "error\|timeout" logs/redmine/production.log

# Conexões de banco
docker-compose exec postgres psql -U sgime_user -d sgime_production -c "SELECT count(*) FROM pg_stat_activity;"
```

**Soluções**:
- Aumentar recursos do container
- Otimizar consultas do banco
- Configurar cache Redis
- Implementar balanceamento de carga

### Comandos Úteis de Administração

#### Limpeza de Cache

```bash
# Limpar cache do Redmine
docker-compose exec redmine bundle exec rake tmp:cache:clear RAILS_ENV=production

# Limpar cache Redis
docker-compose exec redis redis-cli FLUSHALL
```

#### Reindexação do Banco

```bash
# Reindexar PostgreSQL
docker-compose exec postgres psql -U sgime_user -d sgime_production -c "REINDEX DATABASE sgime_production;"
```

#### Verificação de Integridade

```bash
# Verificar integridade dos plugins
docker-compose exec redmine bundle exec rake redmine:plugins:test RAILS_ENV=production

# Verificar dados do Redmine
docker-compose exec redmine bundle exec rake redmine:doctor RAILS_ENV=production
```

### Recuperação de Desastres

#### Cenário: Falha Total do Sistema

1. **Avaliação da Situação**
   ```bash
   # Verificar o que está funcionando
   docker-compose ps
   docker system df
   ```

2. **Recuperação dos Dados**
   ```bash
   # Restaurar backup mais recente
   ./scripts/manage.sh restore backups/sgime_backup_latest.tar.gz
   ```

3. **Verificação da Integridade**
   ```bash
   # Testar funcionalidades críticas
   curl -f https://localhost/
   ./scripts/manage.sh status
   ```

4. **Comunicação**
   - Informar stakeholders sobre o status
   - Documentar lições aprendidas
   - Implementar melhorias preventivas

---

**Suporte Técnico Avançado**  
Seção de Engenharia - Colégio Pedro II  
📧 admin-sgime@cp2.g12.br  
🌐 https://sgime.cp2.g12.br/admin  

**Versão do Guia**: 1.6  
**Última Atualização**: Julho 2025
