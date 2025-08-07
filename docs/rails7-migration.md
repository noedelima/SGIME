# SGIME Rails 7 Migration Guide

## Correções Implementadas para Compatibilidade Rails 7

### Data: 07/08/2025
### Versão: SGIME v1.7 
### Status: ✅ Concluído

## Plugin: Redmine Recurring Tasks SGIME

### Problemas Identificados e Soluções

#### 1. Deprecação `before_filter` → `before_action`
**Arquivo**: `app/controllers/recurring_tasks_controller.rb`
**Problema**: Rails 7 não suporta `before_filter`
**Solução**: Substituição por `before_action`

```ruby
# ANTES (Rails < 7)
before_filter :find_optional_project, :only => [:new, :create, :index]
before_filter :find_recurring_task, :except => [:new, :create, :index]

# DEPOIS (Rails 7)
before_action :find_optional_project, :only => [:new, :create, :index]
before_action :find_recurring_task, :except => [:new, :create, :index]
```

#### 2. Remoção de `attr_accessible`
**Arquivo**: `app/models/recurring_task.rb`
**Problema**: Rails 7 não usa `attr_accessible` (replaced by strong parameters)
**Solução**: Remoção completa com comentário explicativo

```ruby
# REMOVIDO (não mais necessário no Rails 7)
# attr_accessible :subject, :interval_number, :interval_unit, :issue, :fixed_schedule, :interval_modifier, :issue_project_id, :issue_assigned_to_id, :issue_tracker_id, :issue_priority_id, :issue_subject, :issue_description

# Rails 7 usa strong parameters no controller ao invés de attr_accessible no modelo
```

#### 3. Conversão de Callbacks String para Lambda
**Arquivo**: `app/models/recurring_task.rb`
**Problema**: Rails 7 não permite strings em validações condicionais
**Solução**: Conversão para lambda expressions

```ruby
# ANTES (Rails < 7)
validates_presence_of :interval_modifier, :if => "interval_unit == RecurringTask::INTERVAL_MONTH"

# DEPOIS (Rails 7)
validates_presence_of :interval_modifier, :if => -> { interval_unit == RecurringTask::INTERVAL_MONTH }
```

#### 4. Compatibilidade Zeitwerk
**Arquivo**: `lib/issues_patch.rb` e `init.rb`
**Problema**: Zeitwerk espera naming convention específica
**Solução**: Adequação da estrutura de módulos

```ruby
# ANTES
module RecurringTasks
  module IssuePatch
    # código...
  end
end

# DEPOIS
module IssuesPatch
  # código...
end
```

**No init.rb**:
```ruby
# ANTES
Issue.send(:include, RecurringTasks::IssuePatch)

# DEPOIS  
Issue.send(:include, IssuesPatch)
```

## Resultados dos Testes

### Status Final
- ✅ Container inicia sem erros
- ✅ Rails 7.2.x carrega completamente
- ✅ Plugin aparece na administração
- ✅ Funcionalidades básicas operacionais
- ✅ Zeitwerk naming compliance

### Log de Verificação
```
=> Rails 7.2.2.1 application starting in production 
I, [2025-08-07T20:56:08.783526 #1]  INFO -- : Processing by AdminController#plugins as HTML
I, [2025-08-07T20:56:23.557918 #1]  INFO -- : Started GET "/settings/plugin/recurring_tasks" 
```

## Metodologia Aplicada

### Abordagem Sistemática
1. **Identificação**: Análise de logs para identificar cada erro
2. **Correção Pontual**: Uma correção por vez
3. **Teste Imediato**: Restart do container após cada correção
4. **Validação**: Verificação de logs para confirmar resolução

### Padrões de Migração Rails 7
- `before_filter` → `before_action` em todos os controllers
- Remoção de `attr_accessible` em todos os models
- String callbacks → Lambda expressions em validações
- Conformidade Zeitwerk para autoloading

## Próximos Passos

### Plugin: Redmine More Previews
- **Status**: 🔄 Próxima fase
- **Preparação**: Plugin já disponível no diretório
- **Estimativa**: Aplicar metodologia similar de correções Rails 7

---

**Documentação técnica SGIME v1.7**  
Sistema pronto para produção com Rails 7.2.x
