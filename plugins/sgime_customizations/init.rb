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
  }
end

# Hook para adicionar assets customizados no head da página
class SgimeCustomizationsHook < Redmine::Hook::ViewListener
  def view_layouts_base_html_head(context={})
    html = "".html_safe
    
    # Adicionar CSS customizado
    html << stylesheet_link_tag('sgime_custom', plugin: 'sgime_customizations')
    html << stylesheet_link_tag('cpii_brasao', plugin: 'sgime_customizations')
    html << stylesheet_link_tag('sgime_menu_fix', plugin: 'sgime_customizations')
    html << stylesheet_link_tag('sgime_contrast_max', plugin: 'sgime_customizations')
    html << stylesheet_link_tag('sgime_layout_fixes', plugin: 'sgime_customizations')
    
    # Adicionar JavaScript customizado
    html << javascript_include_tag('sgime_custom', plugin: 'sgime_customizations')
    
    # Adicionar favicons customizados
    html << sgime_custom_favicons
    
    html
  end
  
  private
  
  def sgime_custom_favicons
    html = "".html_safe
    
    # Tentar ler os arquivos de favicon
    begin
      plugin_dir = File.dirname(__FILE__)
      svg_path = File.join(plugin_dir, 'assets', 'images', 'favicon.svg')
      ico_path = File.join(plugin_dir, 'assets', 'images', 'favicon.ico')
      
      if File.exist?(svg_path)
        svg_data = Base64.strict_encode64(File.read(svg_path))
        html << %(<link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,#{svg_data}">).html_safe
      end
      
      if File.exist?(ico_path)
        ico_data = Base64.strict_encode64(File.read(ico_path))
        html << %(<link rel="shortcut icon" type="image/x-icon" href="data:image/x-icon;base64,#{ico_data}">).html_safe
      end
    rescue => e
      Rails.logger.warn "SGIME: Erro ao carregar favicons: #{e.message}"
    end
    
    html
  end
end

# Registrar o hook
Redmine::Hook.add_listener(SgimeCustomizationsHook)

# Override para suprimir o favicon padrão do Redmine
module ::ApplicationHelper
  def favicon
    # Retorna string vazia pois os favicons institucionais são injetados via plugin
    ''.html_safe
  end
end
