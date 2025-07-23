module SgimeCustomizations
  # Gerador de relatórios PDF para listas de verificação
  # Customização 1 da especificação técnica
  class PdfReportGenerator
    
    def initialize(issue)
      @issue = issue
    end
    
    def generate_pdf
      return nil unless @issue.tracker.name == 'LISTA DE VERIFICAÇÃO'
      
      begin
        pdf_content = build_pdf_content
        save_pdf_file(pdf_content)
      rescue => e
        Rails.logger.error "Erro ao gerar PDF para issue #{@issue.id}: #{e.message}"
        nil
      end
    end
    
    private
    
    def build_pdf_content
      require 'prawn'
      
      Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
        # Header com identidade visual
        add_header(pdf)
        
        # Informações básicas da vistoria
        add_basic_info(pdf)
        
        # Dados do ativo
        add_asset_info(pdf)
        
        # Checklist detalhado
        add_checklist_details(pdf)
        
        # Observações e comentários
        add_observations(pdf)
        
        # Evidências fotográficas
        add_photos(pdf)
        
        # Assinaturas e responsáveis
        add_signatures(pdf)
        
        # Footer
        add_footer(pdf)
      end.render
    end
    
    def add_header(pdf)
      # Logo e cabeçalho institucional
      pdf.text_box "COLÉGIO PEDRO II", 
                   at: [0, pdf.cursor],
                   size: 16,
                   style: :bold,
                   color: '1f4788'
      
      pdf.move_down 5
      
      pdf.text "Seção de Engenharia", size: 12, color: '666666'
      pdf.text "Sistema de Gestão Integrada de Engenharia - SGIME", 
               size: 10, color: '666666'
      
      pdf.move_down 20
      
      # Título do relatório
      pdf.text "RELATÓRIO DE VISTORIA TÉCNICA", 
               size: 18, 
               style: :bold, 
               align: :center,
               color: '2c5aa0'
      
      pdf.move_down 20
      
      # Linha separadora
      pdf.stroke_horizontal_rule
      pdf.move_down 15
    end
    
    def add_basic_info(pdf)
      pdf.text "INFORMAÇÕES GERAIS", size: 14, style: :bold, color: '2c5aa0'
      pdf.move_down 10
      
      info_data = [
        ['Número da Vistoria:', @issue.id.to_s],
        ['Data de Realização:', format_date(@issue.created_on)],
        ['Responsável:', @issue.author.name],
        ['Status:', @issue.status.name],
        ['Projeto:', @issue.project.name]
      ]
      
      pdf.table(info_data, 
                cell_style: { size: 10, borders: [:bottom], 
                             border_width: 0.5, border_color: 'cccccc' },
                column_widths: [120, 350]) do |table|
        table.cells[0..4, 0].font_style = :bold
      end
      
      pdf.move_down 20
    end
    
    def add_asset_info(pdf)
      pdf.text "DADOS DO ATIVO", size: 14, style: :bold, color: '2c5aa0'
      pdf.move_down 10
      
      asset_data = [
        ['Código do Ativo:', @issue.custom_field_value('codigo_ativo') || 'N/A'],
        ['Localização:', @issue.custom_field_value('localizacao') || 'N/A'],
        ['Disciplina:', @issue.custom_field_value('disciplina') || 'N/A'],
        ['Fabricante:', @issue.custom_field_value('fabricante') || 'N/A'],
        ['Modelo:', @issue.custom_field_value('modelo') || 'N/A']
      ]
      
      pdf.table(asset_data,
                cell_style: { size: 10, borders: [:bottom],
                             border_width: 0.5, border_color: 'cccccc' },
                column_widths: [120, 350]) do |table|
        table.cells[0..4, 0].font_style = :bold
      end
      
      pdf.move_down 20
    end
    
    def add_checklist_details(pdf)
      pdf.text "ITENS VERIFICADOS", size: 14, style: :bold, color: '2c5aa0'
      pdf.move_down 10
      
      if @issue.checklists.present?
        checklist_data = [['#', 'Item', 'Status', 'Observações']]
        
        @issue.checklists.each_with_index do |item, index|
          status = item.is_done? ? 'Conforme' : 'Não Conforme'
          status_color = item.is_done? ? '00aa00' : 'dd0000'
          
          checklist_data << [
            (index + 1).to_s,
            item.subject,
            status,
            item.comment || ''
          ]
        end
        
        pdf.table(checklist_data,
                  header: true,
                  cell_style: { size: 9, padding: 5 },
                  column_widths: [30, 250, 80, 110]) do |table|
          table.row(0).font_style = :bold
          table.row(0).background_color = 'f0f0f0'
          
          # Colorir status
          (1...checklist_data.length).each do |i|
            status_cell = table.cells[i, 2]
            if checklist_data[i][2] == 'Não Conforme'
              status_cell.text_color = 'dd0000'
              status_cell.font_style = :bold
            else
              status_cell.text_color = '00aa00'
            end
          end
        end
      else
        pdf.text "Nenhum item de checklist encontrado.", size: 10, style: :italic
      end
      
      pdf.move_down 20
    end
    
    def add_observations(pdf)
      pdf.text "OBSERVAÇÕES E COMENTÁRIOS", size: 14, style: :bold, color: '2c5aa0'
      pdf.move_down 10
      
      if @issue.description.present?
        pdf.text @issue.description, size: 10, align: :justify
      else
        pdf.text "Sem observações adicionais.", size: 10, style: :italic
      end
      
      # Adicionar comentários/journals
      if @issue.journals.present?
        pdf.move_down 15
        pdf.text "Histórico de Atualizações:", size: 12, style: :bold
        pdf.move_down 5
        
        @issue.journals.each do |journal|
          next unless journal.notes.present?
          
          pdf.text "#{format_date(journal.created_on)} - #{journal.user.name}:",
                   size: 9, style: :bold
          pdf.text journal.notes, size: 9
          pdf.move_down 5
        end
      end
      
      pdf.move_down 20
    end
    
    def add_photos(pdf)
      pdf.text "EVIDÊNCIAS FOTOGRÁFICAS", size: 14, style: :bold, color: '2c5aa0'
      pdf.move_down 10
      
      image_attachments = @issue.attachments.select { |a| a.image? }
      
      if image_attachments.any?
        image_attachments.each_with_index do |attachment, index|
          begin
            if File.exist?(attachment.diskfile)
              pdf.text "Figura #{index + 1}: #{attachment.filename}", 
                       size: 10, style: :bold
              pdf.move_down 5
              
              # Adicionar imagem redimensionada
              pdf.image attachment.diskfile, 
                       width: 400, 
                       height: 300,
                       fit: [400, 300]
              
              pdf.move_down 15
            end
          rescue => e
            Rails.logger.warn "Erro ao incluir imagem #{attachment.filename}: #{e.message}"
            pdf.text "Erro ao carregar imagem: #{attachment.filename}", 
                     size: 9, style: :italic, color: 'dd0000'
            pdf.move_down 10
          end
        end
      else
        pdf.text "Nenhuma evidência fotográfica anexada.", size: 10, style: :italic
      end
      
      pdf.move_down 20
    end
    
    def add_signatures(pdf)
      pdf.text "RESPONSÁVEIS", size: 14, style: :bold, color: '2c5aa0'
      pdf.move_down 20
      
      # Área para assinaturas
      signature_data = [
        ['Vistoriador:', '_' * 40, 'Data:', '_' * 20],
        ['', @issue.author.name, '', format_date(@issue.created_on)],
        ['', '', '', ''],
        ['Responsável Técnico:', '_' * 40, 'Data:', '_' * 20],
        ['', 'Nome:', '', ''],
      ]
      
      pdf.table(signature_data,
                cell_style: { size: 10, borders: [], padding: 5 },
                column_widths: [120, 200, 50, 100]) do |table|
        table.cells[0, 0].font_style = :bold
        table.cells[3, 0].font_style = :bold
        table.cells[0, 2].font_style = :bold
        table.cells[3, 2].font_style = :bold
      end
    end
    
    def add_footer(pdf)
      pdf.repeat(:all) do
        pdf.draw_text "SGIME v1.6 - Colégio Pedro II - Seção de Engenharia", 
                      at: [0, 0], size: 8, color: '666666'
        
        pdf.draw_text "Página #{pdf.page_number}", 
                      at: [pdf.bounds.right - 60, 0], size: 8, color: '666666'
      end
    end
    
    def save_pdf_file(pdf_content)
      filename = "relatorio_vistoria_#{@issue.id}_#{Date.current.strftime('%Y%m%d')}.pdf"
      
      # Salvar como anexo da issue
      attachment = Attachment.new(
        container: @issue,
        file: StringIO.new(pdf_content),
        filename: filename,
        author: User.current || @issue.author,
        content_type: 'application/pdf'
      )
      
      if attachment.save
        Rails.logger.info "PDF gerado com sucesso para issue #{@issue.id}: #{filename}"
        attachment
      else
        Rails.logger.error "Erro ao salvar PDF para issue #{@issue.id}: #{attachment.errors.full_messages}"
        nil
      end
    end
    
    def format_date(date)
      return 'N/A' unless date
      date.strftime('%d/%m/%Y às %H:%M')
    end
  end
end
