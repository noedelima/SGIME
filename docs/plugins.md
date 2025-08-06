# Plugins do SGIME

## Referências Oficiais

- **Página oficial de plugins Redmine**: https://www.redmine.org/plugins
- **Guia de desenvolvimento de plugins**: https://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial
- **API de plugins**: https://www.redmine.org/projects/redmine/wiki/Plugin_Internals

## Plugins Essenciais Implementados

### 1. Redmine Dashboard
- **Repositório**: https://github.com/jgraichen/redmine_dashboard.git
- **Página oficial**: https://www.redmine.org/plugins/dashboard
- **Descrição**: Dashboard personalizável para visão geral do projeto
- **Status**: ✅ Funcionando

### 2. SGIME Customizations
- **Repositório**: Plugin customizado local
- **Descrição**: Tema e identidade visual do Colégio Pedro II
- **Status**: ✅ Funcionando

### 3. Redmine Checklists
- **Repositório**: RedmineUP Light version (download manual)
- **Página oficial**: https://www.redmine.org/plugins/checklists
- **Descrição**: Sistema de checklists oficial para issues
- **Status**: ✅ Funcionando

### 4. Redmine DMSF
- **Repositório**: https://github.com/picman/redmine_dmsf.git (fork atualizado)
- **Página oficial**: https://www.redmine.org/plugins/dmsf
- **Descrição**: Sistema completo de gestão de documentos com workflows
- **Status**: ✅ Funcionando (com correções aplicadas)

### 5. Redmine Recurring Tasks
- **Repositório**: https://github.com/nutso/redmine-plugin-recurring-tasks.git
- **Página oficial**: https://www.redmine.org/plugins/redmine_recurring_tasks
- **Descrição**: Criação automática de tarefas recorrentes para manutenção
- **Status**: ✅ Funcionando

## Plugins Opcionais (Removidos da Instalação Atual)

> **📝 Nota**: Os plugins abaixo foram removidos para simplificar a instalação e manter apenas os recursos essenciais do SGIME.

### Plugins Disponíveis para Implementação Futura

1. **Redmine More Previews** - Preview avançado de arquivos
2. **Redmine Issue Templates** - Templates predefinidos para issues  
3. **Redmine OmniAuth Azure** - Integração SSO com Microsoft Azure AD

### Plugins de Backup Removidos

- **Simple Checklists** - Sistema básico de checklists (substituído por redmine_checklists oficial)## Como Buscar Novos Plugins

1. Acesse https://www.redmine.org/plugins
2. Use os filtros para encontrar plugins por categoria:
   - **Time tracking**: Controle de tempo
   - **Issue tracking**: Gestão de issues
   - **SCM**: Integração com repositórios
   - **Project management**: Gestão de projetos
   - **Workflow**: Personalização de workflows

3. Verifique a compatibilidade com Redmine 6.0
4. Teste em ambiente de desenvolvimento antes de implementar

## Scripts de Gerenciamento

- `./scripts/setup-plugins.sh` - Setup inicial dos plugins
- `./scripts/plugin-manager.sh` - Gerenciamento dinâmico
- `./scripts/plugin-manager.sh list` - Lista status dos plugins
- `./scripts/plugin-manager.sh enable <plugin>` - Habilita plugin
- `./scripts/plugin-manager.sh disable <plugin>` - Desabilita plugin

## Notas de Desenvolvimento

- Todos os plugins devem ter compatibilidade com Redmine 6.0+
- Testar sempre em ambiente de desenvolvimento antes de produção
- Manter documentação atualizada quando adicionar novos plugins
- Fazer backup antes de instalar/atualizar plugins

## Troubleshooting

### Plugin não aparece na administração
1. Verificar se o diretório está montado corretamente no Docker
2. Verificar se existe arquivo `init.rb` no plugin
3. Executar migrações: `docker compose exec redmine bundle exec rake redmine:plugins:migrate`
4. Reiniciar container: `docker compose restart redmine`

### Erro de SECRET_KEY_BASE
Execute comandos rake com a variável definida:
```bash
docker compose exec redmine bash -c "cd /usr/src/redmine && SECRET_KEY_BASE=\$REDMINE_SECRET_KEY_BASE bundle exec rake redmine:plugins:migrate RAILS_ENV=production"
```
