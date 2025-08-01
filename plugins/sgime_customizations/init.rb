Redmine::Plugin.register :sgime_customizations do
  name 'SGIME Customizations Plugin'
  author 'SGIME Team'
  description 'Customizações específicas do SGIME - CSS, JS e funcionalidades personalizadas'
  version '1.0.0'
  url 'https://github.com/noedelima/SGIME'
  author_url 'https://github.com/noedelima'
  
  # Configurações do plugin
  settings default: {
    'custom_css_enabled' => true,
    'custom_js_enabled' => true,
    'sgime_theme_enabled' => true
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

# Hook para adicionar CSS customizado
class SgimeThemeHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    stylesheet_link_tag('sgime_custom', plugin: 'sgime_customizations') +
    javascript_include_tag('sgime_custom', plugin: 'sgime_customizations')
  end
end
