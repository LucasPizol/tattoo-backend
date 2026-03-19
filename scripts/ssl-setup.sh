#!/bin/bash

# Script para configurar SSL com Let's Encrypt - Tattoo API
# Executa em duas fases: 1) Obter certificados 2) Ativar SSL

set -e

echo "🔐 Configurando SSL para Tattoo API..."

# Verificar se domínio está respondendo
echo "🌐 Verificando se domínio está acessível..."
if ! curl -f -s -o /dev/null http://api.tattoo.rainbowpiercing.com.br; then
    echo "❌ ERRO: Domínio api.tattoo.rainbowpiercing.com.br não está acessível!"
    echo "🔍 Verifique se:"
    echo "   - O DNS está apontando para este servidor"
    echo "   - A porta 80 está aberta"
    echo "   - O nginx está rodando"
    exit 1
fi

# Criar diretórios necessários
echo "📁 Criando estrutura de diretórios..."
mkdir -p ./certbot/www
mkdir -p ./certbot/conf
chmod -R 755 ./certbot

echo "🐳 FASE 1: Parando containers e configurando para obter certificados..."
docker-compose down

echo "🏗️  Rebuild dos containers..."
docker-compose build --no-cache nginx

echo "🚀 Iniciando aplicação completa (sem SSL)..."
docker-compose up -d

echo "⏳ Aguardando inicialização completa..."
sleep 15

# Verificar se a aplicação está respondendo
echo "🔍 Verificando se aplicação está funcionando..."
for i in {1..5}; do
    if curl -f -s -o /dev/null http://api.tattoo.rainbowpiercing.com.br; then
        echo "✅ Aplicação respondendo!"
        break
    fi
    echo "⏳ Tentativa $i/5 - aguardando..."
    sleep 10
done

echo "📜 FASE 2: Obtendo certificado SSL..."
docker-compose run --rm certbot certonly \
  --webroot \
  --webroot-path /var/www/certbot \
  -d api.tattoo.rainbowpiercing.com.br \
  -d www.api.tattoo.rainbowpiercing.com.br \
  --email lucaspizolfe@gmail.com \
  --agree-tos \
  --no-eff-email \
  --non-interactive

if [ $? -eq 0 ]; then
    echo "✅ Certificado obtido com sucesso!"

        echo "🔄 FASE 3: Ativando configuração SSL..."

    # Backup da configuração atual
    cp nginx/nginx.conf nginx/nginx-http-backup.conf

    echo "⚠️  AÇÃO MANUAL NECESSÁRIA:"
    echo "📝 Agora edite o arquivo nginx/nginx.conf e:"
    echo "   1. Comente todo o bloco 'MODO DESENVOLVIMENTO' (linhas 16-29)"
    echo "   2. Descomente o redirect HTTPS (linhas 32-34)"
    echo "   3. Descomente todo o bloco 'SERVIDOR HTTPS' (linhas 42-112)"
    echo ""
    read -p "✅ Pressione ENTER quando terminar a edição..."

    # Rebuild nginx com nova configuração
    docker-compose build nginx

    # Reiniciar todos os serviços
    echo "🚀 Reiniciando com SSL ativado..."
    docker-compose down
    docker-compose up -d

    echo "⏳ Aguardando estabilização..."
    sleep 10

    # Verificar HTTPS
    if curl -f -s -o /dev/null https://api.rainbowpiercing.com.br; then
        echo "🎉 SSL configurado com sucesso!"
        echo "🌐 Acesse: https://api.rainbowpiercing.com.br"
        echo "🔒 Certificado válido!"
    else
        echo "⚠️ SSL pode não estar funcionando corretamente"
        echo "🔍 Verifique os logs: docker-compose logs nginx"
    fi
else
    echo "❌ ERRO ao obter certificado!"
    echo "🔍 Possíveis causas:"
    echo "   - Domínio não está apontando corretamente"
    echo "   - Firewall bloqueando portas 80/443"
    echo "   - Rate limit do Let's Encrypt atingido"
    echo "   - Problema na validação ACME"
    echo ""
    echo "📋 Para debug, execute:"
    echo "   docker-compose logs nginx"
    echo "   docker-compose logs certbot"
    exit 1
fi
