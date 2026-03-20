#!/bin/bash

echo "🔐 Script de configuração de SSL para NGINX com Let's Encrypt"

read -p "Informe o domínio completo (ex: wifi.seudominio.com.br): " DOMINIO

if [[ -z "$DOMINIO" ]]; then
  echo "❌ Domínio não pode estar vazio. Abortando."
  exit 1
fi

echo "📦 Instalando Certbot e dependências..."
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

echo "✅ Certbot instalado com sucesso."

echo "📁 Atualizando configuração NGINX para domínio $DOMINIO"

NGINX_CONF="/etc/nginx/sites-available/hotspot"

sudo cp $NGINX_CONF $NGINX_CONF.bak

sudo sed -i "s/server_name _;/server_name $DOMINIO;/g" $NGINX_CONF

echo "🔄 Parando o  NGINX para aplicar alterações..."
sudo systemctl stop nginx

echo "🔒 Solicitando certificado SSL para $DOMINIO..."
sudo certbot --nginx -d "$DOMINIO" --redirect

echo "✅ Certificado SSL instalado com sucesso."
echo "🌐 Acesse https://$DOMINIO para verificar."

echo "📅 Adicionando renovação automática..."
echo "0 3 * * * /usr/bin/certbot renew --quiet" | sudo tee /etc/cron.d/certbot-renew > /dev/null

echo "🟢 Configuração finalizada!"