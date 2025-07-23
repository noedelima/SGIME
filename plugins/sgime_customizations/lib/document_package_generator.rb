module SgimeCustomizations
  # Gerador de pacotes de documentos para download
  # Customização 3 da especificação técnica
  class DocumentPackageGenerator
    
    def initialize(project)
      @project = project
    end
    
    def generate_package(folder_path = nil)
      begin
        temp_dir = create_temp_directory
        
        if folder_path
          # Empacotar pasta específica
          copy_folder_documents(folder_path, temp_dir)
        else
          # Empacotar todos os documentos do projeto
          copy_all_documents(temp_dir)
        end
        
        zip_file = create_zip_file(temp_dir)
        cleanup_temp_directory(temp_dir)
        
        zip_file
      rescue => e
        Rails.logger.error "Erro ao gerar pacote de documentos: #{e.message}"
        nil
      end
    end
    
    private
    
    def create_temp_directory
      temp_dir = File.join(Rails.root, 'tmp', 'document_packages', 
                          "#{@project.identifier}_#{Time.current.to_i}")
      FileUtils.mkdir_p(temp_dir)
      temp_dir
    end
    
    def copy_folder_documents(folder_path, temp_dir)
      # Esta lógica depende da implementação específica do DMSF
      if defined?(Dmsf) && @project.module_enabled?('dmsf')
        copy_dmsf_folder(folder_path, temp_dir)
      else
        copy_regular_attachments(temp_dir)
      end
    end
    
    def copy_all_documents(temp_dir)
      # Copiar todos os documentos do projeto
      if defined?(Dmsf) && @project.module_enabled?('dmsf')
        copy_all_dmsf_files(temp_dir)
      else
        copy_regular_attachments(temp_dir)
      end
    end
    
    def copy_dmsf_folder(folder_path, temp_dir)
      # Implementação específica para DMSF
      folder = DmsfFolder.find_by(project: @project, title: folder_path)
      return unless folder
      
      # Criar estrutura de diretórios
      folder_temp_path = File.join(temp_dir, sanitize_filename(folder.title))
      FileUtils.mkdir_p(folder_temp_path)
      
      # Copiar arquivos da pasta
      folder.dmsf_files.each do |dmsf_file|
        copy_dmsf_file(dmsf_file, folder_temp_path)
      end
      
      # Copiar subpastas recursivamente
      folder.dmsf_folders.each do |subfolder|
        copy_dmsf_subfolder(subfolder, folder_temp_path)
      end
    end
    
    def copy_all_dmsf_files(temp_dir)
      # Copiar todos os arquivos DMSF do projeto
      @project.dmsf_folders.each do |folder|
        copy_dmsf_folder_recursive(folder, temp_dir)
      end
      
      # Copiar arquivos na raiz
      @project.dmsf_files.each do |dmsf_file|
        copy_dmsf_file(dmsf_file, temp_dir)
      end
    end
    
    def copy_dmsf_folder_recursive(folder, parent_path)
      folder_path = File.join(parent_path, sanitize_filename(folder.title))
      FileUtils.mkdir_p(folder_path)
      
      # Copiar arquivos da pasta
      folder.dmsf_files.each do |dmsf_file|
        copy_dmsf_file(dmsf_file, folder_path)
      end
      
      # Copiar subpastas
      folder.dmsf_folders.each do |subfolder|
        copy_dmsf_folder_recursive(subfolder, folder_path)
      end
    end
    
    def copy_dmsf_file(dmsf_file, destination_path)
      return unless dmsf_file.last_revision
      
      source_file = dmsf_file.last_revision.disk_file
      return unless File.exist?(source_file)
      
      # Criar nome do arquivo com informações de versão
      filename = build_versioned_filename(dmsf_file)
      destination_file = File.join(destination_path, filename)
      
      # Copiar arquivo
      FileUtils.cp(source_file, destination_file)
      
      # Criar arquivo de metadados
      create_metadata_file(dmsf_file, destination_path)
    end
    
    def copy_regular_attachments(temp_dir)
      # Fallback para anexos regulares do Redmine
      @project.issues.each do |issue|
        next unless issue.attachments.any?
        
        issue_dir = File.join(temp_dir, "issue_#{issue.id}")
        FileUtils.mkdir_p(issue_dir)
        
        issue.attachments.each do |attachment|
          next unless File.exist?(attachment.diskfile)
          
          destination_file = File.join(issue_dir, attachment.filename)
          FileUtils.cp(attachment.diskfile, destination_file)
        end
      end
    end
    
    def build_versioned_filename(dmsf_file)
      base_name = File.basename(dmsf_file.name, File.extname(dmsf_file.name))
      extension = File.extname(dmsf_file.name)
      version = dmsf_file.last_revision.major_version
      revision = dmsf_file.last_revision.minor_version
      
      if revision > 0
        "#{base_name}_v#{version}.#{revision}#{extension}"
      else
        "#{base_name}_v#{version}#{extension}"
      end
    end
    
    def create_metadata_file(dmsf_file, destination_path)
      metadata = {
        nome_original: dmsf_file.name,
        versao: "#{dmsf_file.last_revision.major_version}.#{dmsf_file.last_revision.minor_version}",
        autor: dmsf_file.last_revision.user.name,
        data_criacao: dmsf_file.created_at.strftime('%d/%m/%Y %H:%M'),
        data_ultima_modificacao: dmsf_file.last_revision.updated_at.strftime('%d/%m/%Y %H:%M'),
        tamanho: number_to_human_size(dmsf_file.last_revision.size),
        descricao: dmsf_file.description || 'Sem descrição',
        status: dmsf_file.deleted? ? 'Deletado' : 'Ativo'
      }
      
      metadata_file = File.join(destination_path, "#{File.basename(dmsf_file.name, '.*')}_metadata.txt")
      
      File.open(metadata_file, 'w') do |f|
        f.write("=== METADADOS DO DOCUMENTO ===\n\n")
        metadata.each do |key, value|
          f.write("#{key.to_s.humanize}: #{value}\n")
        end
        f.write("\n--- Gerado pelo SGIME v1.6 ---\n")
        f.write("Data de geração: #{Time.current.strftime('%d/%m/%Y %H:%M')}\n")
        f.write("Projeto: #{@project.name}\n")
      end
    end
    
    def create_zip_file(temp_dir)
      zip_filename = "#{@project.identifier}_documentos_#{Time.current.strftime('%Y%m%d_%H%M%S')}.zip"
      zip_path = File.join(Rails.root, 'tmp', zip_filename)
      
      require 'zip'
      
      Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
        Dir.glob("#{temp_dir}/**/*").each do |file|
          next if File.directory?(file)
          
          # Caminho relativo dentro do ZIP
          relative_path = file.sub("#{temp_dir}/", '')
          zipfile.add(relative_path, file)
        end
        
        # Adicionar arquivo README
        readme_content = build_package_readme
        zipfile.get_output_stream('LEIA-ME.txt') { |f| f.write(readme_content) }
      end
      
      {
        path: zip_path,
        filename: zip_filename,
        size: File.size(zip_path)
      }
    end
    
    def build_package_readme
      readme = "PACOTE DE DOCUMENTOS - SGIME\n"
      readme += "=" * 50 + "\n\n"
      readme += "Projeto: #{@project.name}\n"
      readme += "Data de geração: #{Time.current.strftime('%d/%m/%Y às %H:%M')}\n"
      readme += "Gerado por: #{User.current&.name || 'Sistema'}\n"
      readme += "Sistema: SGIME v1.6 - Colégio Pedro II\n\n"
      
      readme += "CONTEÚDO DO PACOTE:\n"
      readme += "-" * 20 + "\n\n"
      
      if defined?(Dmsf) && @project.module_enabled?('dmsf')
        readme += "Este pacote contém os documentos organizados conforme a estrutura\n"
        readme += "do Sistema de Gestão de Documentos (DMSF) do projeto.\n\n"
        readme += "ESTRUTURA:\n"
        readme += "- Cada pasta corresponde a uma pasta no sistema\n"
        readme += "- Arquivos incluem número da versão no nome\n"
        readme += "- Arquivos _metadata.txt contêm informações detalhadas\n\n"
      else
        readme += "Este pacote contém os anexos de documentos organizados por\n"
        readme += "número da tarefa/issue do projeto.\n\n"
      end
      
      readme += "OBSERVAÇÕES IMPORTANTES:\n"
      readme += "- Mantenha a estrutura de pastas para referência\n"
      readme += "- Arquivos de metadados contêm informações de versionamento\n"
      readme += "- Em caso de dúvidas, consulte o sistema SGIME\n\n"
      
      readme += "CONTATO:\n"
      readme += "Seção de Engenharia - Colégio Pedro II\n"
      readme += "E-mail: geeng@cp2.g12.br\n"
      readme += "Sistema: https://sgime.cp2.g12.br\n\n"
      
      readme += "---\n"
      readme += "Documento gerado automaticamente pelo SGIME\n"
      readme += "Não edite este arquivo.\n"
      
      readme
    end
    
    def cleanup_temp_directory(temp_dir)
      FileUtils.rm_rf(temp_dir) if Dir.exist?(temp_dir)
    end
    
    def sanitize_filename(filename)
      # Remover/substituir caracteres problemáticos em nomes de arquivo
      filename.gsub(/[^\w\s\-.]/, '_').gsub(/\s+/, '_')
    end
    
    def number_to_human_size(size)
      return '0 B' if size == 0
      
      units = ['B', 'KB', 'MB', 'GB', 'TB']
      unit_index = 0
      size = size.to_f
      
      while size >= 1024 && unit_index < units.length - 1
        size /= 1024
        unit_index += 1
      end
      
      "#{size.round(2)} #{units[unit_index]}"
    end
  end
end
