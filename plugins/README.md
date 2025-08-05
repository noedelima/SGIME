# SGIME Plugins Directory

Este diretório contém os plugins do Redmine para o sistema SGIME.

## � Sistema Automatizado

**IMPORTANTE**: Os plugins são baixados automaticamente dos repositórios oficiais durante a instalação. Não são armazenados no repositório do SGIME para evitar duplicação de código.

## �📁 Estrutura

```
plugins/
├── .gitignore                    # Ignora plugins baixados automaticamente
├── README.md                     # Este arquivo
├── sgime_customizations/         # Plugin customizado do SGIME (commitado)
├── redmine_dashboard/            # Baixado de: github.com/jgraichen/redmine_dashboard
├── redmine_recurring_tasks/      # Baixado de: github.com/nutso/redmine-plugin-recurring-tasks (INCOMPATÍVEL)
├── simple_checklists/           # Baixado de: github.com/ggilder/redmine_simple_checklists (BACKUP)
├── redmine_checklists/          # Download manual: RedmineUP Light version (ATIVO)
├── redmine_issue_templates/     # Baixado de: github.com/akiko-pusu/redmine_issue_templates
└── redmine_dmsf/                # Baixado de: github.com/danmunn/redmine_dmsf (opcional)
```

## 🚀 Instalação Automática

Durante o `./setup.sh`, os plugins essenciais são automaticamente:

1. **Baixados** dos repositórios oficiais
2. **Configurados** no docker-compose.yml
3. **Habilitados** no sistema
4. **Tabelas criadas** automaticamente

### Plugins Essenciais (Habilitados por Padrão)

- ✅ **redmine_dashboard** - Dashboard personalizado
- ✅ **sgime_customizations** - Tema e customizações CPII
- ✅ **redmine_checklists** - Sistema de checklists oficial (RedmineUP Light)

### Plugins Instalados mas Desabilitados

- ⚠️ **simple_checklists** - Sistema de checklists básico (backup)
- ⚠️ **redmine_recurring_tasks** - Tarefas recorrentes (incompatível Redmine 6.0)
- ⚠️ **redmine_issue_templates** - Templates de issues

### Plugins Opcionais (Baixados mas Desabilitados)

- ⚠️ **redmine_dmsf** - Gestão de documentos (problemas de compatibilidade)
- 📋 **redmine_checklists** - Checklists oficiais (repositório instável)
- 🏃 **redmine_agile** - Metodologias ágeis (comercial)

## 🔧 Gerenciamento Manual

### Configurar Plugin Específico

```bash
# Apenas plugins essenciais
./scripts/setup-plugins.sh essential-only

# Apenas download (sem habilitar)
./scripts/setup-plugins.sh download-only

# Status dos plugins
./scripts/setup-plugins.sh status
```

### Habilitar/Desabilitar Plugins

```bash
# Habilitar plugin opcional
./scripts/plugin-manager.sh enable redmine_dmsf

# Desabilitar plugin
./scripts/plugin-manager.sh disable redmine_dmsf

# Listar status
./scripts/plugin-manager.sh list
```

### Adicionar Plugin Personalizado

1. **Download manual**:
   ```bash
   cd plugins
   git clone [URL_DO_PLUGIN] [nome_do_plugin]
   ```

2. **Habilitar**:
   ```bash
   ./scripts/plugin-manager.sh enable [nome_do_plugin]
   ```

## 📋 Repositórios dos Plugins

| Plugin | Repositório | Status | Função |
|--------|-------------|--------|---------|
| redmine_dashboard | [jgraichen/redmine_dashboard](https://github.com/jgraichen/redmine_dashboard) | ✅ Ativo | Dashboard personalizado |
| redmine_checklists | Download manual RedmineUP | ✅ Ativo | Checklists oficial (Light) |
| sgime_customizations | Local/customizado | ✅ Ativo | Tema Colégio Pedro II |
| simple_checklists | [ggilder/redmine_simple_checklists](https://github.com/ggilder/redmine_simple_checklists) | 💾 Backup | Checklists básico (backup) |
| redmine_recurring_tasks | [nutso/redmine-plugin-recurring-tasks](https://github.com/nutso/redmine-plugin-recurring-tasks) | ❌ Incompatível | Tarefas recorrentes |
| redmine_issue_templates | [akiko-pusu/redmine_issue_templates](https://github.com/akiko-pusu/redmine_issue_templates) | ⚠️ Pendente | Templates de issues |
| redmine_dmsf | [danmunn/redmine_dmsf](https://github.com/danmunn/redmine_dmsf) | ⚠️ Opcional | Gestão de documentos |

## 🔍 Troubleshooting

### Plugin não carrega

1. Verificar se está habilitado:
   ```bash
   ./scripts/plugin-manager.sh list
   ```

2. Verificar logs:
   ```bash
   docker-compose logs redmine
   ```

3. Reiniciar sistema:
   ```bash
   docker-compose restart redmine
   ```

### Erro de migração

```bash
# Executar manualmente
docker exec -it sgime-redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

### Plugin com dependências nativas

Alguns plugins (como DMSF) podem ter problemas com gems nativas. Para resolver:

1. Desabilite temporariamente o plugin
2. Verifique compatibilidade com Redmine 6.0
3. Use alternativas quando disponíveis
- [ ] redmine_spent_time
- [ ] redmine_contacts

## 🚨 Importante

- Sempre teste um plugin por vez
- Faça backup antes de adicionar novos plugins
- Verifique compatibilidade com Redmine 5.1
