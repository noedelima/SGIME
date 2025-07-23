-- Script de inicialização do PostgreSQL para SGIME
-- Sistema de Gestão Integrada de Engenharia
-- Colégio Pedro II - Seção de Engenharia

-- Criar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Configurar locale brasileiro
SET lc_messages TO 'pt_BR.UTF-8';
SET lc_monetary TO 'pt_BR.UTF-8';
SET lc_numeric TO 'pt_BR.UTF-8';
SET lc_time TO 'pt_BR.UTF-8';

-- Comentário do banco
COMMENT ON DATABASE sgime_production IS 'SGIME - Sistema de Gestão Integrada de Engenharia - Colégio Pedro II';
