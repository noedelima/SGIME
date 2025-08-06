# Guia de Início Rápido - SGIME

## Sistema de Gestão Integrada de Engenharia
**Colégio Pedro II - Seção de Engenharia**  
**Versão:** 1.6  
**Data:** Julho de 2025  
**Licença:** GPLv3

---

## 🚀 Instalação em 5 Minutos

### Pré-requisitos
- **Sistema Operacional:** Ubuntu 20.04+ ou Fedora 35+
- **Docker:** 24.0+ instalado
- **Docker Compose:** 2.0+ instalado
- **RAM:** Mínimo 4GB (Recomendado: 8GB)
- **Disco:** Mínimo 10GB livres
- **Rede:** Acesso à internet para download das imagens

### Instalação Automática

```bash
# 1. Clone ou baixe o projeto SGIME
git clone https://github.com/noedelima/SGIME.git
cd SGIME

# 2. Execute o script de setup automático
./setup.sh

# 3. Aguarde a instalação (5-10 minutos)
# O script irá:
# - Verificar pré-requisitos
# - Configurar variáveis de ambiente
# - Baixar e construir as imagens Docker
# - Inicializar o banco de dados
# - Configurar plugins essenciais
# - Configurar dados iniciais
```

### Primeiro Acesso

1. **Abra o navegador:** http://localhost ou https://localhost
2. **Usuário:** admin
3. **Senha:** admin123
4. **⚠️ IMPORTANTE:** Altere a senha imediatamente!

---

## 📋 Comandos Essenciais

```bash
# Ver status dos serviços
./scripts/manage.sh status

# Iniciar todos os serviços
./scripts/manage.sh start

# Parar todos os serviços  
./scripts/manage.sh stop

# Reiniciar todos os serviços
./scripts/manage.sh restart

# Ver logs em tempo real
./scripts/manage.sh logs

# Fazer backup completo
./scripts/manage.sh backup

# Verificar saúde do sistema
./verificar-sistema.sh
```

---

## ⚙️ Configuração Inicial Básica

### 1. Alterar Senha do Administrador
1. Login como `admin`
2. Canto superior direito → **Minha conta**
3. **Alterar senha**

### 2. Configurar Informações Gerais
1. **Administração** → **Configurações** → **Geral**
2. Definir:
   - Nome da aplicação: "SGIME - Colégio Pedro II"
   - Idioma padrão: Português (Brasil)
   - Formato de data e hora
   - Timezone: America/Sao_Paulo

### 3. Configurar Email (Opcional)
1. **Administração** → **Configurações** → **Notificações por e-mail**
2. Configurar servidor SMTP
3. Testar envio de email

### 4. Criar Primeiro Projeto
1. **Projetos** → **Novo projeto**
2. Nome: "Projeto Piloto"
3. Identificador: "projeto-piloto"
4. Habilitar módulos necessários

---

## 👥 Gerenciamento de Usuários

### Criar Usuários Locais
1. **Administração** → **Usuários** → **Novo usuário**
2. Preencher dados básicos
3. Definir permissões e grupos

### Configurar LDAP (Opcional)
1. **Administração** → **Autenticação LDAP**
2. **Novo modo de autenticação**
3. Configurar parâmetros do Active Directory:
   - Host: `ldap.cp2.g12.br`
   - Porta: `389`
   - Base DN: `DC=cp2,DC=g12,DC=br`

### Configurar SSO Azure (Opcional)
1. Verificar se plugin está ativo
2. **Administração** → **Plugins** → **OmniAuth Azure**
3. Configurar Client ID, Secret e Tenant ID

---

## 🔧 Configurações Específicas do SGIME

### Módulo de Manutenção

#### 1. Criar Hierarquia de Locais
```
SGIME (Projeto Principal)
├── Campus São Cristóvão
│   ├── Edifício Principal
│   │   ├── Bloco A
│   │   └── Bloco B
│   └── Ginásio
└── Campus Tijuca
    ├── Prédio 1
    └── Prédio 2
```

#### 2. Configurar Disciplinas Técnicas
1. **Administração** → **Campos personalizados**
2. Criar lista "Disciplinas":
   - Elétrica
   - Hidráulica
   - Ar Condicionado
   - Elevadores
   - Civil
   - Jardinagem

#### 3. Configurar Tipos de Tarefas
1. **Administração** → **Tipos de tarefa**
2. Criar tipos:
   - ATIVO
   - LISTA DE VERIFICAÇÃO  
   - ORDEM DE SERVIÇO
   - SOLICITAÇÃO DE MANUTENÇÃO

#### 4. Criar Modelo de Checklist
1. Criar nova tarefa tipo "LISTA DE VERIFICAÇÃO"
2. Usar plugin **Checklists** para criar itens
3. Exemplo para Ar Condicionado:
   - [ ] Verificar filtros
   - [ ] Testar controle remoto
   - [ ] Verificar vazamentos
   - [ ] Medir temperatura

### Módulo de Documentos

#### 1. Estrutura de Projetos
```
Projetos de Engenharia
├── Projeto Reforma Biblioteca
├── Projeto Nova Quadra
└── Projeto Sistema Elétrico
```

#### 2. Configurar Plugin DMSF
1. **Administração** → **Plugins** → **DMSF**
2. Habilitar em projetos necessários
3. Configurar aprovações de documentos

---

## 📊 Dashboards e Relatórios

### Configurar Dashboard Principal
1. **Minha página**
2. **Personalizar esta página**
3. Adicionar blocos:
   - Tarefas atribuídas a mim
   - Últimas notícias
   - Calendário
   - Issues por tipo

### Relatórios Básicos
- **Projetos** → **Issues** → **Resumo**
- Filtrar por disciplina, local, responsável
- Exportar para PDF/CSV

---

## 🛡️ Segurança e Backup

### Configurar Backup Automático
O sistema já está configurado para:
- **Backup do banco:** Diário às 02:00
- **Backup de arquivos:** Semanal aos domingos
- **Retenção:** 30 dias

Para verificar:
```bash
# Ver últimos backups
ls -la backups/

# Testar backup manual
./scripts/manage.sh backup
```

### Configurar SSL em Produção
1. Obter certificado válido (Let's Encrypt recomendado)
2. Substituir certificados em `config/nginx/ssl/`
3. Reiniciar Nginx: `docker-compose restart nginx`

---

## 🆘 Resolução de Problemas Rápidos

### Sistema não inicia
```bash
# Verificar status
./scripts/manage.sh status

# Ver logs de erro
./scripts/manage.sh logs

# Reiniciar tudo
./scripts/manage.sh restart
```

### Página não carrega
```bash
# Verificar conectividade
curl -I http://localhost

# Verificar certificados SSL
curl -I -k https://localhost

# Testar sem proxy
curl -I http://localhost:3000
```

### Banco de dados com problema
```bash
# Verificar logs do PostgreSQL
docker-compose logs postgres

# Testar conexão
docker-compose exec postgres pg_isready -U sgime_user

# Reconstruir se necessário
docker-compose stop postgres
docker volume rm sgime_postgres_data
docker-compose up -d postgres
```

### Performance lenta
```bash
# Verificar recursos
docker stats

# Limpar cache Redis
docker-compose exec redis redis-cli -a senha_redis FLUSHALL

# Otimizar banco
docker-compose exec postgres psql -U sgime_user -d sgime_production -c "VACUUM ANALYZE;"
```

---

## 📞 Suporte e Ajuda

### Documentação Completa
- **Manual do Usuário:** `docs/manual-usuario.md`
- **Guia do Administrador:** `docs/guia-administrador.md`
- **API e Integrações:** `docs/api-integracoes.md`
- **Troubleshooting:** `docs/troubleshooting.md`

### Contatos
- **Email:** geeng@cp2.g12.br
- **Telefone:** (21) 2569-1234 (Ramal: 5678)
- **Horário:** Segunda a Sexta, 8h às 18h

### Recursos Online
- **Redmine Oficial:** https://www.redmine.org/guide
- **Docker Docs:** https://docs.docker.com/
- **PostgreSQL Docs:** https://www.postgresql.org/docs/

---

## 🔄 Próximos Passos

1. **Treinamento da equipe** nos módulos principais
2. **Importação de dados** existentes (se houver)
3. **Configuração de integrações** externas
4. **Personalização** de workflows específicos
5. **Configuração de relatórios** customizados

---

**🎉 Parabéns! Seu SGIME está pronto para uso!**

Este guia cobriu o básico para você começar. Para configurações avançadas, consulte a documentação completa na pasta `docs/`.

---

*SGIME v1.6 - Sistema de Gestão Integrada de Engenharia*  
*Colégio Pedro II - Seção de Engenharia*  
*Licença: GPLv3*
