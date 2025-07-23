module SgimeCustomizations
  # Gerador automático de Ordens de Serviço
  # Customização 2 da especificação técnica
  class WorkOrderGenerator
    
    def initialize(checklist_issue)
      @checklist_issue = checklist_issue
    end
    
    def generate_work_order
      return unless should_generate_work_order?
      
      work_order = create_work_order
      link_issues(work_order)
      notify_stakeholders(work_order)
      
      work_order
    end
    
    private
    
    def should_generate_work_order?
      # Verificar se já não existe uma OS vinculada
      existing_os = @checklist_issue.relations.select do |relation|
        relation.issue_to.tracker.name == 'ORDEM DE SERVIÇO'
      end
      
      existing_os.empty?
    end
    
    def create_work_order
      Issue.create!(
        project: @checklist_issue.project,
        tracker: Tracker.find_by(name: 'ORDEM DE SERVIÇO'),
        author: @checklist_issue.author,
        assigned_to: find_maintenance_responsible,
        subject: "OS - #{@checklist_issue.subject}",
        description: build_work_order_description,
        priority: determine_priority,
        custom_field_values: build_custom_fields
      )
    end
    
    def build_work_order_description
      description = "**Ordem de Serviço gerada automaticamente**\n\n"
      description += "**Origem:** Lista de Verificação #{@checklist_issue.id}\n"
      description += "**Ativo:** #{@checklist_issue.custom_field_value('codigo_ativo')}\n"
      description += "**Local:** #{@checklist_issue.custom_field_value('localizacao')}\n"
      description += "**Disciplina:** #{@checklist_issue.custom_field_value('disciplina')}\n\n"
      
      description += "**Não Conformidades Identificadas:**\n"
      
      # Buscar itens não conformes do checklist
      non_conformities = extract_non_conformities
      non_conformities.each_with_index do |item, index|
        description += "#{index + 1}. #{item}\n"
      end
      
      description += "\n**Observações:**\n"
      description += @checklist_issue.description if @checklist_issue.description.present?
      
      description
    end
    
    def extract_non_conformities
      # Extrair itens não conformes do checklist
      # Esta lógica depende da implementação específica do plugin de checklists
      conformities = []
      
      if @checklist_issue.checklists.present?
        @checklist_issue.checklists.each do |checklist_item|
          if checklist_item.is_done == false
            conformities << checklist_item.subject
          end
        end
      end
      
      conformities
    end
    
    def determine_priority
      # Determinar prioridade baseada no tipo de não conformidade
      critical_keywords = ['emergência', 'urgente', 'segurança', 'risco', 'parada']
      
      description_text = @checklist_issue.description.to_s.downcase
      
      if critical_keywords.any? { |keyword| description_text.include?(keyword) }
        IssuePriority.find_by(name: 'Alta') || IssuePriority.default
      else
        IssuePriority.find_by(name: 'Normal') || IssuePriority.default
      end
    end
    
    def find_maintenance_responsible
      # Buscar responsável pela manutenção baseado na disciplina
      disciplina = @checklist_issue.custom_field_value('disciplina')
      
      # Lógica para encontrar o responsável apropriado
      # Pode ser baseado em grupos/roles específicos
      responsible_group = Group.find_by(lastname: "Manutenção #{disciplina}")
      
      if responsible_group&.users&.active&.first
        responsible_group.users.active.first
      else
        # Fallback para administrador do projeto
        @checklist_issue.project.members.joins(:roles)
                        .where(roles: { name: 'Gerente de Manutenção' })
                        .first&.user
      end
    end
    
    def build_custom_fields
      custom_fields = {}
      
      # Copiar campos relevantes da lista de verificação
      ['codigo_ativo', 'localizacao', 'disciplina', 'fabricante', 'modelo'].each do |field_name|
        value = @checklist_issue.custom_field_value(field_name)
        custom_fields[field_name] = value if value.present?
      end
      
      # Adicionar campos específicos da OS
      custom_fields['origem_os'] = 'Lista de Verificação'
      custom_fields['status_orcamento'] = 'Pendente'
      custom_fields['tipo_manutencao'] = 'Corretiva'
      
      custom_fields
    end
    
    def link_issues(work_order)
      # Criar relação entre a lista de verificação e a OS
      IssueRelation.create!(
        issue_from: @checklist_issue,
        issue_to: work_order,
        relation_type: 'precedes'
      )
    end
    
    def notify_stakeholders(work_order)
      # Notificar stakeholders sobre a nova OS
      begin
        # Enviar email para o responsável
        if work_order.assigned_to
          Mailer.deliver_issue_add(work_order)
        end
        
        # Notificar membros do projeto com permissão adequada
        notifiable_users = work_order.project.members.joins(:roles)
                                   .where(roles: { permissions: ['manage_work_orders'] })
                                   .map(&:user)
                                   .select(&:active?)
        
        notifiable_users.each do |user|
          Mailer.deliver_issue_add(work_order) if user.mail_notification?
        end
        
      rescue => e
        Rails.logger.error "Erro ao enviar notificações para OS #{work_order.id}: #{e.message}"
      end
    end
  end
end
