# 📋 PROCEDIMENTO: Operacionalização do Plugin Redmine More Previews

## 🎯 **DECISÃO ESTRATÉGICA: VERSIONAR PLUGIN CUSTOMIZADO**

### **Justificativa:**
O plugin `redmine_more_previews` requer correções específicas para compatibilidade com Rails 7. Para garantir **reprodutibilidade** e **manutenibilidade** do SGIME, optamos por versionar o plugin corrigido no repositório.

---

## 🔍 **PROCEDIMENTO COMPLETO IMPLEMENTADO**

### **1️⃣ Download do Plugin Original**
```bash
# Clone do repositório oficial
git clone https://github.com/HugoHasenbein/redmine_more_previews.git
cp -r redmine_more_previews plugins/
```

**Fonte:** HugoHasenbein/redmine_more_previews v5.0.9  
**Repositório:** https://github.com/HugoHasenbein/redmine_more_previews

### **2️⃣ Correções Aplicadas para Rails 7**

#### **A. Correção Zeitwerk (Diretivas Unloadable)**
```bash
# Problema: NameError undefined 'unloadable' for module VinceLib
# Solução: Substituir por comentários
find converters/vince/ -name "*.rb" -exec sed -i 's/^\s*unloadable\s*$/# unloadable # Deprecated in Rails 7/' {} \;
```

**Arquivos Corrigidos:** 10 arquivos no converter vince

#### **B. Desabilitação de Converters Problemáticos**
```bash
# Problema: Converters desabilitados ainda executando init.rb
# Solução: Renomear init.rb para .disabled
for dir in *_disabled; do 
  mv "$dir/init.rb" "$dir/init.rb.disabled"
done
```

**Converters Desabilitados:**
- cliff_disabled, libre_disabled, maggie_disabled
- mark_disabled, teddie_disabled, zippy_disabled

#### **C. Simplificação do Gemfile**
```ruby
# Remoção de dependências conflitantes:
# - marcel (conflito com Rails)
# - zlib (conflito interno)  
# - puma (duplicação)
```

### **3️⃣ Integração Docker Compose**
```yaml
# docker-compose.yml
volumes:
  - ./plugins/redmine_more_previews:/usr/src/redmine/plugins/redmine_more_previews
```

### **4️⃣ Versionamento no Repositório**
```bash
# .gitignore - Exceção criada
!plugins/redmine_more_previews/

# Adicionado ao repositório
git add plugins/redmine_more_previews/
git commit -m "feat: Add redmine_more_previews with Rails 7 fixes"
```

---

## ✅ **VANTAGENS DA ABORDAGEM ESCOLHIDA**

### **🔒 Estabilidade e Reprodutibilidade**
- ✅ **Reprodutível**: Qualquer clone do SGIME tem o plugin funcional
- ✅ **Correções Preservadas**: Fixes Rails 7 versionados permanentemente
- ✅ **Independência**: Não depende de repositório externo
- ✅ **Customização**: Facilita ajustes específicos do Colégio Pedro II

### **🛠️ Manutenibilidade**
- ✅ **Controle Total**: Modificações podem ser feitas conforme necessário
- ✅ **Histórico**: Git tracking de todas as mudanças
- ✅ **Backup**: Plugin preservado mesmo se repositório original for removido
- ✅ **Deployment**: Processo de instalação simplificado

---

## 🔄 **ALTERNATIVAS CONSIDERADAS**

### **❌ Opção 1: Download Automático via Script**
```bash
# scripts/setup-plugins.sh
git clone https://github.com/HugoHasenbein/redmine_more_previews.git
# + aplicar correções automaticamente
```

**Problemas:**
- Dependência de repositório externo
- Correções aplicadas a cada setup
- Falha se repositório original mudar
- Complexidade de manutenção

### **❌ Opção 2: Fork do Repositório Original**
```bash
# Fork próprio: noedelima/redmine_more_previews
```

**Problemas:**
- Manutenção de fork separado
- Complexidade de merge de updates
- Overhead de múltiplos repositórios

---

## 🎯 **CONVERTERS DISPONÍVEIS**

### **✅ Ativos (4 converters)**
```bash
converters/
├── nil_text/     ✅ Processamento de texto simples
├── pass/         ✅ Pass-through (HTML direto)
├── peek/         ✅ Preview básico de arquivos  
└── vince/        ✅ vCard/VCF (corrigido Rails 7)
```

### **💤 Disponíveis para Ativação (6 converters)**
```bash
converters/
├── cliff_disabled/   💤 Email/EML processing
├── libre_disabled/   💤 LibreOffice integration
├── maggie_disabled/  💤 Image processing  
├── mark_disabled/    💤 Markdown/LaTeX
├── teddie_disabled/  💤 Text processing
└── zippy_disabled/   💤 Archive handling
```

**Para ativar:**
```bash
cd plugins/redmine_more_previews/converters
mv cliff_disabled cliff
mv cliff/init.rb.disabled cliff/init.rb
# Repetir para outros converters conforme necessário
```

---

## 📊 **ESTRUTURA FINAL VERSIONADA**

### **Conteúdo no Repositório SGIME:**
```bash
plugins/redmine_more_previews/           # ✅ VERSIONADO
├── Gemfile                             # ✅ Simplificado
├── init.rb                             # ✅ Plugin principal
├── lib/                                # ✅ Core do plugin
├── app/views/                          # ✅ Templates
├── config/locales/                     # ✅ Traduções
├── converters/
│   ├── nil_text/                       # ✅ Ativo
│   ├── pass/                           # ✅ Ativo
│   ├── peek/                           # ✅ Ativo
│   ├── vince/                          # ✅ Ativo (corrigido)
│   ├── cliff_disabled/                 # ✅ Disponível
│   ├── libre_disabled/                 # ✅ Disponível
│   ├── maggie_disabled/                # ✅ Disponível
│   ├── mark_disabled/                  # ✅ Disponível
│   ├── teddie_disabled/                # ✅ Disponível
│   └── zippy_disabled/                 # ✅ Disponível
└── doc/                                # ✅ Documentação
```

**Total:** 273 arquivos versionados com correções Rails 7

---

## 🎉 **RESULTADO FINAL**

### **Plugin Totalmente Funcional:**
- ✅ **4 converters ativos** funcionando perfeitamente
- ✅ **6 converters opcionais** prontos para ativação
- ✅ **Compatibilidade Rails 7** garantida
- ✅ **Versionamento completo** no repositório SGIME
- ✅ **Reprodutibilidade 100%** para novos deployments

### **Benefícios Alcançados:**
- 🎯 **Estabilidade**: Plugin funcionando sem dependências externas
- 🔒 **Segurança**: Correções preservadas permanentemente  
- 🚀 **Simplicidade**: Um comando `git clone` e sistema completo
- 📋 **Documentação**: Procedimento completamente documentado

---

**📝 RECOMENDAÇÃO:** Esta abordagem (versionamento do plugin corrigido) é a **estratégia recomendada** para plugins que requerem correções específicas ou customizações para o ambiente SGIME.

*Procedimento documentado para futuras implementações de plugins complexos*
