require 'base64'

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
  
  # Menu principal será implementado futuramente
  # menu :application_menu, :sgime_dashboard,
  #      { controller: 'sgime_dashboard', action: 'index' },
  #      caption: 'SGIME Dashboard',
  #      if: Proc.new { User.current.logged? }
end

# Carregar assets customizados
Rails.application.config.assets.precompile += %w(
  sgime_custom.css
  cpii_brasao.css
  sgime_menu_fix.css
  sgime_contrast_max.css
  sgime_layout_fixes.css
  sgime_custom.js
)

# Carregar patches quando o Rails inicializar os plugins
Rails.configuration.to_prepare do
  if defined?(Checklist)
    unless Checklist.included_modules.include?(SgimeChecklistPatch)
      Checklist.send(:include, SgimeChecklistPatch)
    end
  end
end

# Hook para adicionar CSS customizado e modificar elementos
class SgimeThemeHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    # Preparar favicons como data URL para evitar dependência de /plugin_assets
    svg_data = begin
      path = Rails.root.join('plugins', 'sgime_customizations', 'assets', 'images', 'cpii-favicon.svg')
      Base64.strict_encode64(File.binread(path))
    rescue
      nil
    end
    ico_data = begin
      path = Rails.root.join('plugins', 'sgime_customizations', 'assets', 'images', 'favicon.ico')
      Base64.strict_encode64(File.binread(path))
    rescue
      nil
    end

    stylesheet_link_tag('sgime_custom', plugin: 'sgime_customizations') +
    stylesheet_link_tag('cpii_brasao', plugin: 'sgime_customizations') +
    stylesheet_link_tag('sgime_menu_fix', plugin: 'sgime_customizations') +
    stylesheet_link_tag('sgime_contrast_max', plugin: 'sgime_customizations') +
    stylesheet_link_tag('sgime_layout_fixes', plugin: 'sgime_customizations') +
    javascript_include_tag('sgime_custom', plugin: 'sgime_customizations') +
    # Favicons inline no head via data URL (prioriza SVG + fallback ICO)
    (<<~HTML).html_safe +
  <script>(function(){function purgeFav(){try{document.querySelectorAll('head link[rel="icon"], head link[rel="shortcut icon"]').forEach(function(l){var h=l.getAttribute('href')||''; if(h && !h.startsWith('data:image/')) l.remove();});}catch(e){console.warn('Falha limpeza favicons',e);} }purgeFav();try{new MutationObserver(function(m){purgeFav();}).observe(document.head,{childList:true,subtree:true});}catch(e){/* ignore */}})();</script>
      #{svg_data ? "<link rel=\"icon\" type=\"image/svg+xml\" href=\"data:image/svg+xml;base64,#{svg_data}\">" : ''}
      #{ico_data ? "<link rel=\"shortcut icon\" type=\"image/x-icon\" href=\"data:image/x-icon;base64,#{ico_data}\">" : ''}
    HTML
    javascript_tag(<<~JS.html_safe)
      document.addEventListener('DOMContentLoaded', function() {
        // === NORMALIZAÇÃO DE FAVICONS ===
        // Remove qualquer favicon pré-existente servido por /assets (ex: favicon gerado padrão do Redmine)
        // mantendo apenas os inlines (data:) injetados pelo hook.
        (function ensureOnlyInstitutionalFavicons() {
          try {
            var links = document.querySelectorAll('link[rel="icon"], link[rel="shortcut icon"]');
            links.forEach(function(l){
              var href = (l.getAttribute('href')||'');
              if(href && !href.startsWith('data:image/')) {
                l.parentNode && l.parentNode.removeChild(l);
              }
            });
            // Se por algum motivo nossos favicons não existirem (ex: erro de leitura no servidor), não recriamos aqui
            // para evitar lógica duplicada; fallback visual será o favicon padrão removido.
          } catch(e) { console.warn('Falha ao normalizar favicons', e); }
        })();
        
        // === TÍTULO DA PÁGINA COM IDENTIDADE INSTITUCIONAL ===
        function updatePageTitle() {
          var title = document.title;
          if (!title.includes('SGIME')) {
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
        
  // === SUBSTITUIÇÃO GLOBAL DESATIVADA ===
  // Importante: não substituir "Redmine" globalmente para preservar nomes de usuários
  // e o rodapé "Powered by Redmine". A identidade visual é aplicada via header/título.
        
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
        
  // Observer removido pois não há substituição global de texto.
        
        console.log('🏫 SGIME - Sistema carregado com identidade do Colégio Pedro II');
      });
    JS
  end
  
  def view_layouts_base_content(context={})
    # Adicionar conteúdo customizado se necessário
  end
end

# Override para suprimir o favicon padrão do Redmine (evita emissão do link /assets/favicon-*.ico)
module ::ApplicationHelper
  def favicon
    # Retorna string vazia pois os favicons institucionais são injetados via hook do plugin.
    ''.html_safe
  end
end
