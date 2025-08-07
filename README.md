# SGIME - Sistema de Gestão Integrada de Engenharia

## 🚀 Versão 1.7 (Rails 7 Ready) - Estável

**Sistema de Gestão Integrada de Engenharia para Colégio Pedro II**

### 🎯 Destaques da v1.7
- **🔧 Compatibilidade Completa com Rails 7**: Todos os plugins atualizados e funcionais
- **🧹 Código Limpo**: Remoção de arquivos desnecessários e versões de backup
- **📦 5 Plugins Essenciais**: Conjunto mínimo e funcional para operação
- **🔐 Sistema Estável**: Pronto para produção com Redmine 6.0 + Rails 7.2

### 📊 Status dos Plugins
- ✅ **Redmine Dashboard** - Dashboard personalizado (funcional)
- ✅ **SGIME Customizations** - Tema Colégio Pedro II (funcional)  
- ✅ **Redmine Checklists** - Sistema de checklists (funcional)
- ✅ **Redmine DMSF** - Gestão de documentos (funcional)
- ✅ **Redmine Recurring Tasks** - Tarefas recorrentes (funcional)
- 🔄 **Redmine More Previews** - Visualizações avançadas (próxima fase)

## Descrição Geral

O SGIME (Sistema de Gestão Integrada de Engenharia) é uma solução completa desenvolvida sobre a plataforma Redmine para o Colégio Pedro II. O sistema centraliza e automatiza os processos de:

- **Gestão de Ativos e Manutenção**: Controle completo de ativos imobiliários e equipamentos eletromecânicos
- **Gestão de Documentos de Projetos**: Repositório centralizado para documentos de engenharia e arquitetura

## Módulos do Sistema

### 1. Módulo de Gestão de Ativos
- Cadastro hierárquico de locais (complexos, campi, edifícios, blocos)
- Controle de ativos por disciplina técnica
- Gestão de manutenção preditiva, preventiva e corretiva

### 2. Módulo de Planejamento e Controle da Manutenção
- Checklists automatizados com geração de relatórios PDF
- Rotinas de manutenção recorrentes
- Controle de não conformidades

### 3. Módulo de Gestão de Ordens de Serviço
- Fluxo completo de OS com detalhamento técnico
- Geração automática a partir de itens não conformes
- Controle de orçamentos e cronogramas

### 4. Módulo de Relatórios e Indicadores
- Dashboards customizáveis
- Filtros por hierarquia e disciplina
- Indicadores de desempenho

### 5. Módulo de Gestão de Documentos (GED)
- Repositório seguro para documentos de projeto
- Controle de versões e revisões
- Fluxo de aprovação de documentos

### 6. Módulo de Administração
- Gerenciamento de disciplinas técnicas
- Controle de permissões e hierarquias
- Configurações globais do sistema

## Licenças de Software

- **SGIME**: GNU General Public License v3.0 (GPLv3)
- **Redmine**: GNU General Public License v2.0
- **PostgreSQL**: PostgreSQL License (compatível com MIT)
- **Ruby**: Ruby License e BSD-2-Clause
- **Nginx**: BSD-2-Clause License

## 🎨 Tema e Identidade Visual

O SGIME implementa a **identidade visual oficial do Colégio Pedro II** através de um tema personalizado que inclui:

- **🏛️ Favicon Oficial**: Baseado no brasão do CPII com cores institucionais
- **🎨 Logo no Header**: Brasão integrado com texto "SGIME - Colégio Pedro II"
- **🌈 Paleta Institucional**: Azul institucional (#003366) e dourado oficial (#DAA520)
- **📱 Interface Responsiva**: Adaptação para dispositivos móveis
- **♿ Alto Contraste**: Menu com visibilidade máxima e acessibilidade

### Estrutura do Tema
```
plugins/sgime_customizations/
├── assets/stylesheets/
│   ├── sgime_custom.css         # CSS principal
│   ├── cpii_brasao.css          # Elementos do brasão
│   ├── sgime_menu_fix.css       # Correções de visibilidade
│   └── sgime_contrast_max.css   # Contraste máximo
└── assets/images/
    ├── cpii-favicon.svg         # Favicon oficial
    └── favicon.ico              # Fallback
```

Para mais detalhes, consulte: `plugins/sgime_customizations/README.md`

## Arquitetura Técnica

- **Plataforma Base**: Redmine 6.0.x + Rails 7.2.x
- **Banco de Dados**: PostgreSQL 16.x 
- **Servidor Web**: Nginx (proxy reverso) + Puma (Ruby)
- **Cache**: Redis para sessões e cache
- **Containerização**: Docker + Docker Compose
- **Autenticação**: LDAP/AD + SSO (Microsoft Entra ID)
- **Compatibilidade**: Totalmente compatível com Rails 7

## Plugins Implementados

### Plugins Essenciais (Habilitados)
- ✅ **Redmine Dashboard** - Dashboard personalizado
- ✅ **SGIME Customizations** - Tema e identidade visual do Colégio Pedro II
- ✅ **Redmine Checklists** - Sistema de checklists (RedmineUP Light)
- ✅ **Redmine DMSF** - Sistema completo de gestão de documentos
- ✅ **Redmine Recurring Tasks** - Tarefas recorrentes para manutenção

### Plugins Removidos (Para Instalação Simplificada)
> **� Nota**: Os plugins abaixo foram removidos para manter apenas os recursos essenciais.

- **Redmine Issue Templates** - Templates predefinidos para issues (opcional)
- **Redmine More Previews** - Preview avançado de arquivos (opcional)
- **Simple Checklists** - Sistema básico de checklists (substituído pelo oficial)

Para mais informações sobre plugins, consulte: [docs/plugins.md](docs/plugins.md)

## Pré-requisitos

### Sistema Operacional
- Ubuntu Server 22.04 LTS ou superior
- Fedora Server 38 ou superior

### Software Base
- Docker 24.x ou superior
- Docker Compose 2.x ou superior
- Git 2.x ou superior

### Recursos Mínimos
- **Desenvolvimento**: 4GB RAM, 2 CPU cores, 20GB disco
- **Produção**: 16GB RAM, 8 CPU cores, 200GB disco SSD

## Instalação

### Instalação Rápida (Desenvolvimento)

```bash
# Clone o repositório
git clone https://github.com/noedelima/SGIME.git
cd SGIME

# Execute a instalação automatizada
./setup.sh
```

### Instalação Passo a Passo

1. **Preparação do Ambiente**
```bash
# Atualize o sistema
sudo apt update && sudo apt upgrade -y

# Instale dependências
sudo apt install -y docker.io docker-compose git curl wget
```

2. **Clone e Configuração**
```bash
# Clone o projeto
git clone https://github.com/noedelima/SGIME.git
cd SGIME

# Copie e configure as variáveis de ambiente
cp config/env.example config/.env
nano config/.env
```

3. **Inicialização dos Serviços**
```bash
# Construa e inicie os contêineres
docker-compose up -d

# Execute a configuração inicial
docker-compose exec redmine bundle exec rake redmine:setup
```

## Configuração Inicial

### Primeiro Acesso

1. Acesse o sistema em: `http://localhost:3000`
2. Usuário padrão: `admin`
3. Senha padrão: `admin123`
4. **IMPORTANTE**: Altere a senha imediatamente após o primeiro login

### Configuração de Plugins

Os plugins serão instalados automaticamente. Para configuração manual:

```bash
# Entre no contêiner do Redmine
docker-compose exec redmine bash

# Execute as migrações dos plugins
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

### Configuração de Autenticação LDAP/SSO

1. Acesse **Administração → Autenticação LDAP**
2. Configure os parâmetros do Active Directory
3. Para SSO, configure o plugin OmniAuth Azure conforme documentação

## Operação do Sistema

### Comandos de Gerenciamento

```bash
# Iniciar todos os serviços
./scripts/manage.sh start

# Parar todos os serviços
./scripts/manage.sh stop

# Reiniciar todos os serviços
./scripts/manage.sh restart

# Verificar status dos serviços
./scripts/manage.sh status

# Visualizar logs em tempo real
./scripts/manage.sh logs

# Backup completo do sistema
./scripts/manage.sh backup
```

### Monitoramento

- **Logs da aplicação**: `docker-compose logs redmine`
- **Logs do banco**: `docker-compose logs postgres`
- **Logs do proxy**: `docker-compose logs nginx`
- **Saúde dos serviços**: `docker-compose ps`

## Backup e Recuperação

### Backup Automático

O sistema executa backups automáticos conforme cronograma:
- **Banco de dados**: Diário às 02:00
- **Arquivos**: Semanal aos domingos às 03:00
- **Retenção**: 30 dias

### Backup Manual

```bash
# Backup completo
./scripts/manage.sh backup

# Backup apenas do banco
./scripts/manage.sh backup-db

# Backup apenas dos arquivos
./scripts/manage.sh backup-files
```

### Restauração

```bash
# Restaurar backup completo
./scripts/manage.sh restore /caminho/para/backup.tar.gz

# Restaurar apenas o banco
./scripts/manage.sh restore-db /caminho/para/backup_db.sql
```

### RTO (Recovery Time Objective)

- **Tempo máximo de recuperação**: 4 horas
- **Ponto de recuperação**: Máximo 24 horas (backup diário)

## Remoção Completa

Para remover completamente o sistema:

```bash
# Execute o script de desinstalação
chmod +x scripts/uninstall.sh
./scripts/uninstall.sh
```

**ATENÇÃO**: Este comando remove TODOS os dados permanentemente. Faça backup antes de executar.

## Suporte e Documentação

### Documentação Técnica
- [Manual do Usuário](docs/manual-usuario.md)
- [Guia do Administrador](docs/guia-administrador.md)
- [API e Integrações](docs/api-integracoes.md)
- [Troubleshooting](docs/troubleshooting.md)

### Contato e Suporte
- **Órgão**: Colégio Pedro II
- **Setor**: Seção de Engenharia
- **E-mail**: geeng@cp2.g12.br
- **Documentação Online**: https://sgime.cp2.g12.br/docs

## Contribuição

Este projeto segue as diretrizes de contribuição do Colégio Pedro II. Para contribuir:

1. Faça fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a GNU General Public License v3.0 - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

**SGIME v1.6** - Sistema de Gestão Integrada de Engenharia  
**Colégio Pedro II** - Seção de Engenharia  
**Data**: Julho de 2025
