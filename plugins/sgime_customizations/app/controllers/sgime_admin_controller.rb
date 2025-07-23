class SgimeAdminController < ApplicationController
  before_action :require_admin
  
  def index
    @settings = Setting.plugin_sgime_customizations || {}
    @projects_count = Project.count
    @issues_count = Issue.count
    @maintenance_issues = Issue.joins(:tracker).where(trackers: { name: ['ATIVO', 'LISTA DE VERIFICAÇÃO', 'ORDEM DE SERVIÇO'] }).count
    @document_projects = Project.joins(:enabled_modules).where(enabled_modules: { name: 'dmsf' }).count
  end
  
  def update_settings
    if request.post?
      Setting.plugin_sgime_customizations = params[:settings].permit!
      flash[:notice] = 'Configurações do SGIME atualizadas com sucesso.'
      redirect_to action: 'index'
    end
  end
  
  def system_info
    @system_info = {
      sgime_version: '1.6',
      redmine_version: Redmine::VERSION::STRING,
      ruby_version: RUBY_VERSION,
      rails_version: Rails::VERSION::STRING,
      database: ActiveRecord::Base.connection.adapter_name,
      plugins: Redmine::Plugin.all.map { |p| { name: p.name, version: p.version } }
    }
  end
  
  def maintenance_stats
    @stats = {
      total_assets: Issue.joins(:tracker).where(trackers: { name: 'ATIVO' }).count,
      pending_maintenance: Issue.joins(:tracker).where(trackers: { name: 'LISTA DE VERIFICAÇÃO' }, status_id: IssueStatus.where(is_closed: false)).count,
      open_work_orders: Issue.joins(:tracker).where(trackers: { name: 'ORDEM DE SERVIÇO' }, status_id: IssueStatus.where(is_closed: false)).count,
      non_conformities: Issue.joins(:tracker).where(trackers: { name: 'LISTA DE VERIFICAÇÃO' }).select { |i| i.custom_field_value('status_conformidade') == 'Não Conforme' }.count
    }
    
    # Estatísticas por disciplina
    @discipline_stats = {}
    CustomField.find_by(name: 'disciplina')&.possible_values&.each do |discipline|
      @discipline_stats[discipline] = Issue.joins(:tracker)
                                          .where(trackers: { name: ['ATIVO', 'LISTA DE VERIFICAÇÃO', 'ORDEM DE SERVIÇO'] })
                                          .select { |i| i.custom_field_value('disciplina') == discipline }
                                          .count
    end
  end
  
  def backup_status
    @backups = Dir.glob('backups/*.{tar.gz,sql}').map do |file|
      {
        name: File.basename(file),
        size: File.size(file),
        date: File.mtime(file),
        type: file.include?('_db_') ? 'Banco de Dados' : (file.include?('_files_') ? 'Arquivos' : 'Completo')
      }
    end.sort_by { |b| b[:date] }.reverse
  rescue
    @backups = []
  end
  
  private
  
  def require_admin
    unless User.current.admin?
      render_403
      return false
    end
  end
end
