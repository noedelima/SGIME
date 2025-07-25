# SGIME - Plugins Necessários 

**Sistema de Gestão Integrada de Engenharia**  
**Data:** 25 de Julho de 2025  
**Status:** Lista Consolidada Baseada na Especificação Técnica  
**Redmine:** 5.1.x  

---

## 📋 Resumo Executivo

Este documento consolida **TODOS** os plugins necessários para implementar o SGIME conforme especificação técnica oficial. Os plugins estão categorizados por prioridade e módulo funcional.

---

## 🔴 PLUGINS CRÍTICOS (Módulos Centrais)

### 1. **Redmine Checklists** - ⭐ ESSENCIAL
- **Função:** Listas de verificação para manutenção preventiva  
- **Módulo:** Planejamento e Controle da Manutenção  
- **Repositório:** https://github.com/nodecarter/redmine_checklists  
- **Versão:** 3.1.26+ (compatível Redmine 5.1)  
- **Especificação:** Seção 5.2 - "Plugin Redmine Checklists"  
- **Uso:** Criar modelos de checklist para inspeções de ativos  

### 2. **Redmine DMSF** - ⭐ ESSENCIAL  
- **Função:** Sistema de Gerenciamento de Documentos  
- **Módulo:** Gestão de Documentos de Projetos (GED)  
- **Repositório:** https://github.com/danmunn/redmine_dmsf  
- **Versão:** 3.1.3+ (compatível Redmine 5.1+)  
- **Especificação:** Seção 5.5 - "Plugin Redmine DMSF"  
- **Uso:** Repositório centralizado, controle de versões, fluxo de aprovação  

### 3. **Redmine Recurring Tasks** - ⭐ ESSENCIAL  
- **Função:** Tarefas recorrentes para manutenção preventiva  
- **Módulo:** Planejamento e Controle da Manutenção  
- **Repositório:** https://github.com/nutso/redmine-plugin-recurring-tasks  
- **Versão:** Versão estável compatível com Redmine 5.1  
- **Especificação:** Seção 5.2 - "Plugin Redmine Recurring Tasks"  
- **Uso:** Automatizar criação de tarefas de manutenção preventiva  

---

## 🟡 PLUGINS IMPORTANTES (Interface e Workflow)

### 4. **Redmine Dashboard** - 🎯 IMPORTANTE  
- **Função:** Dashboards customizáveis e task boards  
- **Módulo:** Relatórios e Indicadores  
- **Repositório:** https://github.com/jgraichen/redmine_dashboard  
- **Versão:** 2.16.0+ (compatível Redmine 5.0-6.0)  
- **Especificação:** Seção 5.4 - "Plugin Redmine Dashboard"  
- **Uso:** Visualizações por hierarquia e disciplina técnica  

### 5. **Redmine Attach Preview** - 🎯 IMPORTANTE  
- **Função:** Visualização de anexos no navegador  
- **Módulo:** Gestão de Documentos  
- **Repositório:** https://github.com/alexandermeindl/redmine_attach_preview  
- **Versão:** Versão compatível com Redmine 5.1  
- **Especificação:** Seção 5.5 - "Plugin Redmine Attach Preview"  
- **Uso:** Preview de PDFs, DWGs, imagens sem download  

### 6. **Redmine OmniAuth Azure** - 🎯 IMPORTANTE  
- **Função:** Single Sign-On com Microsoft Entra ID  
- **Módulo:** Autenticação e Autorização  
- **Repositório:** https://github.com/alexandermeindl/redmine_omniauth_azure  
- **Versão:** Versão compatível com Redmine 5.1  
- **Especificação:** Seção 4 - "Single Sign-On (SSO)"  
- **Uso:** Integração com contas Microsoft corporativas  

---

## 🟢 PLUGINS ÚTEIS (Funcionalidades Complementares)

### 7. **Redmine Agile** - 📊 ÚTIL  
- **Função:** Metodologias ágeis (Scrum/Kanban)  
- **Módulo:** Gerenciamento de Projetos  
- **Repositório:** https://github.com/redminecrm/redmine_agile  
- **Versão:** 1.6.5+ (compatível Redmine 4.2-5.1)  
- **Uso:** Task boards para acompanhamento visual de atividades  

### 8. **Redmine Contacts (CRM)** - 📊 ÚTIL  
- **Função:** Gestão de contatos e relacionamentos  
- **Módulo:** Administração  
- **Repositório:** https://github.com/redminecrm/redmine_contacts  
- **Versão:** 4.2.6+ (compatível Redmine 4.2-5.1)  
- **Uso:** Cadastro de empresas contratadas e fornecedores  

### 9. **Redmine Custom CSS** - 🎨 ÚTIL  
- **Função:** CSS personalizado por projeto  
- **Módulo:** Interface e Customização  
- **Repositório:** https://github.com/pdxwebdev/redmine_custom_css  
- **Versão:** 0.1.7+ (Redmine 3.0+)  
- **Uso:** Personalização visual específica por disciplina ou projeto  

---

## 🛠️ PLUGINS CUSTOMIZADOS (Desenvolvimento Próprio)

### 10. **SGIME Customizations** - ⭐ CRÍTICO  
- **Função:** Implementação das 3 customizações específicas  
- **Módulo:** Todos os módulos  
- **Localização:** `./plugins/sgime_customizations/`  
- **Especificação:** Seção 9.2 - "Customizações Necessárias"  
- **Componentes:**  
  - **Customização 1:** Geração de PDF de Vistoria  
  - **Customização 2:** Gatilho para OS automática  
  - **Customização 3:** Download de pacotes de documentos  

---

## 📦 PLANO DE IMPLEMENTAÇÃO

### **Fase 1: Infraestrutura (AGORA)**
```bash
# 1. Plugin de Checklists (Crítico)
./scripts/plugin-manager.sh install redmine_checklists https://github.com/nodecarter/redmine_checklists.git

# 2. Plugin de Documentos (Crítico)  
./scripts/plugin-manager.sh install redmine_dmsf https://github.com/danmunn/redmine_dmsf.git

# 3. Plugin de Tarefas Recorrentes (Crítico)
./scripts/plugin-manager.sh install redmine_recurring_tasks https://github.com/nutso/redmine-plugin-recurring-tasks.git
```

### **Fase 2: Interface (Esta Semana)**
```bash
# 4. Dashboard e Relatórios
./scripts/plugin-manager.sh install redmine_dashboard https://github.com/jgraichen/redmine_dashboard.git

# 5. Preview de Anexos
./scripts/plugin-manager.sh install redmine_attach_preview https://github.com/alexandermeindl/redmine_attach_preview.git

# 6. SSO Microsoft
./scripts/plugin-manager.sh install redmine_omniauth_azure https://github.com/alexandermeindl/redmine_omniauth_azure.git
```

### **Fase 3: Complementares (Próxima Semana)**
```bash
# 7. Metodologias Ágeis  
./scripts/plugin-manager.sh install redmine_agile https://github.com/redminecrm/redmine_agile.git

# 8. Gestão de Contatos
./scripts/plugin-manager.sh install redmine_contacts https://github.com/redminecrm/redmine_contacts.git

# 9. CSS Customizado
./scripts/plugin-manager.sh install redmine_custom_css https://github.com/pdxwebdev/redmine_custom_css.git
```

### **Fase 4: Customizações (Final)**
```bash
# 10. Plugin SGIME (Desenvolvimento próprio)
./scripts/plugin-manager.sh enable sgime_customizations
```

---

## ⚠️ DEPENDÊNCIAS E OBSERVAÇÕES

### **Dependências de Sistema**
- **redmine_dmsf:** Requer `xapian-ruby` para busca avançada (opcional)  
- **redmine_agile:** Pode conflitar com outros plugins de Kanban  
- **redmine_attach_preview:** Requer bibliotecas de conversão (ImageMagick, LibreOffice)  

### **Ordem de Instalação Crítica**
1. **SEMPRE** instalar plugins básicos primeiro (checklists, recurring_tasks)  
2. Plugins de documentos depois (dmsf, attach_preview)  
3. Plugins de interface por último (dashboard, agile)  
4. Customizações próprias sempre no final  

### **Teste Incremental Obrigatório**
- ✅ Instalar **UM plugin por vez**  
- ✅ Testar funcionalidade antes do próximo  
- ✅ Fazer backup antes de cada instalação  
- ✅ Monitorar logs durante instalação  
- ✅ Reverter imediatamente se houver problemas  

---

## 📊 MAPEAMENTO ESPECIFICAÇÃO → PLUGINS

| Módulo Funcional | Plugin(s) Necessário(s) | Prioridade |
|------------------|-------------------------|------------|
| **Gestão de Ativos** | Funcionalidade nativa do Redmine | N/A |
| **Planejamento e Controle** | redmine_checklists + redmine_recurring_tasks | 🔴 |
| **Gestão de OS** | sgime_customizations | 🔴 |
| **Relatórios e Indicadores** | redmine_dashboard | 🟡 |
| **Gestão de Documentos** | redmine_dmsf + redmine_attach_preview | 🔴 |
| **Administração** | redmine_omniauth_azure + redmine_contacts | 🟡 |

---

## 🎯 CRITÉRIOS DE SUCESSO

### **Metas Mínimas (Fase 1)**
- [ ] redmine_checklists instalado e funcionando  
- [ ] Criar um checklist de teste  
- [ ] redmine_dmsf instalado e configurado  
- [ ] Upload e preview de documento funcionando  
- [ ] redmine_recurring_tasks criando tarefas automaticamente  

### **Metas Completas (Fase 4)**  
- [ ] Todos os 10 plugins instalados e funcionando  
- [ ] Módulos da especificação técnica implementados  
- [ ] Customizações próprias funcionais  
- [ ] SSO Microsoft configurado e testado  
- [ ] Documentação de problemas atualizada  

---

## 🚀 COMANDOS DE VERIFICAÇÃO

### **Status Geral**
```bash
# Ver plugins habilitados
./scripts/plugin-manager.sh list

# Status dos containers
docker-compose ps

# Logs do Redmine
docker-compose logs redmine -f
```

### **Teste de Funcionalidade**
```bash
# Verificar plugins carregados no Redmine
docker exec sgime-redmine bundle exec rails runner "puts Redmine::Plugin.all.map(&:id)"

# Verificar migrações de plugins
docker exec sgime-redmine bundle exec rake redmine:plugins:migrate:status RAILS_ENV=production
```

---

**Status:** ✅ **PRONTO PARA IMPLEMENTAÇÃO**  
**Próximo Passo:** Instalar Fase 1 (Plugins Críticos)  
**Responsável:** GitHub Copilot  
**Data:** 25/07/2025  
