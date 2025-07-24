# SGIME - Plugins Oficiais Priorizados
## Versões Atualizadas e URLs de Download

**Data:** 24 de Julho de 2025  
**Redmine Target:** 5.1.x  
**Estratégia:** Plugins oficiais/nativos primeiro  

---

## 🎯 Plugins Prioritários (Oficiais)

### 1. **Redmine Checklists** 
- **Repositório:** https://github.com/nodecarter/redmine_checklists
- **Versão Atual:** 3.1.26 (Jan 2024)
- **Compatibilidade:** Redmine 5.0-5.1
- **Licença:** GPLv2
- **Prioridade:** 🔴 CRÍTICA
- **Funcionalidade:** Sistema de checklists em tarefas
- **Status:** ✅ Compatível com Redmine 5.1

### 2. **Redmine Dashboard**
- **Repositório:** https://github.com/jgraichen/redmine_dashboard
- **Versão Atual:** 2.16.0 (Jan 2025) 
- **Compatibilidade:** Redmine 5.0-6.0
- **Licença:** Apache 2.0
- **Prioridade:** 🟡 IMPORTANTE
- **Funcionalidade:** Task board e planning board
- **Status:** ✅ Compatível com Redmine 5.1

### 3. **Redmine DMSF (Document Management)**
- **Repositório:** https://github.com/danmunn/redmine_dmsf
- **Versão Atual:** 3.1.3 (Dez 2024)
- **Compatibilidade:** Redmine 5.1+
- **Licença:** GPLv2
- **Prioridade:** 🔴 CRÍTICA
- **Funcionalidade:** Gerenciamento avançado de documentos
- **Status:** ✅ Compatível com Redmine 5.1

### 4. **Redmine Agile**
- **Repositório:** https://github.com/redminecrm/redmine_agile
- **Versão Atual:** 1.6.5 (Dez 2024)
- **Compatibilidade:** Redmine 4.2-5.1
- **Licença:** GPLv3
- **Prioridade:** 🟡 IMPORTANTE
- **Funcionalidade:** Metodologias ágeis (Scrum/Kanban)
- **Status:** ✅ Compatível com Redmine 5.1

### 5. **Redmine CRM**
- **Repositório:** https://github.com/redminecrm/redmine_contacts
- **Versão Atual:** 4.2.6 (Nov 2024)
- **Compatibilidade:** Redmine 4.2-5.1
- **Licença:** GPLv3
- **Prioridade:** 🟢 ÚTIL
- **Funcionalidade:** Gestão de contatos e CRM
- **Status:** ✅ Compatível com Redmine 5.1

### 6. **Redmine Custom CSS**
- **Repositório:** https://github.com/pdxwebdev/redmine_custom_css
- **Versão Atual:** 0.1.7 (Set 2023)
- **Compatibilidade:** Redmine 3.0+
- **Licença:** MIT
- **Prioridade:** 🟢 ÚTIL
- **Funcionalidade:** CSS personalizado por projeto
- **Status:** ⚠️ Testar compatibilidade

---

## 📋 Plano de Implementação

### Fase 1: Plugins Críticos
1. **redmine_checklists** - Essencial para listas de verificação
2. **redmine_dmsf** - Gerenciamento de documentos
3. **redmine_dashboard** - Interface moderna

### Fase 2: Plugins Importantes
4. **redmine_agile** - Metodologias ágeis
5. **redmine_contacts** - Gestão de contatos

### Fase 3: Plugins Utilitários
6. **redmine_custom_css** - Personalização visual

---

## 🔧 Comandos de Instalação

### Usando o Plugin Manager
```bash
# 1. Redmine Checklists
./scripts/plugin-manager.sh install redmine_checklists https://github.com/nodecarter/redmine_checklists.git

# 2. Redmine Dashboard  
./scripts/plugin-manager.sh install redmine_dashboard https://github.com/jgraichen/redmine_dashboard.git

# 3. Redmine DMSF
./scripts/plugin-manager.sh install redmine_dmsf https://github.com/danmunn/redmine_dmsf.git

# 4. Redmine Agile
./scripts/plugin-manager.sh install redmine_agile https://github.com/redminecrm/redmine_agile.git

# 5. Redmine Contacts
./scripts/plugin-manager.sh install redmine_contacts https://github.com/redminecrm/redmine_contacts.git

# 6. Redmine Custom CSS
./scripts/plugin-manager.sh install redmine_custom_css https://github.com/pdxwebdev/redmine_custom_css.git
```

### Habilitação Individual
```bash
# Habilitar um por vez para teste
./scripts/plugin-manager.sh enable redmine_checklists
./scripts/plugin-manager.sh status

# Se OK, continuar com próximo
./scripts/plugin-manager.sh enable redmine_dashboard
./scripts/plugin-manager.sh status
```

---

## ⚠️ Observações Importantes

### Dependências Conhecidas
- **redmine_dmsf:** Requer `xapian-ruby` para busca (opcional)
- **redmine_agile:** Pode conflitar com outros plugins de Kanban
- **redmine_contacts:** Versão CRM pode ter funcionalidades pagas

### Ordem de Instalação Recomendada
1. Sempre instalar plugins básicos primeiro (checklists, dashboard)
2. Plugins de documentos depois (dmsf)
3. Plugins de metodologia por último (agile)

### Teste Incremental
- Instalar um plugin por vez
- Testar funcionalidade antes do próximo
- Fazer backup antes de cada instalação
- Monitorar logs durante instalação

---

## 🎯 Metas de Sucesso

- [ ] Sistema base funcionando sem plugins
- [ ] redmine_checklists instalado e funcional
- [ ] redmine_dashboard instalado e funcional  
- [ ] redmine_dmsf instalado e funcional
- [ ] Pelo menos 3 plugins principais funcionando
- [ ] Documentação de problemas encontrados

---

**Última Atualização:** 24/07/2025 20:30  
**Próximo Passo:** Instalar redmine_checklists  
**Status:** ✅ Pronto para começar instalação
