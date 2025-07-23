# Plugin de Customizações do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

require 'redmine'

Redmine::Plugin.register :sgime_customizations do
  name 'SGIME - Customizações Específicas'
  author 'Seção de Engenharia - Colégio Pedro II'
  description 'Plugin com customizações específicas para o Sistema de Gestão Integrada de Engenharia'
  version '1.6.0'
  url 'https://sgime.cp2.g12.br'
  author_url 'mailto:engenharia@cp2.g12.br'

  # Definir configurações globais
  settings default: {
    'organization_name' => 'Colégio Pedro II',
    'department_name' => 'Seção de Engenharia',
    'contact_email' => 'engenharia@cp2.g12.br',
    'system_version' => '1.6',
    'enable_automatic_os' => true,
    'enable_pdf_reports' => true,
    'enable_document_packages' => true
  }, partial: 'settings/sgime_settings'

  # Adicionar menu administrativo
  menu :admin_menu, :sgime_admin, 
       { controller: 'sgime_admin', action: 'index' },
       caption: 'SGIME - Configurações',
       html: { class: 'icon icon-settings' },
       if: Proc.new { User.current.admin? }

  # Adicionar permissões específicas
  project_module :sgime_manutencao do
    permission :view_assets, {}, read: true
    permission :manage_assets, {}
    permission :view_maintenance, {}, read: true
    permission :manage_maintenance, {}
    permission :view_work_orders, {}, read: true
    permission :manage_work_orders, {}
    permission :generate_reports, {}
  end

  project_module :sgime_documentos do
    permission :view_documents, {}, read: true
    permission :manage_documents, {}
    permission :approve_documents, {}
    permission :download_packages, {}
  end
end

# Hooks para customizações
class SgimeHooks < Redmine::Hook::ViewListener
  
  # Adicionar CSS/JS personalizado
  def view_layouts_base_html_head(context = {})
    stylesheet_link_tag('sgime_custom', plugin: 'sgime_customizations') +
    javascript_include_tag('sgime_custom', plugin: 'sgime_customizations')
  end

  # Customizar header da aplicação
  def view_layouts_base_body_bottom(context = {})
    content_tag(:script, type: 'text/javascript') do
      raw "
        // Adicionar identificação visual do SGIME
        if (document.querySelector('#header h1')) {
          document.querySelector('#header h1').innerHTML = 
            '<span style=\"color: #1f4788;\">SGIME</span> - Sistema de Gestão Integrada de Engenharia';
        }
        
        // Adicionar informações do Colégio Pedro II
        var footer = document.querySelector('#footer');
        if (footer) {
          footer.innerHTML += '<br><small>Colégio Pedro II - Seção de Engenharia | Versão 1.6</small>';
        }
      "
    end
  end

  # Hook para geração automática de OS
  def controller_issues_edit_after_save(context = {})
    issue = context[:issue]
    
    # Verificar se é uma lista de verificação com item não conforme
    if issue.tracker.name == 'LISTA DE VERIFICAÇÃO' && 
       issue.custom_field_value('status_conformidade') == 'Não Conforme'
       
      # Gerar OS automaticamente
      SgimeCustomizations::WorkOrderGenerator.new(issue).generate_work_order
    end
  end
end
