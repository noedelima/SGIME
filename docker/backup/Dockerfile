# Dockerfile para serviço de backup do SGIME
# Sistema de Gestão Integrada de Engenharia
# Colégio Pedro II - Seção de Engenharia

FROM alpine:3.18

# Metadados
LABEL maintainer="Seção de Engenharia - Colégio Pedro II <engenharia@cp2.g12.br>"
LABEL version="1.6"
LABEL description="Serviço de backup automatizado para SGIME"

# Instalar dependências
RUN apk add --no-cache \
    postgresql-client \
    curl \
    tar \
    gzip \
    bash \
    dcron \
    tzdata \
    && rm -rf /var/cache/apk/*

# Configurar timezone
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Criar usuário para backup
RUN addgroup -g 1000 sgime && \
    adduser -D -s /bin/bash -G sgime -u 1000 sgime

# Criar diretórios
RUN mkdir -p /backups /scripts /var/log/sgime \
    && chown -R sgime:sgime /backups /scripts /var/log/sgime

# Copiar scripts de backup
COPY docker/backup/scripts/ /scripts/
RUN chmod +x /scripts/*.sh \
    && chown -R sgime:sgime /scripts

# Configurar cron
COPY docker/backup/crontab /etc/cron.d/sgime-backup
RUN chmod 0644 /etc/cron.d/sgime-backup \
    && crontab -u sgime /etc/cron.d/sgime-backup

# Configurar usuário
USER sgime
WORKDIR /backups

# Health check
HEALTHCHECK --interval=1h --timeout=30s --start-period=10s --retries=3 \
    CMD /scripts/healthcheck.sh

# Comando padrão - executar cron em foreground
CMD ["crond", "-f", "-d", "8"]
