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
├── redmine_dashboard/            # Baixado automaticamente durante setup
├── redmine_checklists/          # Download manual: RedmineUP Light version
├── redmine_dmsf/                # Baixado automaticamente com correções
├── redmine_recurring_tasks/     # Baixado automaticamente durante setup
├── simple_checklists/           # Backup: sistema básico de checklists
├── redmine_issue_templates/     # Opcional: templates de issues
└── redmine_more_previews/       # Opcional: preview avançado de arquivos
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
- ✅ **redmine_dmsf** - Sistema completo de gestão de documentos
- ✅ **redmine_recurring_tasks** - Tarefas recorrentes para manutenção

## 📦 Plugins Removidos da Instalação

> **📝 Nota**: Para manter a instalação simplificada, os seguintes plugins foram removidos. Podem ser reativados conforme necessidade futura.

- **simple_checklists** - Sistema de checklists básico (substituído pelo oficial)
- **redmine_issue_templates** - Templates de issues (funcionalidade opcional)
- **redmine_more_previews** - Preview avançado de arquivos (funcionalidade opcional)

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
| redmine_dmsf | [picman/redmine_dmsf](https://github.com/picman/redmine_dmsf) | ✅ Ativo | Gestão de documentos |
| redmine_recurring_tasks | [nutso/redmine-plugin-recurring-tasks](https://github.com/nutso/redmine-plugin-recurring-tasks) | ✅ Ativo | Tarefas recorrentes |

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
