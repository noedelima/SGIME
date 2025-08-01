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
  sgime_custom.js
)

# Hook para adicionar CSS customizado e modificar elementos
class SgimeThemeHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    stylesheet_link_tag('sgime_custom', plugin: 'sgime_customizations') +
    javascript_include_tag('sgime_custom', plugin: 'sgime_customizations') +
    content_tag(:script, "
      // Substituir Redmine por SGIME no título
      document.addEventListener('DOMContentLoaded', function() {
        if (document.title.includes('Redmine')) {
          document.title = document.title.replace('Redmine', 'SGIME - Colégio Pedro II');
        }
        
        // Adicionar favicon
        var favicon = document.querySelector('link[rel=\"icon\"]') || document.querySelector('link[rel=\"shortcut icon\"]');
        if (!favicon) {
          var link = document.createElement('link');
          link.rel = 'icon';
          link.type = 'image/svg+xml';
          link.href = '/plugin_assets/sgime_customizations/images/favicon.svg';
          document.head.appendChild(link);
        }
      });
    ".html_safe)
  end
  
  def view_layouts_base_content(context={})
    # Adicionar conteúdo customizado se necessário
  end
end
