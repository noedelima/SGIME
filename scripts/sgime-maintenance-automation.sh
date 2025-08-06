#!/bin/bash
#
# SGIME - Sistema de Automação de Manutenção
# Script para criação automática de tarefas de manutenção recorrentes
# Conforme ABNT NBR-5674
#
# Versão: 1.0.0
# Autor: Equipe SGIME - Colégio Pedro II

set -e

# Configurações
REDMINE_ROOT="/usr/src/redmine"
SGIME_CONFIG="/opt/sgime/config"
LOG_FILE="/opt/sgime/logs/maintenance_automation.log"

# Função de logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Função para verificar dependências
check_dependencies() {
    log "Verificando dependências do sistema..."
    
    # Verificar se Redmine está rodando
    if ! docker compose ps redmine | grep -q "Up"; then
        log "ERRO: Container Redmine não está rodando"
        exit 1
    fi
    
    # Verificar se base de dados está acessível
    if ! docker compose exec -T postgres pg_isready > /dev/null 2>&1; then
        log "ERRO: Base de dados PostgreSQL não está acessível"
        exit 1
    fi
    
    log "✅ Dependências verificadas com sucesso"
}

# Função para criar tarefas de manutenção preventiva
create_maintenance_tasks() {
    local maintenance_type="$1"
    local interval_days="$2"
    local project_id="$3"
    
    log "Criando tarefas de manutenção: $maintenance_type (intervalo: $interval_days dias)"
    
    # SQL para inserir nova issue de manutenção
    local sql="
    INSERT INTO issues (
        project_id, 
        tracker_id, 
        subject, 
        description, 
        status_id, 
        assigned_to_id,
        priority_id,
        author_id,
        created_on,
        updated_on,
        due_date
    ) VALUES (
        $project_id,
        (SELECT id FROM trackers WHERE name = 'Manutenção' LIMIT 1),
        'Manutenção $maintenance_type - ' || to_char(CURRENT_DATE + INTERVAL '$interval_days days', 'DD/MM/YYYY'),
        'Tarefa de manutenção $maintenance_type criada automaticamente pelo sistema SGIME conforme cronograma de manutenção preventiva (ABNT NBR-5674).',
        (SELECT id FROM issue_statuses WHERE name = 'Nova' LIMIT 1),
        (SELECT id FROM users WHERE login = 'manutencao' LIMIT 1),
        (SELECT id FROM enumerations WHERE name = 'Normal' AND type = 'IssuePriority' LIMIT 1),
        (SELECT id FROM users WHERE admin = true LIMIT 1),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        CURRENT_DATE + INTERVAL '$interval_days days'
    );"
    
    # Executar SQL no container PostgreSQL
    docker compose exec -T postgres psql -U "${POSTGRES_USER:-sgime_user}" -d "${POSTGRES_DB:-sgime_production}" -c "$sql"
    
    if [ $? -eq 0 ]; then
        log "✅ Tarefa de manutenção $maintenance_type criada com sucesso"
    else
        log "❌ Erro ao criar tarefa de manutenção $maintenance_type"
    fi
}

# Função para processar checklists com falhas
process_failed_checklists() {
    log "Processando checklists com falhas para geração de OS..."
    
    # Buscar checklists com itens marcados como "Não" nas últimas 24h
    local sql="
    SELECT DISTINCT 
        cl.issue_id,
        i.subject,
        i.project_id,
        string_agg(cli.subject, '; ') as failed_items
    FROM checklist_items cli
    JOIN checklists cl ON cli.checklist_id = cl.id  
    JOIN issues i ON cl.issue_id = i.id
    WHERE cli.is_done = false 
      AND cli.updated_on >= CURRENT_DATE - INTERVAL '1 day'
    GROUP BY cl.issue_id, i.subject, i.project_id
    HAVING COUNT(cli.id) > 0;"
    
    # Executar consulta e processar resultados
    docker compose exec -T postgres psql -U "${POSTGRES_USER:-sgime_user}" -d "${POSTGRES_DB:-sgime_production}" -t -c "$sql" | while IFS='|' read -r issue_id subject project_id failed_items; do
        if [ -n "$issue_id" ]; then
            # Remover espaços em branco
            issue_id=$(echo "$issue_id" | xargs)
            subject=$(echo "$subject" | xargs)
            project_id=$(echo "$project_id" | xargs)
            failed_items=$(echo "$failed_items" | xargs)
            
            log "Gerando OS para checklist com falhas - Issue: $issue_id, Itens: $failed_items"
            
            # Criar OS automática
            create_work_order "$issue_id" "$subject" "$project_id" "$failed_items"
        fi
    done
}

# Função para criar Ordem de Serviço (OS)
create_work_order() {
    local source_issue_id="$1"
    local source_subject="$2"
    local project_id="$3"
    local failed_items="$4"
    
    local os_sql="
    INSERT INTO issues (
        project_id, 
        tracker_id, 
        subject, 
        description, 
        status_id, 
        assigned_to_id,
        priority_id,
        author_id,
        created_on,
        updated_on,
        due_date
    ) VALUES (
        $project_id,
        (SELECT id FROM trackers WHERE name = 'Ordem de Serviço' LIMIT 1),
        'OS - Não conformidades detectadas em: $source_subject',
        'Ordem de Serviço gerada automaticamente devido a não conformidades detectadas no checklist da tarefa #$source_issue_id.\n\nItens com falha:\n$failed_items\n\nConforme ABNT NBR-5674, esta OS deve ser analisada e executada pela equipe de manutenção.',
        (SELECT id FROM issue_statuses WHERE name = 'Nova' LIMIT 1),
        (SELECT id FROM users WHERE login = 'planejamento_manutencao' LIMIT 1),
        (SELECT id FROM enumerations WHERE name = 'Alta' AND type = 'IssuePriority' LIMIT 1),
        (SELECT id FROM users WHERE admin = true LIMIT 1),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        CURRENT_DATE + INTERVAL '7 days'
    );"
    
    docker compose exec -T postgres psql -U "${POSTGRES_USER:-sgime_user}" -d "${POSTGRES_DB:-sgime_production}" -c "$os_sql"
    
    if [ $? -eq 0 ]; then
        log "✅ OS criada automaticamente para Issue #$source_issue_id"
    else
        log "❌ Erro ao criar OS para Issue #$source_issue_id"
    fi
}

# Função principal
main() {
    log "=== INÍCIO: Automação de Manutenção SGIME ==="
    
    check_dependencies
    
    # Processar checklists com falhas
    process_failed_checklists
    
    # Verificar se é dia de criar tarefas de manutenção preventiva
    day_of_week=$(date +%u)  # 1=Segunda, 7=Domingo
    
    case $day_of_week in
        1)  # Segunda-feira: Manutenção semanal
            create_maintenance_tasks "Preventiva Semanal" 7 1
            ;;
        15) # Dia 15: Manutenção quinzenal (aproximação)
            create_maintenance_tasks "Preventiva Quinzenal" 15 1
            ;;
        1)  # Primeiro dia do mês: Manutenção mensal
            if [ $(date +%d) -eq 1 ]; then
                create_maintenance_tasks "Preventiva Mensal" 30 1
            fi
            ;;
    esac
    
    log "=== FIM: Automação de Manutenção SGIME ==="
}

# Executar função principal
main "$@"
