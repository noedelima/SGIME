# SGIME Plugins Directory

Este diretório contém os plugins do Redmine para o sistema SGIME.

## 📁 Estrutura

```
plugins/
├── sgime_customizations/          # Plugin customizado do SGIME
├── redmine_checklists/           # Plugin de checklists
├── redmine_dashboard/            # Plugin de dashboard
├── redmine_dmsf/                 # Plugin de gerenciamento de documentos
└── ...                           # Outros plugins
```

## 🔧 Como Usar

### 1. Adicionar um Plugin

1. Baixe o plugin para esta pasta:
   ```bash
   cd plugins
   git clone [URL_DO_PLUGIN] [nome_do_plugin]
   ```

2. Adicione a linha no docker-compose.yml:
   ```yaml
   - ./plugins/[nome_do_plugin]:/usr/src/redmine/plugins/[nome_do_plugin]
   ```

3. Reinicie o container:
   ```bash
   docker-compose restart redmine
   ```

### 2. Remover um Plugin

1. Comente a linha no docker-compose.yml
2. Reinicie o container:
   ```bash
   docker-compose restart redmine
   ```

## 📋 Plugins Planejados

- [ ] sgime_customizations (próprio)
- [ ] redmine_checklists
- [ ] redmine_dashboard
- [ ] redmine_dmsf
- [ ] redmine_agile
- [ ] redmine_spent_time
- [ ] redmine_contacts

## 🚨 Importante

- Sempre teste um plugin por vez
- Faça backup antes de adicionar novos plugins
- Verifique compatibilidade com Redmine 5.1
