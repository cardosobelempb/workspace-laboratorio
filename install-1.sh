#!/bin/bash

echo "🔧 Atualizando sistema..."
apt update && apt upgrade -y

echo "📦 Instalando pacotes base..."
apt install -y nginx mysql-server freeradius freeradius-mysql nodejs npm git unzip curl

echo "🧪 Verificando versões:"
node -v
npm -v
mysql --version
freeradius -v

echo "🗄️ Criando banco de dados e usuário MySQL..."
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS hotspot CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'hotspotuser'@'localhost' IDENTIFIED BY 'senhaforte123';
GRANT ALL PRIVILEGES ON hotspot.* TO 'hotspotuser'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "✅ Banco de dados 'hotspot' criado com usuário 'hotspotuser'"

echo "📂 Criando estrutura de diretórios..."
mkdir -p /var/www/hotspot
chown -R $USER:$USER /var/www/hotspot

echo "⚠️ IMPORTANTE: copie o sistema para /var/www/hotspot e depois execute as configurações."

echo "🧯 Reiniciando serviços..."
systemctl restart mysql
systemctl enable freeradius
systemctl restart freeradius
systemctl enable nginx
systemctl restart nginx

echo "✅ Instalação concluída."
