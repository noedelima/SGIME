# Manual do Usuário - SGIME

**Sistema de Gestão Integrada de Engenharia**  
**Colégio Pedro II - Seção de Engenharia**  
**Versão 1.6 - Julho 2025**

---

## Sumário

1. [Introdução](#introdução)
2. [Primeiro Acesso](#primeiro-acesso)
3. [Módulos do Sistema](#módulos-do-sistema)
4. [Gestão de Ativos](#gestão-de-ativos)
5. [Manutenção Preventiva](#manutenção-preventiva)
6. [Ordens de Serviço](#ordens-de-serviço)
7. [Gestão de Documentos](#gestão-de-documentos)
8. [Relatórios e Dashboards](#relatórios-e-dashboards)
9. [Perguntas Frequentes](#perguntas-frequentes)

---

## Introdução

O SGIME é uma plataforma integrada para gestão completa das atividades de engenharia e manutenção do Colégio Pedro II. Baseado no Redmine, oferece funcionalidades específicas para:

- **Gestão de Ativos**: Controle hierárquico de equipamentos e instalações
- **Manutenção**: Preventiva, preditiva e corretiva
- **Documentos**: Repositório centralizado para projetos de engenharia
- **Relatórios**: Indicadores de desempenho e conformidade

## Primeiro Acesso

### Acessando o Sistema

1. Acesse: `https://sgime.cp2.g12.br`
2. Use suas credenciais do Active Directory ou:
   - Usuário: `admin`
   - Senha: `admin` (apenas primeira instalação)

### Navegação Básica

O sistema está organizado em **Projetos** que representam:
- **Complexos** (Ex: Campus Centro)
- **Campi** (Ex: Campus Humaitá II)
- **Edifícios** (Ex: Edifício Principal)
- **Blocos** (Ex: Bloco A, Bloco B)

### Perfis de Usuário

- **Administrador**: Acesso completo ao sistema
- **Gerente de Manutenção**: Gestão completa de manutenção
- **Técnico**: Execução de manutenção e vistoria
- **Prefeito de Campus**: Visão gerencial do campus
- **Consulta**: Apenas visualização

## Módulos do Sistema

### 1. Módulo de Gestão de Ativos

**Objetivo**: Cadastrar e organizar todos os ativos do Colégio Pedro II.

#### Cadastrando um Novo Ativo

1. Navegue até o projeto (local) apropriado
2. Clique em **"Nova tarefa"**
3. Selecione o rastreador **"ATIVO"**
4. Preencha os campos obrigatórios:
   - **Assunto**: Nome do ativo
   - **Código do Ativo**: Identificação única
   - **Localização**: Local específico
   - **Disciplina**: Área técnica (Elétrica, Hidráulica, etc.)
   - **Fabricante**: Marca do equipamento
   - **Modelo**: Modelo específico

#### Organizando por Disciplinas

O sistema organiza ativos por disciplinas técnicas:
- **Elétrica**: Quadros, motores, iluminação
- **Hidráulica**: Bombas, tubulações, reservatórios
- **Ar Condicionado**: Centrais de ar, splits
- **Civil**: Estruturas, pisos, coberturas
- **Prevenção**: Extintores, hidrantes, alarmes

### 2. Módulo de Planejamento e Controle da Manutenção

#### Criando Listas de Verificação

1. No projeto apropriado, crie uma nova tarefa
2. Selecione o rastreador **"LISTA DE VERIFICAÇÃO"**
3. Vincule ao ativo correspondente
4. Use o **plugin Checklists** para criar itens de verificação:
   - Clique na aba **"Checklists"**
   - Adicione itens de verificação
   - Defina critérios de conformidade

#### Executando Vistoria

1. Acesse a lista de verificação
2. Marque cada item como **Conforme** ✅ ou **Não Conforme** ❌
3. Adicione comentários e evidências fotográficas
4. Para evidências, use **"Arquivos"** para anexar fotos
5. Finalize alterando o status para **"Concluída"**

#### Gerando Relatório PDF

Após concluir uma vistoria:
1. Clique no botão **"Gerar Relatório PDF"**
2. O sistema compilará automaticamente:
   - Dados do ativo
   - Itens verificados
   - Não conformidades
   - Evidências fotográficas
   - Assinaturas digitais

### 3. Módulo de Gestão de Ordens de Serviço

#### Geração Automática de OS

Quando uma lista de verificação apresenta **não conformidades**:
- O sistema **automaticamente cria** uma Ordem de Serviço
- A OS é vinculada à lista de verificação original
- O responsável técnico é notificado por email

#### Gerenciando Ordens de Serviço

1. Acesse **"Ordens de Serviço"** no menu do projeto
2. Para cada OS, você pode:
   - **Detalhar o escopo** de trabalho
   - **Anexar orçamentos** (planilhas, PDFs)
   - **Definir cronograma** usando o Gantt
   - **Acompanhar execução** através de atualizações

#### Fluxo de Estados da OS

- **Nova**: OS recém-criada
- **Em Orçamento**: Aguardando definição de custos
- **Aprovada**: Pronta para execução
- **Em Execução**: Trabalho em andamento
- **Concluída**: Serviço finalizado
- **Cancelada**: OS cancelada

### 4. Módulo de Gestão de Documentos (GED)

#### Estrutura de Documentos

O módulo de documentos organiza arquivos por **projeto de engenharia**:
- **Projetos Arquitetônicos**
- **Projetos Estruturais**
- **Projetos de Instalações**
- **As Built** (Como Executado)
- **Manuais e Especificações**

#### Fazendo Upload de Documentos

1. Navegue até o projeto de documentos
2. Use o **plugin DMSF** (Document Management System)
3. Clique em **"Novo Arquivo"**
4. Faça o upload do documento
5. Preencha metadados:
   - **Título**: Nome do documento
   - **Descrição**: Resumo do conteúdo
   - **Versão**: Controle de versão
   - **Palavras-chave**: Para busca

#### Controle de Versões

- Cada upload cria uma **nova versão**
- Versões anteriores são **preservadas**
- Histórico de modificações é **rastreável**
- Apenas a **versão mais recente** fica ativa por padrão

#### Download em Pacote

Para baixar múltiplos documentos:
1. Selecione a pasta desejada
2. Clique em **"Baixar Pacote Completo (.zip)"**
3. O sistema criará um arquivo ZIP com:
   - Documentos principais (PDF)
   - Arquivos fonte (DWG, DOCX)
   - Arquivo de metadados
   - README explicativo

### 5. Módulo de Relatórios e Indicadores

#### Dashboards Personalizáveis

Use o **plugin Dashboard** para criar visualizações:
1. Acesse **"Dashboard"** no menu principal
2. Adicione **widgets** conforme sua necessidade:
   - Gráficos de não conformidades
   - Status de ordens de serviço
   - Estatísticas por disciplina
   - Indicadores de desempenho

#### Filtros Avançados

Todos os relatórios podem ser filtrados por:
- **Hierarquia**: Complexo → Campus → Edifício → Bloco
- **Disciplina**: Elétrica, Hidráulica, Civil, etc.
- **Período**: Data de criação, atualização
- **Status**: Aberto, fechado, em andamento
- **Responsável**: Técnico, gerente

#### Principais Indicadores

- **Taxa de Conformidade**: % de itens conformes por período
- **Tempo Médio de Resolução**: Tempo médio para fechar OS
- **Backlog de Manutenção**: OS pendentes por disciplina
- **Custo por Disciplina**: Gastos por área técnica
- **Eficiência de Equipe**: Produtividade por técnico

## Perguntas Frequentes

### Como alterar minha senha?

1. Clique em **"Minha conta"** (canto superior direito)
2. Acesse a aba **"Informações"**
3. Clique em **"Alterar senha"**

### Como receber notificações por email?

1. Em **"Minha conta"** → **"Configurações"**
2. Configure **"Notificações por email"**
3. Selecione eventos de interesse

### Como criar um relatório personalizado?

1. Use **"Problemas"** → **"Visualizar"**
2. Configure filtros desejados
3. Salve como **"Consulta personalizada"**
4. Adicione ao Dashboard se necessário

### Posso acessar pelo celular?

Sim! O SGIME possui interface responsiva e funciona perfeitamente em dispositivos móveis.

### Como solicitar novo usuário?

Entre em contato com a Seção de Engenharia:
- **Email**: geeng@cp2.g12.br
- **Sistema**: https://sgime.cp2.g12.br

### O que fazer se encontrar um bug?

1. Documente o problema (prints, passos para reproduzir)
2. Crie uma **tarefa** no projeto "Suporte SGIME"
3. Ou envie email para: geeng@cp2.g12.br

---

**Suporte Técnico**  
Seção de Engenharia - Colégio Pedro II  
📧 geeng@cp2.g12.br  
🌐 https://sgime.cp2.g12.br  

**Versão do Manual**: 1.6  
**Última Atualização**: Julho 2025
