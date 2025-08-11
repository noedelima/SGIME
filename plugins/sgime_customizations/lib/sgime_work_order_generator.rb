class SgimeWorkOrderGenerator
	# Contrato:
	# - generate_for_issue(issue, triggered_by: 'checklist')
	#   Cria/atualiza uma OS quando houver itens de checklist não conformes.
	#   Registra journal no issue de origem e relaciona as issues.

	def self.generate_for_issue(issue, triggered_by: nil)
		return unless issue.is_a?(Issue)

		# Regras: somente se houver checklist e algum item não concluído marcado como não conforme
		failed_items = fetch_failed_checklist_items(issue)
		return if failed_items.empty?

		tracker = find_os_tracker(issue.project)
		return unless tracker

		author = User.anonymous # fallback; idealmente um usuário de sistema

		subject = "OS automática para ##{issue.id} - #{issue.subject}"
		description = <<~DESC
			Ordem de Serviço gerada automaticamente devido a não conformidades detectadas no checklist da tarefa ##{issue.id}.

			Itens com falha:
			#{failed_items.map { |c| "- #{c.subject}" }.join("\n")}

			Origem: #{triggered_by || 'automação'}
		DESC

		# Tenta localizar uma OS existente relacionada para evitar duplicação
		existing = Issue.where(project_id: issue.project_id, tracker_id: tracker.id)
										.where("subject LIKE ?", "%OS automática para ##{issue.id}%").first

		if existing
			existing.init_journal(author, "Atualização automática de OS com novos itens de falha.")
			existing.description = description
			existing.save(validate: false)
			relate(existing, issue)
			return existing
		end

		os = Issue.new(project: issue.project, tracker: tracker)
		os.subject = subject
		os.description = description
		os.author = author if os.respond_to?(:author=)

		# Herdar prioridade e responsável quando houver
		os.priority = issue.priority if os.respond_to?(:priority=) && issue.respond_to?(:priority)
		os.assigned_to = issue.assigned_to if os.respond_to?(:assigned_to=)

		# Estado inicial: usar o primeiro status padrão
		os.status = IssueStatus.default if os.respond_to?(:status=)

		os.save(validate: false)
		relate(os, issue)
		os
	rescue => e
		Rails.logger.error("[SGIME] Erro em SgimeWorkOrderGenerator.generate_for_issue: #{e.class}: #{e.message}")
		nil
	end

	def self.fetch_failed_checklist_items(issue)
		return [] unless issue.respond_to?(:checklists)
		# Regra: itens não concluídos são considerados não conformes quando o issue está em estados de conclusão ou ao marcar algo como feito/não feito.
		issue.checklists.select { |c| !c.is_section && !c.is_done }
	end
	private_class_method :fetch_failed_checklist_items

	def self.find_os_tracker(project)
		return nil unless project
		Tracker.where("LOWER(name) IN (?)", ["ordem de serviço", "ordem de servico", "os"]).first
	end
	private_class_method :find_os_tracker

	def self.relate(os_issue, source_issue)
		return unless os_issue && source_issue
		return unless os_issue.persisted? && source_issue.persisted?
		# Cria relação se não existir
		unless IssueRelation.where(issue_from_id: os_issue.id, issue_to_id: source_issue.id).exists? ||
					 IssueRelation.where(issue_from_id: source_issue.id, issue_to_id: os_issue.id).exists?
			IssueRelation.create(issue_from: os_issue, issue_to: source_issue, relation_type: IssueRelation::TYPE_RELATES)
		end
	end
	private_class_method :relate
end

