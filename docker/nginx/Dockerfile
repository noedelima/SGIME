# Dockerfile customizado para Nginx SGIME
# Baseado em nginx:1.25-alpine com curl para healthcheck

FROM nginx:1.25-alpine

# Instalar curl para healthcheck
RUN apk add --no-cache curl

# Criar diretório para SSL se não existir
RUN mkdir -p /etc/nginx/ssl

# Copiar configurações personalizadas (opcional - pode ser feito via volume)
# COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
# COPY config/nginx/sites/ /etc/nginx/conf.d/

# Expor portas
EXPOSE 80 443

# Comando padrão (herdado da imagem base)
CMD ["nginx", "-g", "daemon off;"]
