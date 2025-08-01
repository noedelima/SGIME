Redmine::Plugin.register :sgime_customizations do
  name 'SGIME Customizations Plugin - Colégio Pedro II'
  author 'SGIME Team - Colégio Pedro II'
  description 'Customizações específicas do SGIME para o Colégio Pedro II - CSS, JS e funcionalidades personalizadas'
  version '2.0.0'
  url 'https://github.com/noedelima/SGIME'
  author_url 'https://github.com/noedelima'
  
  # Configurações do plugin
  settings default: {
    'custom_css_enabled' => true,
    'custom_js_enabled' => true,
    'sgime_theme_enabled' => true,
    'cpii_branding_enabled' => true
  }, partial: 'settings/sgime_customizations'
  
  # Permissões
  project_module :sgime_customizations do
    permission :view_sgime_customizations, {}, public: true
    permission :manage_sgime_customizations, {}
  end
  
  # Menu principal
  menu :application_menu, :sgime_dashboard,
       { controller: 'sgime_dashboard', action: 'index' },
       caption: 'SGIME Dashboard',
       if: Proc.new { User.current.logged? }
end

# Carregar assets customizados
Rails.application.config.assets.precompile += %w(
  sgime_custom.css
  cpii_brasao.css
  sgime_menu_fix.css
  sgime_contrast_max.css
  sgime_custom.js
)

# Hook para adicionar CSS customizado e modificar elementos
class SgimeThemeHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    stylesheet_link_tag('sgime_custom', plugin: 'sgime_customizations') +
    stylesheet_link_tag('cpii_brasao', plugin: 'sgime_customizations') +
    stylesheet_link_tag('sgime_menu_fix', plugin: 'sgime_customizations') +
    stylesheet_link_tag('sgime_contrast_max', plugin: 'sgime_customizations') +
    javascript_include_tag('sgime_custom', plugin: 'sgime_customizations') +
    javascript_tag(<<~JS.html_safe)
      document.addEventListener('DOMContentLoaded', function() {
        
        // === FAVICON OFICIAL DO COLÉGIO PEDRO II ===
        // Remove favicons existentes
        var existingFavicons = document.querySelectorAll('link[rel*="icon"]');
        existingFavicons.forEach(function(favicon) {
          favicon.remove();
        });
        
        // Favicon SVG com brasão oficial do CPII
        var faviconSvg = document.createElement('link');
        faviconSvg.rel = 'icon';
        faviconSvg.type = 'image/svg+xml';
        faviconSvg.href = 'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 32 32"><defs><radialGradient id="bg" cx="50%" cy="50%"><stop offset="0%" stop-color="%23004080"/><stop offset="100%" stop-color="%23003366"/></radialGradient><radialGradient id="globe" cx="50%" cy="50%"><stop offset="0%" stop-color="%23F4E4BC"/><stop offset="100%" stop-color="%23DAA520"/></radialGradient></defs><rect width="32" height="32" fill="url(%23bg)" rx="3"/><circle cx="16" cy="16" r="12" fill="url(%23globe)" stroke="%23003366" stroke-width="1"/><g stroke="%23003366" stroke-width="0.8" fill="none"><circle cx="16" cy="16" r="8"/><ellipse cx="16" cy="16" rx="8" ry="5"/><ellipse cx="16" cy="16" rx="5" ry="8"/><line x1="8" y1="16" x2="24" y2="16"/><line x1="16" y1="8" x2="16" y2="24"/></g><rect x="10" y="13.5" width="12" height="3" fill="%23003366" rx="0.5"/><text x="16" y="16" font-family="Arial,sans-serif" font-size="2.2" font-weight="bold" text-anchor="middle" fill="%23F4E4BC">CPII</text></svg>';
        
        // Favicon ICO como fallback
        var faviconIco = document.createElement('link');
        faviconIco.rel = 'shortcut icon';
        faviconIco.type = 'image/x-icon';
        faviconIco.href = 'data:image/x-icon;base64,AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAgAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAA2AAAAdAAAAAAAAAD///8A';
        
        document.head.appendChild(faviconSvg);
        document.head.appendChild(faviconIco);
        
        // === TÍTULO DA PÁGINA COM IDENTIDADE INSTITUCIONAL ===
        function updatePageTitle() {
          var title = document.title;
          if (title.includes('Redmine')) {
            document.title = title.replace(/Redmine/g, 'SGIME - Colégio Pedro II');
          } else if (!title.includes('SGIME')) {
            document.title = 'SGIME - Colégio Pedro II | ' + title;
          }
        }
        
        updatePageTitle();
        
        // Observa mudanças no título da página
        var titleObserver = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
              updatePageTitle();
            }
          });
        });
        
        var titleElement = document.querySelector('title');
        if (titleElement) {
          titleObserver.observe(titleElement, { childList: true });
        }
        
        // === SUBSTITUIÇÃO DINÂMICA DE TEXTO "REDMINE" ===
        function replaceRedmineText() {
          var walker = document.createTreeWalker(
            document.body,
            NodeFilter.SHOW_TEXT,
            null,
            false
          );
          
          var textNodes = [];
          var node;
          
          while (node = walker.nextNode()) {
            if (node.nodeValue && node.nodeValue.includes('Redmine')) {
              textNodes.push(node);
            }
          }
          
          textNodes.forEach(function(textNode) {
            textNode.nodeValue = textNode.nodeValue.replace(/Redmine/g, 'SGIME');
          });
        }
        
        replaceRedmineText();
        
        // === MELHORIAS DE INTERFACE ===
        // Garante visibilidade dos links do menu com ALTO CONTRASTE
        function enforceMenuVisibility() {
          var topMenuLinks = document.querySelectorAll('#top-menu ul li a');
          topMenuLinks.forEach(function(link) {
            // Força todas as propriedades de visibilidade com ALTO CONTRASTE
            link.style.setProperty('color', '#FFFFFF', 'important');
            link.style.setProperty('background', 'rgba(218, 165, 32, 0.8)', 'important'); // Dourado semi-transparente
            link.style.setProperty('display', 'inline-block', 'important');
            link.style.setProperty('visibility', 'visible', 'important');
            link.style.setProperty('opacity', '1', 'important');
            link.style.setProperty('padding', '0.5rem 1rem', 'important');
            link.style.setProperty('border-radius', '5px', 'important');
            link.style.setProperty('border', '2px solid #DAA520', 'important'); // Borda dourada
            link.style.setProperty('text-shadow', '0 1px 3px rgba(0,0,0,0.8)', 'important'); // Sombra forte
            link.style.setProperty('font-weight', '600', 'important'); // Mais negrito
            link.style.setProperty('text-decoration', 'none', 'important');
            link.style.setProperty('transition', 'all 0.3s ease', 'important');
            link.style.setProperty('margin', '0 0.5rem', 'important');
            link.style.setProperty('box-shadow', '0 2px 6px rgba(0,0,0,0.3)', 'important'); // Sombra destaque
            link.style.setProperty('min-width', '80px', 'important');
            link.style.setProperty('text-align', 'center', 'important');
          });
          
          // Garante estrutura do menu com fundo contrastante
          var topMenu = document.querySelector('#top-menu');
          if (topMenu) {
            topMenu.style.setProperty('background', 'rgba(0, 51, 102, 0.9)', 'important'); // Azul forte
            topMenu.style.setProperty('padding', '0.8rem', 'important');
            topMenu.style.setProperty('border-radius', '8px', 'important');
            topMenu.style.setProperty('border', '2px solid rgba(218, 165, 32, 0.5)', 'important'); // Borda dourada
            topMenu.style.setProperty('box-shadow', '0 4px 15px rgba(0,0,0,0.3)', 'important');
            topMenu.style.setProperty('backdrop-filter', 'blur(10px)', 'important');
          }
          
          var topMenuUl = document.querySelector('#top-menu ul');
          if (topMenuUl) {
            topMenuUl.style.setProperty('display', 'block', 'important');
            topMenuUl.style.setProperty('visibility', 'visible', 'important');
            topMenuUl.style.setProperty('opacity', '1', 'important');
          }
          
          var topMenuLis = document.querySelectorAll('#top-menu ul li');
          topMenuLis.forEach(function(li) {
            li.style.setProperty('display', 'inline-block', 'important');
            li.style.setProperty('margin', '0', 'important');
            li.style.setProperty('visibility', 'visible', 'important');
            li.style.setProperty('opacity', '1', 'important');
          });
        }
        
        // Executa imediatamente e depois de um delay
        enforceMenuVisibility();
        setTimeout(enforceMenuVisibility, 100);
        setTimeout(enforceMenuVisibility, 500);
        setTimeout(enforceMenuVisibility, 1000);
        
        // === OBSERVER PARA MUDANÇAS DINÂMICAS ===
        var contentObserver = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.addedNodes.length > 0) {
              replaceRedmineText();
            }
          });
        });
        
        contentObserver.observe(document.body, {
          childList: true,
          subtree: true
        });
        
        console.log('🏫 SGIME - Sistema carregado com identidade do Colégio Pedro II');
      });
    JS
  end
  
  def view_layouts_base_content(context={})
    # Adicionar conteúdo customizado se necessário
  end
end
