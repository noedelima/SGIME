module SgimeChecklistPatch
	def self.included(base)
		base.class_eval do
			# Gera/atualiza OS automaticamente quando um item de checklist é criado/atualizado
			after_commit :sgime_generate_os_after_save, on: [:create, :update]

			private
			def sgime_generate_os_after_save
				begin
					if respond_to?(:issue) && issue.present?
						SgimeWorkOrderGenerator.generate_for_issue(issue, triggered_by: 'checklist')
					end
				rescue => e
					Rails.logger.error("[SGIME] Falha ao gerar OS automática: #{e.class}: #{e.message}\n#{e.backtrace&.take(5)&.join("\n")}")
				end
			end
		end
	end
end

