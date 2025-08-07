# Plugin Recurring Tasks - Correções para Redmine 6.0

## Problemas Identificados

1. **Arquivo rake com require environment**: O arquivo `lib/tasks/recurring_tasks.rake` estava carregando o environment antes do namespace
2. **require_dependency obsoleto**: Uso de `require_dependency` que foi depreciado no Rails 7
3. **Carregamento de patches**: Necessário usar `require_relative` ao invés de `require_dependency`

## Correções Aplicadas

### 1. lib/tasks/recurring_tasks.rake
- Removido: `require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")`
- Mantido: Task `:recur_tasks => :environment` funciona corretamente

### 2. init.rb
- Removido: `require 'issues_patch'` e `require_dependency 'recurring_tasks/hooks'`
- Adicionado: Carregamento via `Rails.configuration.to_prepare`
- Usado: `require_relative` para carregar os arquivos necessários

### 3. Estrutura Moderna Rails 7
- Patches carregados dentro do bloco `to_prepare`
- Compatibilidade mantida com versões anteriores

## Status
✅ Plugin corrigido e funcional para Redmine 6.0 + Rails 7
