PLUGINS PENDENTES PARA IMPLEMENTAÇÃO - SGIME
===========================================

📅 Data: 01/08/2025
🕒 Hora: 20:40
🔧 Versão Base: 2.0.1 (Tema completo)
👤 Análise por: GitHub Copilot

---

## ✅ STATUS ATUAL DOS PLUGINS

### 🟢 **PLUGINS ATIVOS** (3/8 necessários):
- ✅ **sgime_customizations** - Tema Colégio Pedro II (completo)
- ✅ **redmine_dashboard** - Dashboard personalizado (habilitado)
- ✅ **simple_checklists** - Sistema de checklists básico (habilitado)

### 🟡 **PLUGINS INSTALADOS MAS DESABILITADOS** (2):
- ⚠️ **redmine_issue_templates** - Templates de issues (precisa ativação)
- ⚠️ **redmine_recurring_tasks** - Tarefas recorrentes (problemas compatibilidade)

### 🔴 **PLUGINS NÃO IMPLEMENTADOS** (5 críticos):

---

## 📋 PLUGINS QUE FALTAM IMPLEMENTAR

### 🔴 **FASE 1: CRÍTICOS** (implementar primeiro)

#### 1. **redmine_checklists** (Oficial)
**URL**: https://github.com/nodecarter/redmine_checklists.git  
**Prioridade**: 🔴 **CRÍTICA**  
**Funcionalidade**: Checklists avançados para tarefas  
**Status**: ❌ **NÃO INSTALADO**  
**Comando**:
```bash
./scripts/plugin-manager.sh install redmine_checklists https://github.com/nodecarter/redmine_checklists.git
./scripts/plugin-manager.sh enable redmine_checklists
```

#### 2. **redmine_dmsf** (Gestão de Documentos)
**URL**: https://github.com/danmunn/redmine_dmsf.git  
**Prioridade**: 🔴 **CRÍTICA**  
**Funcionalidade**: Sistema avançado de documentos  
**Status**: ❌ **NÃO INSTALADO**  
**Observação**: Plugin complexo, pode ter dependências  
**Comando**:
```bash
./scripts/plugin-manager.sh install redmine_dmsf https://github.com/danmunn/redmine_dmsf.git
./scripts/plugin-manager.sh enable redmine_dmsf
```

### 🟡 **FASE 2: IMPORTANTES** (após Fase 1)

#### 3. **redmine_attach_preview** (Preview de Anexos)
**URL**: https://github.com/alexandermeindl/redmine_attach_preview.git  
**Prioridade**: 🟡 **IMPORTANTE**  
**Funcionalidade**: Preview de arquivos anexados  
**Status**: ❌ **NÃO INSTALADO**  
**Comando**:
```bash
./scripts/plugin-manager.sh install redmine_attach_preview https://github.com/alexandermeindl/redmine_attach_preview.git
./scripts/plugin-manager.sh enable redmine_attach_preview
```

#### 4. **redmine_omniauth_azure** (SSO Microsoft)
**URL**: https://github.com/alexandermeindl/redmine_omniauth_azure.git  
**Prioridade**: 🟡 **IMPORTANTE**  
**Funcionalidade**: Login integrado com Azure AD  
**Status**: ❌ **NÃO INSTALADO**  
**Observação**: Pode precisar configuração Azure  
**Comando**:
```bash
./scripts/plugin-manager.sh install redmine_omniauth_azure https://github.com/alexandermeindl/redmine_omniauth_azure.git
./scripts/plugin-manager.sh enable redmine_omniauth_azure
```

### 🟢 **FASE 3: COMPLEMENTARES** (opcional)

#### 5. **redmine_agile** (Metodologias Ágeis)
**URL**: https://github.com/redminecrm/redmine_agile.git  
**Prioridade**: 🟢 **ÚTIL**  
**Funcionalidade**: Scrum/Kanban boards  
**Status**: ❌ **NÃO INSTALADO**  
**Observação**: Plugin comercial, pode ter limitações  

#### 6. **redmine_contacts** (Gestão de Contatos)
**URL**: https://github.com/redminecrm/redmine_contacts.git  
**Prioridade**: 🟢 **ÚTIL**  
**Funcionalidade**: CRM básico integrado  
**Status**: ❌ **NÃO INSTALADO**  

#### 7. **redmine_custom_css** (CSS Customizado)
**URL**: https://github.com/pdxwebdev/redmine_custom_css.git  
**Prioridade**: 🟢 **BAIXA**  
**Funcionalidade**: Interface para CSS customizado  
**Status**: ❌ **NÃO INSTALADO**  
**Observação**: Pode ser desnecessário (já temos tema)  

---

## 🚧 PLUGINS COM PROBLEMAS CONHECIDOS

### ⚠️ **redmine_recurring_tasks**
**Status**: Instalado mas desabilitado  
**Problema**: Incompatibilidade com Redmine 6.0  
**Ação**: Buscar fork compatível ou alternativa  

### ⚠️ **redmine_issue_templates**
**Status**: Instalado mas desabilitado  
**Problema**: Possíveis conflitos ou dependências  
**Ação**: Testar ativação e corrigir erros  

---

## 📊 PLANO DE IMPLEMENTAÇÃO RECOMENDADO

### 🎯 **Ordem de Prioridade**:

1. **PRIMEIRO**: Ativar plugins já instalados
   ```bash
   ./scripts/plugin-manager.sh enable redmine_issue_templates
   # Testar funcionamento
   ```

2. **SEGUNDO**: Instalar plugins críticos (Fase 1)
   ```bash
   ./scripts/plugin-manager.sh install redmine_checklists <url>
   ./scripts/plugin-manager.sh install redmine_dmsf <url>
   ```

3. **TERCEIRO**: Implementar plugins importantes (Fase 2)
   ```bash
   ./scripts/plugin-manager.sh install redmine_attach_preview <url>
   ./scripts/plugin-manager.sh install redmine_omniauth_azure <url>
   ```

4. **QUARTO**: Avaliar plugins complementares (Fase 3)

### ⚡ **Estratégia de Teste**:
- **Um plugin por vez**: Evitar conflitos
- **Testes incrementais**: Validar cada instalação
- **Backup antes**: Usar git para reverter se necessário
- **Logs detalhados**: Monitorar docker logs durante instalação

---

## 📋 COMANDOS DE REFERÊNCIA

### **Verificar Status**:
```bash
./scripts/plugin-manager.sh list
docker compose logs redmine | grep -i plugin
```

### **Testar Plugin**:
```bash
# Instalar
./scripts/plugin-manager.sh install <nome> <url>

# Ativar
./scripts/plugin-manager.sh enable <nome>

# Verificar logs
docker compose logs redmine -f

# Se der problema, desativar
./scripts/plugin-manager.sh disable <nome>
```

### **Migração de Plugins**:
```bash
docker compose exec redmine bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

---

## 🎯 METAS DE SUCESSO

### **Mínimo Viável** (3 plugins críticos):
- [ ] redmine_checklists funcionando
- [ ] redmine_dmsf funcionando  
- [ ] redmine_issue_templates ativado

### **Sistema Completo** (7 plugins):
- [ ] Todos os plugins da Fase 1 e 2 funcionando
- [ ] SSO Microsoft configurado
- [ ] Preview de documentos ativo
- [ ] Sistema de checklists avançado operacional

---

**🏆 STATUS ATUAL**: Tema completo ✅ | 3/8 plugins ativos  
**🎯 PRÓXIMO PASSO**: Ativar redmine_issue_templates  
**📈 PROGRESSO**: Base sólida estabelecida - 37% dos plugins necessários  
**⏱️ ESTIMATIVA**: 2-3 sessões para plugins críticos
