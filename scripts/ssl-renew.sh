#!/bin/bash

# Script para renovar certificados SSL
# Para usar em cron job

echo "🔄 Renovando certificados SSL..."

# Tentar renovar certificados
docker-compose run --rm certbot renew

# Se a renovação foi bem-sucedida, recarregar nginx
if [ $? -eq 0 ]; then
    echo "✅ Certificados renovados!"
    docker-compose exec nginx nginx -s reload
    echo "🔄 Nginx recarregado!"
else
    echo "ℹ️  Nenhum certificado precisava ser renovado."
fi
