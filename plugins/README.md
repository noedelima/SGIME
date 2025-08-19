# Plugins SGIME - Sistema de Gestão Integrada de Engenharia

## Visão Geral

Este diretório contém todos os plugins essenciais do SGIME, cada um com funcionalidades específicas para atender às necessidades do Colégio Pedro II na gestão de engenharia e manutenção.

## Plugins Instalados (6/6 ✅)

### 1. 🎨 sgime_customizations
**Tema e Identidade Visual do Colégio Pedro II**
- **Descrição**: Plugin customizado com a identidade visual oficial do CPII
- **Funcionalidades**:
  - Tema personalizado com cores institucionais
  - Favicon oficial do Colégio Pedro II
  - Logo integrado no header
  - CSS responsivo e acessível
- **Status**: ✅ Ativo e funcional

### 2. 📊 redmine_dashboard
**Dashboard Personalizado**
- **Repositório**: https://github.com/jgraichen/redmine_dashboard.git
- **Descrição**: Dashboard configurável para visão geral do sistema
- **Funcionalidades**:
  - Widgets personalizáveis
  - Métricas em tempo real
  - Filtros por projeto e usuário
  - Interface intuitiva
- **Status**: ✅ Ativo e funcional

### 3. ✅ redmine_checklists
**Sistema de Checklists Oficial**
- **Versão**: RedmineUP Light
- **Descrição**: Sistema oficial de checklists integrado
- **Funcionalidades**:
  - Templates de checklist customizáveis
  - Integração com issues
  - Relatórios automáticos
  - Controle de não conformidades
- **Status**: ✅ Ativo e funcional

### 4. 📁 redmine_dmsf
**Sistema de Gestão de Documentos**
- **Descrição**: Gestão completa de documentos técnicos
- **Funcionalidades**:
  - Upload e organização de arquivos
  - Controle de versões
  - Fluxo de aprovação
  - Repositório seguro
- **Status**: ✅ Ativo e funcional (corrigido para Rails 7)

### 5. 🔄 redmine_recurring_tasks_sgime
**Tarefas Recorrentes e Auto-geração de OS**
- **Versão**: Fork customizado SGIME
- **Descrição**: Sistema de tarefas recorrentes com auto-geração de OS
- **Funcionalidades**:
  - Cronograma automático de manutenções
  - Auto-geração de ordens de serviço
  - Templates de tarefas predefinidas
  - Integração com checklists
- **Status**: ✅ Ativo e funcional

### 6. 👁️ redmine_more_previews
**Visualizações Avançadas de Arquivos**
- **Repositório**: https://github.com/HugoHasenbein/redmine_more_previews.git
- **Descrição**: Preview avançado para múltiplos formatos
- **Funcionalidades**:
  - 10 converters ativos
  - Suporte a PDF, imagens, Office
  - Preview inline de documentos
  - Otimização de performance
- **Status**: ✅ Ativo e funcional

## Estrutura de Diretórios

```
plugins/
├── sgime_customizations/          # Tema CPII
│   ├── assets/
│   │   ├── images/               # Imagens e favicon
│   │   ├── stylesheets/          # CSS customizado
│   │   └── javascripts/          # Scripts personalizados
│   └── config/
├── redmine_dashboard/            # Dashboard
├── redmine_checklists/           # Sistema de checklists
├── redmine_dmsf/                # Gestão de documentos
├── redmine_recurring_tasks_sgime/ # Tarefas recorrentes
└── redmine_more_previews/        # Preview de arquivos
```

## Scripts de Gerenciamento

### Setup Automático
```bash
# Configurar todos os plugins
./scripts/setup-plugins.sh

# Configurar apenas plugins essenciais
./scripts/setup-plugins.sh essential-only

# Verificar status
./scripts/setup-plugins.sh status
```

### Gerenciamento Dinâmico
```bash
# Listar plugins e status
./scripts/plugin-manager.sh list

# Habilitar plugin específico
./scripts/plugin-manager.sh enable <plugin_name>

# Desabilitar plugin específico
./scripts/plugin-manager.sh disable <plugin_name>

# Status do sistema
./scripts/plugin-manager.sh status
```

## Configuração no Docker Compose

Todos os plugins são montados como volumes no container Redmine:

```yaml
volumes:
  - ./plugins/sgime_customizations:/usr/src/redmine/plugins/sgime_customizations
  - ./plugins/redmine_dashboard:/usr/src/redmine/plugins/redmine_dashboard
  - ./plugins/redmine_checklists:/usr/src/redmine/plugins/redmine_checklists
  - ./plugins/redmine_dmsf:/usr/src/redmine/plugins/redmine_dmsf
  - ./plugins/redmine_recurring_tasks_sgime:/usr/src/redmine/plugins/recurring_tasks
  - ./plugins/redmine_more_previews:/usr/src/redmine/plugins/redmine_more_previews
```

## Compatibilidade

- **Redmine**: 6.0.x
- **Rails**: 7.2.x
- **Ruby**: 3.1+
- **PostgreSQL**: 16.x

## Administração

### Acesso aos Plugins
No menu **Administração**, você encontrará:
- **Plugins**: Lista todos os plugins instalados
- **Configurações**: Configurações específicas de cada plugin
- **Permissões**: Controle de acesso granular

### Configurações Essenciais

1. **Dashboard**: Configure widgets e métricas
2. **Checklists**: Defina templates para diferentes equipamentos
3. **DMSF**: Configure estrutura de pastas e permissões
4. **Recurring Tasks**: Defina cronogramas de manutenção
5. **More Previews**: Configure converters ativos

## Troubleshooting

### Problemas Comuns

#### Plugin não aparece na lista
```bash
# Verificar se está montado corretamente
docker compose exec redmine ls -la /usr/src/redmine/plugins/

# Reiniciar container
docker compose restart redmine
```

#### Erro de migração
```bash
# Executar migrações manualmente
docker compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

#### Plugin desabilitado
```bash
# Habilitar via script
./scripts/plugin-manager.sh enable <plugin_name>
```

## Desenvolvimento

### Adicionando Novos Plugins

1. **Baixar plugin**:
```bash
cd plugins/
git clone <repository_url> <plugin_name>
```

2. **Configurar no docker-compose.yml**:
```yaml
- ./plugins/<plugin_name>:/usr/src/redmine/plugins/<plugin_name>
```

3. **Habilitar**:
```bash
./scripts/plugin-manager.sh enable <plugin_name>
```

### Customizações

Para customizar plugins existentes, edite os arquivos nas respectivas pastas mantendo a estrutura original do plugin.

## Backup e Restore

### Backup de Plugins
```bash
# Backup completo incluindo plugins
./scripts/manage.sh backup

# Backup apenas de configurações de plugins
tar -czf plugins_backup.tar.gz plugins/
```

### Restore
```bash
# Restaurar de backup completo
./scripts/manage.sh restore <backup_file>

# Restaurar apenas plugins
tar -xzf plugins_backup.tar.gz
```

## Licenças

- **sgime_customizations**: GPL v3 (customizado para CPII)
- **redmine_dashboard**: MIT License
- **redmine_checklists**: Comercial (RedmineUP Light)
- **redmine_dmsf**: GPL v2
- **redmine_recurring_tasks_sgime**: GPL v3 (fork customizado)
- **redmine_more_previews**: GPL v2

---

**Nota**: Todos os plugins foram testados e são compatíveis com a versão atual do SGIME. Para suporte técnico, consulte a documentação específica de cada plugin ou entre em contato com a equipe SGIME.