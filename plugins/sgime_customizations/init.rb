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
    
    # Adicionar CSS inline para logotipo do CPII
    html << %(
      <style>
        #header h1 {
          background-image: url('/images/logo-cpii-oficial.png') !important;
          background-repeat: no-repeat !important;
          background-position: 10px center !important;
          background-size: 50px 50px !important;
          padding-left: 75px !important;
          font-size: 1.6rem !important;
          color: white !important;
          font-weight: 600 !important;
          text-shadow: 0 2px 4px rgba(0,0,0,0.3) !important;
        }
        #header h1::before {
          background: none !important;
        }
      </style>
    ).html_safe
    
    # Adicionar favicons customizados
    html << sgime_custom_favicons
    
    html
  end
  
  def view_layouts_base_body_top(context={})
    # Hook alternativo para adicionar elementos no topo da página
    html = "".html_safe
    
    # JavaScript para substituir favicon dinamicamente se necessário
    html << %(<script type="text/javascript">
      $(document).ready(function() {
        // Garantir que o logotipo esteja visível
        console.log('🏫 SGIME - Logotipo do Colégio Pedro II carregado');
      });
    </script>).html_safe
    
    html
  end
  
  private
  
  def cpii_logo_base64
    begin
      plugin_dir = File.dirname(__FILE__)
      logo_path = File.join(plugin_dir, 'assets', 'images', 'logo-cpii-oficial.png')
      
      if File.exist?(logo_path)
        Base64.strict_encode64(File.read(logo_path))
      else
        ""
      end
    rescue => e
      Rails.logger.warn "SGIME: Erro ao carregar logo CPII: #{e.message}"
      ""
    end
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
