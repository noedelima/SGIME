# 🏫 SGIME - Tema Colégio Pedro II

## Implementação Completa da Identidade Visual Institucional

Este diretório contém a implementação completa do tema personalizado do SGIME para o Colégio Pedro II, desenvolvido como um plugin do Redmine que aplica a identidade visual oficial da instituição.

---

## 📋 Visão Geral

O tema implementa uma identidade visual completa e autêntica baseada nos logos oficiais do Colégio Pedro II, incluindo:

- ✅ **Favicon oficial** baseado no brasão CPII
- ✅ **Logo institucional** no cabeçalho do sistema
- ✅ **Paleta de cores oficial** da instituição
- ✅ **Menu de navegação** com alto contraste e visibilidade
- ✅ **Tipografia institucional** consistente
- ✅ **Elementos decorativos** inspirados no brasão
- ✅ **Interface responsiva** para dispositivos móveis

---

## 🎨 Elementos Implementados

### 1. Sistema de Cores Institucional
```css
:root {
  /* Cores oficiais do Colégio Pedro II */
  --cp2-azul-institucional: #003366;
  --cp2-azul-secundario: #004080;
  --cp2-dourado: #DAA520;
  --cp2-dourado-claro: #F4E4BC;
  --cp2-branco: #FFFFFF;
}
```

### 2. Favicon e Logo Oficial
- **Favicon SVG** baseado no brasão oficial com gradientes institucionais
- **Logo no header** integrado com texto "SGIME - Colégio Pedro II"
- **Substituição automática** de "Redmine" por "SGIME" via JavaScript

### 3. Menu de Navegação de Alto Contraste
- **Fundo dourado sólido** (#B8860B) para máxima visibilidade
- **Texto branco** com sombra para legibilidade
- **Bordas douradas** espessas (3px) para definição
- **Hover contrastante** com dourado claro e texto azul escuro

---

## 📁 Estrutura de Arquivos

```
plugins/sgime_customizations/
├── init.rb                              # Configuração do plugin + JavaScript
├── README.md                            # Esta documentação
├── assets/
│   ├── stylesheets/
│   │   ├── sgime_custom.css             # CSS principal do tema
│   │   ├── cpii_brasao.css              # Elementos do brasão
│   │   ├── sgime_menu_fix.css           # Correções de visibilidade
│   │   └── sgime_contrast_max.css       # CSS de máximo contraste
│   ├── javascripts/
│   │   └── sgime_custom.js              # JavaScript customizado
│   └── images/
│       ├── cpii-favicon.svg             # Favicon oficial
│       ├── favicon.svg                  # Favicon alternativo
│       └── favicon.ico                  # Fallback ICO
└── README_IDENTIDADE_VISUAL.md          # Documentação detalhada
```

---

## 🚀 Instalação e Uso

### 1. Pré-requisitos
- Redmine 6.0 ou superior
- Docker e Docker Compose v2
- Navegador moderno com suporte a CSS Grid e Flexbox

### 2. Instalação
O plugin já está configurado no sistema SGIME. Para aplicar mudanças:

```bash
cd /home/noedelima/source/SGIME
docker compose restart redmine
```

### 3. Verificação
Após reiniciar, verifique:
- ✅ Favicon do CPII na aba do navegador
- ✅ Logo oficial no cabeçalho
- ✅ Menu superior com botões dourados visíveis
- ✅ Título "SGIME - Colégio Pedro II"

---

## 🔧 Configuração Técnica

### CSS em Camadas
1. **sgime_custom.css** - Base do tema com variáveis e layout
2. **cpii_brasao.css** - Elementos específicos do brasão
3. **sgime_menu_fix.css** - Correções de visibilidade com alta especificidade
4. **sgime_contrast_max.css** - Override absoluto para máximo contraste

### JavaScript Dinâmico
- **Substituição de texto** automática (Redmine → SGIME)
- **Gerenciamento de favicon** com remoção de ícones antigos
- **Forçar visibilidade** de menus com multiple timeouts
- **Observer pattern** para mudanças dinâmicas no DOM

### Assets Precompilados
```ruby
Rails.application.config.assets.precompile += %w(
  sgime_custom.css
  cpii_brasao.css
  sgime_menu_fix.css
  sgime_contrast_max.css
  sgime_custom.js
)
```

---

## 🎯 Especificações de Design

### Cores Principais
| Elemento | Cor | Uso |
|----------|-----|-----|
| Header Background | `#003366` → `#004080` | Gradiente azul institucional |
| Menu Buttons | `#B8860B` | Fundo dourado escuro sólido |
| Menu Hover | `#F4E4BC` | Dourado claro no hover |
| Text Primary | `#FFFFFF` | Texto principal em menus |
| Text Hover | `#003366` | Texto no hover para contraste |

### Tipografia
- **Font Family**: `'Arial', 'Helvetica Neue', sans-serif`
- **Menu Font Weight**: `700` (super negrito)
- **Hover Font Weight**: `800` (extra negrito)
- **Text Shadow**: `1px 1px 2px rgba(0,0,0,0.8)` para legibilidade

### Espacamento e Layout
- **Menu Padding**: `8px 16px` (generoso)
- **Menu Gap**: `8px` entre botões
- **Border Radius**: `6px` (cantos arredondados)
- **Border Width**: `3px` (bordas espessas)

---

## 🐛 Solução de Problemas

### Menu Invisível
Se os botões do menu não estiverem visíveis:
1. Limpe o cache do navegador
2. Verifique se todos os CSS estão carregando
3. Reinicie o container Redmine

### Favicon Não Atualiza
1. Limpe o cache do navegador (Ctrl+F5)
2. Acesse ferramentas do desenvolvedor e limpe storage
3. Reinicie o navegador

### CSS Não Aplicado
1. Verifique se os assets foram precompilados
2. Confirme que o plugin está ativo
3. Verifique logs do Rails para erros

---

## 📱 Responsividade

### Breakpoints
- **Desktop**: > 768px - Menu completo com espaçamento generoso
- **Tablet**: 481px - 768px - Menu compacto mantendo visibilidade
- **Mobile**: ≤ 480px - Layout adaptativo com botões menores

### Adaptações Mobile
```css
@media (max-width: 768px) {
  #header h1 { font-size: 1.2rem; }
  .cpii-brasao { width: 35px; height: 35px; }
}
```

---

## 🔮 Roadmap Futuro

### Versão 2.1
- [ ] Modo escuro institucional
- [ ] Animações suaves de transição
- [ ] Componentes de interface avançados

### Versão 2.2
- [ ] Temas sazonais (eventos do CPII)
- [ ] Personalização por campus
- [ ] Dashboard institucional específico

---

## 👥 Equipe e Contribuição

**Desenvolvido por**: SGIME Team - Colégio Pedro II  
**Versão**: 2.0.0  
**Data**: Agosto 2025  

### Como Contribuir
1. Fork do repositório
2. Crie branch para features (`git checkout -b feature/nova-funcionalidade`)
3. Commit com convenção (`feat: adiciona novo componente`)
4. Push e abra Pull Request

---

## 📄 Licença

Este tema é desenvolvido especificamente para o Colégio Pedro II e segue as diretrizes de identidade visual da instituição.

---

## 📞 Suporte

Para suporte técnico ou dúvidas sobre implementação:
- **Issues**: GitHub Issues do projeto SGIME
- **Documentação**: README_IDENTIDADE_VISUAL.md
- **Logs**: `docker compose logs redmine`

---

**🏫 SGIME - Sistema de Gestão Integrada de Melhorias e Eficiência**  
**Colégio Pedro II - Transformando Gestão em Excelência**
