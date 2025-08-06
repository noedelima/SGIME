#!/bin/bash
#
# SGIME - Plugin Generator para Tarefas Recorrentes
# Gera um plugin minimalista focado nas necessidades do SGIME
#

set -e

PLUGIN_NAME="sgime_recurring_maintenance"
PLUGIN_DIR="/home/noedelima/source/SGIME/plugins/$PLUGIN_NAME"

echo "🔧 Criando plugin minimalista SGIME Recurring Maintenance..."

# Criar estrutura do plugin
mkdir -p "$PLUGIN_DIR"/{app/{controllers,models,views,helpers},config,lib,assets/{javascripts,stylesheets}}

# Arquivo init.rb
cat > "$PLUGIN_DIR/init.rb" << 'EOF'
require 'redmine'

Redmine::Plugin.register :sgime_recurring_maintenance do
  name 'SGIME - Manutenção Recorrente'
  author 'Equipe SGIME - Colégio Pedro II'
  description 'Plugin simplificado para manutenção recorrente no SGIME conforme ABNT NBR-5674'
  version '1.0.0'
  
  settings :default => {
    'enabled' => '1',
    'default_assignee' => nil,
    'auto_create_os' => '1'
  }, :partial => 'settings/sgime_recurring_maintenance'
  
  project_module :issue_tracking do
    permission :manage_recurring_maintenance, {:sgime_maintenance => [:index, :new, :create, :edit, :update, :destroy]}
  end
  
  menu :project_menu, :sgime_maintenance,
    { :controller => 'sgime_maintenance', :action => 'index' },
    :caption => 'Manutenção Recorrente',
    :after => :issues,
    :param => :project_id
end
EOF

# Modelo simplificado
cat > "$PLUGIN_DIR/app/models/sgime_maintenance_schedule.rb" << 'EOF'
class SgimeMaintenanceSchedule < ActiveRecord::Base
  self.table_name = 'sgime_maintenance_schedules'
  
  belongs_to :project
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  
  validates :project_id, :presence => true
  validates :title, :presence => true
  validates :interval_days, :presence => true, :numericality => { :greater_than => 0 }
  validates :tracker_id, :presence => true
  
  scope :active, -> { where(:active => true) }
  
  def next_due_date
    if last_created_on.present?
      last_created_on + interval_days.days
    else
      Date.current
    end
  end
  
  def self.create_due_tasks
    active.find_each do |schedule|
      if schedule.next_due_date <= Date.current
        schedule.create_maintenance_issue!
      end
    end
  end
  
  def create_maintenance_issue!
    issue = Issue.new(
      project: project,
      tracker_id: tracker_id,
      subject: "#{title} - #{Date.current.strftime('%d/%m/%Y')}",
      description: description || "Tarefa de manutenção criada automaticamente",
      assigned_to: assigned_to,
      author_id: User.current.try(:id) || User.active.first.id,
      priority_id: Enumeration.default_priority.try(:id),
      status_id: IssueStatus.default.try(:id)
    )
    
    if issue.save
      update_column(:last_created_on, Date.current)
      Rails.logger.info "SGIME: Tarefa de manutenção criada - Issue ##{issue.id}"
    else
      Rails.logger.error "SGIME: Erro ao criar tarefa - #{issue.errors.full_messages.join(', ')}"
    end
    
    issue
  end
end
EOF

# Controlador
cat > "$PLUGIN_DIR/app/controllers/sgime_maintenance_controller.rb" << 'EOF'
class SgimeMaintenanceController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize
  before_action :find_schedule, only: [:show, :edit, :update, :destroy]
  
  def index
    @schedules = @project.sgime_maintenance_schedules.includes(:assigned_to)
  end
  
  def new
    @schedule = @project.sgime_maintenance_schedules.build
  end
  
  def create
    @schedule = @project.sgime_maintenance_schedules.build(schedule_params)
    
    if @schedule.save
      flash[:notice] = 'Agendamento de manutenção criado com sucesso'
      redirect_to project_sgime_maintenance_index_path(@project)
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @schedule.update(schedule_params)
      flash[:notice] = 'Agendamento atualizado com sucesso'
      redirect_to project_sgime_maintenance_index_path(@project)
    else
      render :edit
    end
  end
  
  def destroy
    @schedule.destroy
    flash[:notice] = 'Agendamento removido'
    redirect_to project_sgime_maintenance_index_path(@project)
  end
  
  private
  
  def find_schedule
    @schedule = @project.sgime_maintenance_schedules.find(params[:id])
  end
  
  def schedule_params
    params.require(:sgime_maintenance_schedule).permit(
      :title, :description, :interval_days, :tracker_id, :assigned_to_id, :active
    )
  end
end
EOF

# Migração
cat > "$PLUGIN_DIR/config/routes.rb" << 'EOF'
resources :projects do
  resources :sgime_maintenance, except: [:show]
end
EOF

echo "✅ Plugin minimalista criado em: $PLUGIN_DIR"
echo "📋 Próximos passos:"
echo "   1. Criar migração para tabela sgime_maintenance_schedules"
echo "   2. Criar views do controlador"
echo "   3. Configurar cron job para executar SgimeMaintenanceSchedule.create_due_tasks"
