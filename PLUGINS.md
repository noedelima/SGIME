# 📦 PLUGINS DO SGIME v1.9

## 🎯 Visão Geral

O SGIME v1.9 inclui **6 plugins essenciais** que fornecem funcionalidade completa para gestão de engenharia do Colégio Pedro II. Todos os plugins são **100% compatíveis com Rails 7** e **totalmente funcionais**.

---

## 🔧 **1. Redmine Dashboard**

### **Descrição**
Dashboard personalizado com widgets específicos para gestão de engenharia.

### **Funcionalidades**
- Widgets customizáveis por usuário
- Visão geral de tarefas e projetos
- Métricas em tempo real
- Interface responsiva

### **Status**: ✅ **Funcional**

---

## 🎨 **2. SGIME Customizations**

### **Descrição**
Tema e customizações visuais oficiais do Colégio Pedro II.

### **Funcionalidades**
- Identidade visual Colégio Pedro II
- Logos e cores institucionais
- Layout otimizado para engenharia
- Responsividade mobile

### **Status**: ✅ **Funcional**

---

## ✅ **3. Redmine Checklists**

### **Descrição**
Sistema avançado de checklists para procedimentos de manutenção.

### **Funcionalidades**
- Checklists dinâmicos por tarefa
- Templates reutilizáveis
- Relatórios automáticos
- Integração com manutenção preventiva

### **Status**: ✅ **Funcional**

---

## 📁 **4. Redmine DMSF**

### **Descrição**
Sistema de gestão de documentos (Document Management System).

### **Funcionalidades**
- Repositório centralizado de documentos
- Controle de versões
- Fluxo de aprovação
- WebDAV para sincronização
- Integração com projetos

### **Status**: ✅ **Funcional**

---

## 🔄 **5. Redmine Recurring Tasks (SGIME)**

### **Descrição**
Versão customizada do plugin para tarefas recorrentes com correções específicas do SGIME.

### **Funcionalidades**
- Tarefas automáticas recorrentes
- Configuração flexível de periodicidade
- Geração automática de manutenção preventiva
- Integração com calendário

### **Correções SGIME**
- Compatibilidade Rails 7/Zeitwerk
- Correção de módulos deprecados
- Otimizações de performance

### **Status**: ✅ **Funcional**

---

## 👁️ **6. Redmine More Previews**

### **Descrição**
Sistema avançado de preview de arquivos com 10 converters especializados.

### **Converters Ativos (10/10)**

#### **📄 Documentos**
- **mark**: Markdown/LaTeX (.md, .tex, .latex)
- **teddie**: Arquivos de texto (.txt, .log, .conf, .ini)
- **nil_text**: Processamento de texto simples
- **pass**: Pass-through HTML direto

#### **🖼️ Mídia**
- **maggie**: Imagens e PDFs (.jpg, .png, .gif, .bmp, .pdf)
- **peek**: Preview básico de arquivos diversos

#### **📧 Comunicação**
- **cliff**: Emails (.eml, .msg)
- **vince**: vCard/VCF (.vcf) - **corrigido Rails 7**

#### **📊 Office**
- **libre**: LibreOffice (.doc, .docx, .xls, .xlsx, .ppt, .pptx, .odt, .ods, .odp)

#### **🗜️ Archives**
- **zippy**: Arquivos compactados (.zip, .tar, .gz, .rar)

### **Benefícios**
- Preview direto de 20+ formatos
- Redução de downloads desnecessários
- Interface mais intuitiva
- Melhor produtividade

### **Status**: ✅ **Funcional (10/10 converters ativos)**

---

## 🚀 **Instalação de Plugins**

### **Automática (Recomendada)**
```bash
./setup.sh
# Todos os 6 plugins são instalados e configurados automaticamente
```

### **Manual**
```bash
cd plugins/
# Plugins já estão incluídos no repositório
# Apenas executar migrações se necessário
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
```

---

## 🔧 **Manutenção**

### **Verificar Status**
```bash
./scripts/manage.sh status
```

### **Atualizar Plugins**
```bash
./scripts/plugin-manager.sh update
```

### **Backup**
```bash
./scripts/backup.sh
```

---

## 🎯 **Compatibilidade**

- **Ruby**: 3.3.x
- **Rails**: 7.2.x
- **Redmine**: 6.0.x
- **PostgreSQL**: 16.x
- **Docker**: 20.x+

---

## 📞 **Suporte**

Para questões específicas sobre plugins:

1. **Documentação**: Consulte `docs/`
2. **Logs**: `logs/redmine/`
3. **Issues**: Repositório oficial
4. **Comunidade**: Fórum Redmine

**Sistema validado e pronto para produção! 🎉**
