require 'redmine'

Redmine::Plugin.register :recurring_tasks do
  name 'SGIME - Tarefas Recorrentes'
  author 'SGIME Team (baseado em Teresa N.)'
  author_url 'https://github.com/noedelima/SGIME'
  url 'https://github.com/noedelima/SGIME'
  description 'Permite configurar tarefas para recorrer em cronograma regular para manutenção predial conforme ABNT NBR-5674. Versão customizada para SGIME v1.6'
  version '2.0.0-sgime'
  
  # user-accessible global configuration
  settings :default => {
    'show_top_menu' => "1",
    'reopen_issue' => "0",
    'journal_attributed_to_user' => 1
  }, :partial => 'settings/recurring_tasks_settings'

  
  Redmine::MenuManager.map :top_menu do |menu|
    menu.push :recurring_tasks, { :controller => 'recurring_tasks', :action => 'index' }, :caption => :label_recurring_tasks, :if => Proc.new { User.current.admin? && (Setting.plugin_recurring_tasks['show_top_menu'] == "1")}
  end
  
  # Permissions map to issue permissions (#12)
  # Modeled after #{redmine root}/lib/redmine.rb permissions setup
  project_module :issue_tracking do
    permission :view_issue_recurrence,   {:recurring_tasks => [:index, :show]}, :read => true
    permission :add_issue_recurrence,    {:recurring_tasks => [:new, :create]}
    permission :edit_issue_recurrence,   {:recurring_tasks => [:edit, :update]}
    permission :delete_issue_recurrence, {:recurring_tasks => [:destroy]}, :require => :member
  end
  
  # project-specific recurring tasks view (#11)
  menu :project_menu, :recurring_tasks, { :controller => 'recurring_tasks', :action => 'index' }, :caption => :label_recurring_tasks, :after => :new_issue, :param => :project_id
  
  # Send patches to models and controllers - Rails 7 compatible way
  Rails.application.config.to_prepare do
    begin
      # Load patches only if not already loaded
      unless defined?(IssuesPatch)
        require_relative 'lib/issues_patch'
      end
      unless defined?(RecurringTasks::Hooks)
        require_relative 'lib/recurring_tasks/hooks'
      end
      
      # Apply patch safely
      unless Issue.included_modules.include?(IssuesPatch)
        Issue.send(:include, IssuesPatch)
      end
    rescue LoadError => e
      Rails.logger.warn "RecurringTasks plugin: Could not load patches - #{e.message}"
    rescue => e
      Rails.logger.error "RecurringTasks plugin: Error loading - #{e.message}"
    end
  end
end