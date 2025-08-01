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

### 2. Redmine Issue Templates  
- **Repositório**: https://github.com/akiko-pusu/redmine_issue_templates.git
- **Página oficial**: https://www.redmine.org/plugins/redmine_issue_templates
- **Descrição**: Templates predefinidos para criação de issues
- **Status**: ✅ Funcionando

### 3. Simple Checklists
- **Repositório**: Plugin customizado SGIME
- **Descrição**: Funcionalidade de checklists simples para issues
- **Status**: ✅ Funcionando

### 4. Redmine Recurring Tasks
- **Repositório**: https://github.com/nutso/redmine-plugin-recurring-tasks.git
- **Descrição**: Tarefas recorrentes/repetitivas
- **Status**: ⚠️ Em teste (compatibilidade Redmine 6.0)

## Plugins Opcionais Disponíveis

### 1. Redmine DMSF
- **Repositório**: https://github.com/danmunn/redmine_dmsf.git
- **Página oficial**: https://www.redmine.org/plugins/dmsf
- **Descrição**: Sistema de gestão de documentos
- **Status**: 🔄 Disponível (não habilitado)

### 2. Redmine More Previews
- **Página oficial**: https://www.redmine.org/plugins/redmine_more_previews
- **Descrição**: Preview avançado de arquivos (imagens, vídeos, PDFs)
- **Status**: 🔄 Para implementar

### 3. Redmine Custom CSS
- **Descrição**: Personalização de CSS por projeto
- **Status**: 🔄 Para implementar

### 4. Redmine OmniAuth Azure
- **Descrição**: Integração SSO com Microsoft Azure AD
- **Status**: 🔄 Para implementar

## Como Buscar Novos Plugins

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
