# Especificação Técnica

Sistema de Gestão Integrada de Engenharia (SGIE) com a Plataforma Redmine

Órgão: Colégio Pedro II  
Setor Demandante: Seção de Engenharia  
Versão do Documento: 1.6 (Final Consolidada)  
Data: 22 de julho de 2025  

---

## 1. Introdução

Este documento estabelece a especificação técnica para a implantação de um Sistema de Gestão Integrada de Engenharia (SGIE) para o Colégio Pedro II. A solução será desenvolvida sobre a plataforma de gerenciamento de projetos Redmine, utilizando tecnologias de código aberto, e visa centralizar, padronizar e automatizar os processos de:
- Manutenção de ativos imobiliários e equipamentos eletromecânicos  
- Gestão de documentos de projetos de engenharia e arquitetura  

A concepção do sistema atende às necessidades de controle, rastreabilidade e colaboração, em conformidade com a legislação vigente, notadamente a Lei nº 14.133/2021, e as normas técnicas aplicáveis.  

---

## 2. Objetivos

### 2.1 Objetivo Geral

Implantar uma plataforma centralizada e segura para o gerenciamento completo do ciclo de vida das atividades de manutenção e dos documentos de projeto, otimizando o uso de recursos, garantindo a conformidade e a integridade da informação, e facilitando a colaboração entre equipes internas e empresas contratadas.  

### 2.2 Objetivos Específicos

**Módulo de Manutenção**  
- Cadastrar e controlar todos os ativos imobiliários e equipamentos, organizados por uma estrutura hierárquica de locais e categorizados por disciplina técnica  
- Gerenciar rotinas de manutenção preditiva, preventiva e corretiva  
- Automatizar a geração e o preenchimento de checklists, com geração de relatórios detalhados  
- Gerar e controlar o fluxo de Ordens de Serviço (OS), incluindo detalhamento de orçamentos e cronogramas  
- Manter um histórico completo de intervenções e custos  

**Módulo de Gestão de Documentos**  
- Estabelecer um repositório centralizado e seguro para documentos de projeto  
- Gerenciar o ciclo de vida dos documentos (elaboração, análise, revisão, aprovação)  
- Controlar versões e revisões de todos os artefatos de projeto  

**Gerais**  
- Gerar relatórios e indicadores de desempenho para ambos os módulos  
- Prover uma interface moderna, responsiva e de fácil utilização  
- Garantir a segurança da informação e o controle de acesso granular  

---

## 3. Referencial Legal e Normativo

- Lei nº 14.133/2021 – Nova Lei de Licitações e Contratos Administrativos  
- Normas da ABNT (ex.: NBR 5462 e outras aplicáveis)  
- Normas Regulamentadoras (NRs) do Ministério do Trabalho e Emprego  
- Normas do Sistema CONFEA/CREA e CAU  
- Políticas de Segurança da Informação do Governo Federal  
- Manual de Redação da Presidência da República  

---

## 4. Arquitetura da Solução

- **Plataforma Base:** Redmine 5.1.x (ou versão estável mais recente)  
- **Banco de Dados:** PostgreSQL 16.x em cluster de alta disponibilidade  
- **Servidor de Aplicação:** Nginx (proxy reverso) + Puma (Ruby)  
- **Ambiente de Implantação:** Contêineres Docker orquestrados por Kubernetes  
- **Interface do Usuário:** Tema responsivo e customizável (ex.: Circle Theme, A1 Theme)  
- **Autenticação e Autorização:**  
  - LDAP/AD nativo  
  - Single Sign-On (SSO) compatível com Microsoft Entra ID (Azure AD)  

---

## 5. Requisitos Funcionais

O sistema será estruturado em módulos, implementados através de configuração nativa do Redmine, campos customizados, fluxos de trabalho e plugins.

### 5.1 Módulo 1: Gestão de Ativos (Manutenção)

- **Hierarquia de Locais:** Projetos e subprojetos para representar complexos, campi, edifícios e blocos  
- **Cadastro de Ativos:** Tarefas do tipo “ATIVO” no nível hierárquico apropriado  
- **Campos Personalizados:** Código do Ativo, Localização, Fabricante, Modelo, Disciplina  

### 5.2 Módulo 2: Planejamento e Controle da Manutenção

- **Checklists:** Plugin Redmine Checklists  
  - Criação de modelos pela interface web  
- **Rotinas de Manutenção:** Plugin Redmine Recurring Tasks  
- **Relatórios de Verificação:**  
  - Inclusão de fotos e evidências  
  - Geração de PDF (Customização 1)  
  - Visualização e download no navegador  
- **Manutenção Corretiva:** Tarefas do tipo “SOLICITAÇÃO DE MANUTENÇÃO CORRETIVA”  

### 5.3 Módulo 3: Gestão de Ordens de Serviço (OS)

- **Tarefa “ORDEM DE SERVIÇO”:** Fluxo de trabalho customizado  
- **Geração Automática de OS:** A partir de itens “Não Conforme” (Customização 2)  
- **Detalhamento Técnico:**  
  - Orçamento no campo wiki ou plugin de planilhas  
  - Cronograma com datas e Gantt nativo  

### 5.4 Módulo 4: Relatórios e Indicadores

- **Dashboards:** Plugin Redmine Dashboard  
- **Filtros:** Por hierarquia de local e disciplina  

### 5.5 Módulo 5: Gestão de Documentos de Projetos (GED)

- **Estrutura:** Subprojetos sob “Projetos de Engenharia”  
- **Repositório:** Plugin Redmine DMSF  
- **Agrupamento de Arquivos:** PDF, DWG, DOCX etc.  
- **Visualização:** Plugin Redmine Attach Preview  
- **Download em pacote (Customização 3)**  
- **Fluxo de Aprovação:** Estados (Em Elaboração, Para Análise, Aprovado, etc.)  

### 5.6 Módulo 6: Administração e Configurações

- **Gerenciamento de Disciplinas:** Lista de valores global no Redmine (RBAC)  
- **Hierarquia e Permissões:** Perfis específicos (“Prefeito de Campus”, “Gerente de Contrato”) com escopo definido  

---

## 6. Requisitos Não Funcionais

- **Desempenho:** < 3 s para 95% das requisições  
- **Segurança:**  
  - HTTPS com certificado válido  
  - LDAP/AD e SSO (SAML/OAuth2)  
  - RBAC e princípio do menor privilégio  
- **Disponibilidade:** ≥ 99,5% (Kubernetes)  
- **Usabilidade:** Interface intuitiva e responsiva em dispositivos móveis  
- **Backup e Recuperação:**  
  - Backup diário do BD e semanal dos anexos (retenção de 30 dias)  
  - RTO máximo de 4 horas  

---

## 7. Fases de Implantação (Sugestão)

| Fase   | Descrição                                                                               | Prazo Estimado |
|--------|-----------------------------------------------------------------------------------------|----------------|
| Fase 1 | Infraestrutura e implantação base (Kubernetes, Redmine, PostgreSQL e plugins essenciais) | 30 dias        |
| Fase 2 | Cadastramento e parametrização (hierarquia, disciplinas, tipos, campos e workflows)     | 45 dias        |
| Fase 3 | Manutenção preventiva e preditiva (modelos de checklists e tarefas automáticas)         | 30 dias        |
| Fase 4 | Treinamento e operação assistida                                                        | 30 dias        |
| Fase 5 | Relatórios e melhoria contínua (dashboards e feedback)                                  | Contínuo       |

---

## 8. Requisitos de Implementação e Documentação

### 8.1 Documentação Técnica

- README.md com:  
  - Descrição geral do sistema e módulos  
  - Licenças de software  
  - Pré-requisitos e versões  
  - Instruções de instalação passo a passo  
  - Configuração inicial e acesso  
  - Procedimentos de backup e restauração  
  - Comandos de operação (start, stop, status)  
  - Instruções de remoção completa  

### 8.2 Scripts de Automação

- **install.sh:** Instalação completa  
- **manage.sh:** Start, stop, restart, status  
- **uninstall.sh:** Remoção completa e segura  

### 8.3 Configuração via Interface Web

Todas as rotinas de administração (disciplinas, usuários, hierarquia) devem ser gerenciáveis pelo painel de Administração do Redmine.  

### 8.4 Compatibilidade de Sistema Operacional

Compatível com as versões estáveis mais recentes de Ubuntu Server e Fedora Server.  

---

## 9. Plugins e Customizações

Note: A hierarquização de locais e categorização por disciplinas usarão funcionalidades nativas do Redmine (projetos/subprojetos, campos personalizados e RBAC).

### 9.1 Plugins Recomendados

| Plugin                    | Finalidade                                               | Repositório Sugerido       |
|---------------------------|----------------------------------------------------------|----------------------------|
| Redmine Checklists        | Listas de verificação                                    | redmine_checklists         |
| Redmine Recurring Tasks   | Tarefas recorrentes                                       | redmine_recurring_tasks    |
| Redmine Dashboard         | Dashboards customizáveis                                  | redmine_dashboard          |
| Redmine DMSF              | Sistema de Gerenciamento de Documentos                    | redmine_dmsf               |
| Redmine Attach Preview    | Visualização de anexos no navegador                       | redmine_attach_preview     |
| Redmine OmniAuth Azure    | Autenticação SSO com contas Microsoft                     | redmine_omniauth_azure     |

### 9.2 Customizações Necessárias

#### Customização 1: Geração de Relatório PDF de Vistoria

- **Descrição:** Botão “Gerar Relatório PDF” ao finalizar checklist  
- **Lógica:** Compilar itens do checklist, comentários e imagens em PDF com identidade visual do Colégio Pedro II  

#### Customização 2: Gatilho para Geração de Ordem de Serviço

- **Descrição:** Monitorar salvamento de tarefa “LISTA DE VERIFICAÇÃO”  
- **Lógica:** Ao marcar “Não Conforme”, criar e vincular automaticamente uma nova “ORDEM DE SERVIÇO”  

#### Customização 3: Empacotamento de Documentos para Download

- **Descrição:** Botão “Baixar Pacote Completo (.zip)” na interface do DMSF  
- **Lógica:** Compactar o PDF principal e arquivos fonte associados em um único .zip  