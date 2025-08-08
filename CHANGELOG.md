# Changelog

## [1.8.0] - 2025-08-08 - Final Stable Release

### ✨ Added
- **Redmine More Previews**: Plugin completamente implementado com 10 converters ativos
  - Converters ativados: cliff, libre, maggie, mark, nil_text, pass, peek, teddie, vince, zippy
  - Suporte para 20+ formatos de arquivo (markdown, imagens, office, email, archives)
  - Compatibilidade total com Rails 7

### 🔧 Fixed
- Correção completa de compatibilidade Rails 7/Zeitwerk
- Remoção de diretivas `unloadable` deprecadas
- Plugin Recurring Tasks: versão customizada SGIME com correções

### 🧹 Improved
- Documentação consolidada e limpa
- Remoção de arquivos temporários de desenvolvimento
- Scripts de instalação validados e atualizados
- Sistema 100% estável para produção

### 📦 Plugins Status (6/6 ✅)
- ✅ Redmine Dashboard
- ✅ SGIME Customizations  
- ✅ Redmine Checklists
- ✅ Redmine DMSF
- ✅ Redmine Recurring Tasks
- ✅ Redmine More Previews

---

## [1.7.0] - 2025-08-07

### ✨ Added
Esta é a primeira versão totalmente funcional do SGIME v1.7 com compatibilidade completa para Rails 7.2.x.

---

## ✅ **PLUGINS IMPLEMENTADOS**

### 🆕 **Novos Plugins (v1.7)**
- **Redmine More Previews v5.0.9** - Visualizações avançadas de arquivos
  - 4 converters ativos: nil_text, pass, peek, vince
  - Compatibilidade Rails 7 (diretivas unloadable corrigidas)
  - 6 converters adicionais disponíveis para ativação

### ✅ **Plugins Mantidos (atualizados para Rails 7)**
- **SGIME Customizations v2.0.0** - Tema Colégio Pedro II
- **Redmine Dashboard v2.16.0** - Dashboard interativo  
- **Redmine Checklists v3.1.27** - Sistema de checklists
- **Redmine DMSF v4.2.2** - Gestão de documentos
- **Redmine Recurring Tasks v2.0.0-sgime** - Tarefas recorrentes (versão customizada)

---

## 🔧 **MELHORIAS TÉCNICAS**

### **Infraestrutura**
- ✅ **Rails 7.2.x**: Compatibilidade completa
- ✅ **Redmine 6.0**: Versão mais recente
- ✅ **PostgreSQL 16**: Database moderno
- ✅ **Docker Compose**: Orquestração simplificada
- ✅ **Nginx + SSL**: Proxy reverso com HTTPS

### **Estabilidade**
- ✅ **Zeitwerk Autoloader**: Todos os plugins compatíveis
- ✅ **Assets Pipeline**: Compilação otimizada
- ✅ **Health Checks**: Monitoramento de containers
- ✅ **Volume Management**: Plugins dynamicamente gerenciáveis

### **Código Limpo**
- ✅ **Remoção de Backups**: Limpeza de arquivos temporários
- ✅ **Plugins Redundantes**: Remoção de versões não utilizadas
- ✅ **Docker Compose**: Comentários atualizados
- ✅ **Documentação**: README.md corrigido e atualizado

---

## 🛠️ **CORREÇÕES CRÍTICAS**

### **Plugin More Previews**
- **Problema**: Converters desabilitados com init.rb ativo
- **Solução**: Renomeados init.rb para init.rb.disabled
- **Resultado**: Plugin carrega apenas converters ativos

### **Plugin Recurring Tasks**
- **Problema**: Volume com indentação incorreta no docker-compose.yml
- **Solução**: Correção de indentação YAML
- **Resultado**: Plugin restaurado e funcional

### **Compatibilidade Rails 7**
- **Problema**: Diretivas `unloadable` deprecadas no converter vince
- **Solução**: Substituição por comentários via sed
- **Resultado**: Carregamento bem-sucedido em Rails 7

---

## 📊 **ARQUITETURA FINAL**

### **Containers**
```bash
sgime-postgres    ✅ PostgreSQL 16
sgime-redmine     ✅ Redmine 6.0 + Rails 7.2.x
sgime-nginx       ✅ Nginx + SSL
```

### **Plugins Ativos**
```bash
1. sgime_customizations           ✅ Tema CP2
2. redmine_dashboard             ✅ Dashboard
3. redmine_checklists            ✅ Checklists
4. redmine_dmsf                  ✅ Documentos
5. redmine_recurring_tasks_sgime ✅ Tarefas Recorrentes
6. redmine_more_previews         ✅ Visualizações
```

### **Estrutura Limpa**
```bash
plugins/
├── sgime_customizations/        ✅ Tema
├── redmine_dashboard/          ✅ Dashboard
├── redmine_checklists/         ✅ Checklists
├── redmine_dmsf/              ✅ DMSF
├── redmine_recurring_tasks_sgime/ ✅ Recurring Tasks
└── redmine_more_previews/      ✅ More Previews
```

---

## 🎯 **PRÓXIMAS VERSÕES**

### **v1.7.1 (Opcional)**
- Ativação de converters adicionais do More Previews
- Métricas de performance
- Relatórios customizados

### **v1.8.0 (Futuro)**
- Integrações com sistemas externos
- Workflows específicos do Colégio Pedro II
- Funcionalidades avançadas de engenharia

---

## 📋 **TESTE E VALIDAÇÃO**

### **Ambiente Testado**
- ✅ **OS**: Linux (desenvolvimento)
- ✅ **Docker**: 24.x
- ✅ **Docker Compose**: v2.x
- ✅ **Browsers**: Chrome, Firefox, Edge

### **Funcionalidades Validadas**
- ✅ **Login/Logout**: Sistema de autenticação
- ✅ **Dashboard**: Visualizações e widgets
- ✅ **Projetos**: Criação e gerenciamento
- ✅ **Tarefas**: Issues e workflows
- ✅ **Documentos**: Upload e versionamento
- ✅ **Checklists**: Criação e execução
- ✅ **Tarefas Recorrentes**: Automação
- ✅ **Previews**: Visualização de arquivos

---

**🎉 SGIME v1.7.0 - ESTÁVEL E PRONTO PARA PRODUÇÃO!**

*Sistema completo para gestão de engenharia do Colégio Pedro II*  
*6 plugins essenciais • Rails 7 Ready • Docker Compose • PostgreSQL 16*
