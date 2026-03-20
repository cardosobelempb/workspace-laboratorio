#!/bin/bash

echo "📁 Verificando arquivos..."
if [[ ! -f freeradius.zip || ! -f hotspot.zip ]]; then
  echo "❌ Arquivos freeradius.zip ou hotspot.zip não encontrados no diretório atual."
  exit 1
fi

echo "📦 Descompactando arquivos..."
unzip -o freeradius.zip -d freeradius_conf
unzip -o hotspot.zip -d hotspot_temp

echo "🚚 Movendo configuração do FreeRADIUS..."
cp -r freeradius_conf/freeradius/3.0/* /etc/freeradius/3.0/

# Link do módulo SQL
echo "🔗 Ativando módulo SQL no FreeRADIUS..."
ln -sf /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/sql

echo "🚚 Instalando sistema em /var/www/hotspot"
rm -rf /var/www/hotspot
mv hotspot_temp/hotspot /var/www/hotspot
chown -R $USER:$USER /var/www/hotspot

echo "📦 Instalando dependências do backend..."
cd /var/www/hotspot/backend
npm install

echo "🔧 Iniciando backend com pm2..."
npm install -g pm2
pm2 start server.js --name hotspot-api
pm2 save
pm2 startup

echo "🧹 Limpando frontend antes do build..."
cd /var/www/hotspot/frontend
rm -rf node_modules package-lock.json dist
npm install

echo "🛠️ Buildando frontend..."
npm run build

echo "🌍 Configurando NGINX..."
cat > /etc/nginx/sites-available/hotspot <<EOF
server {
    listen 80;
    server_name _;

    root /var/www/hotspot/frontend/dist;
    index index.html;

    location / {
        try_files \$uri /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:3001/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/hotspot /etc/nginx/sites-enabled/hotspot

echo "🧹 Removendo bloco padrão do NGINX..."
rm -f /etc/nginx/sites-enabled/default

echo "🗄️ Importando estrutura do banco de dados..."
mysql -u hotspotuser -psenhaforte123 hotspot < /var/www/hotspot/backend/jobs/estrutura.sql

echo "🔁 Reiniciando serviços..."
systemctl restart freeradius
systemctl restart nginx

echo "✅ Sistema configurado com sucesso e pronto para uso!"
