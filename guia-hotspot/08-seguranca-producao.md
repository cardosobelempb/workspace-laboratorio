# 08 · Segurança e Produção

> **Execute esta etapa antes de expor o sistema para usuários reais.**  
> Todos os itens abaixo são importantes — não pule nenhum.

---

## 🔒 1. Trocar senhas padrão

### MySQL — usuário hotspotuser

```bash
mysql -u root -e "
ALTER USER 'hotspotuser'@'localhost'
  IDENTIFIED BY 'NOVA_SENHA_FORTE_AQUI';
FLUSH PRIVILEGES;"
```

Atualizar nos arquivos de configuração:

```bash
# FreeRADIUS
sudo nano /etc/freeradius/3.0/mods-available/sql
# Alterar: password = "NOVA_SENHA_FORTE_AQUI"

# Backend (verificar onde a senha está configurada)
nano /var/www/hotspot/backend/.env
# ou
nano /var/www/hotspot/backend/config.js

# Reiniciar após trocar
sudo systemctl restart freeradius
pm2 restart hotspot-api
```

---

### RADIUS Secret — Mikrotik ↔ FreeRADIUS

Gere um secret forte:

```bash
# Gerar 32 caracteres aleatórios
openssl rand -base64 32
# Exemplo: xK9mP2vL7nQ4wR6yS8tU1aB3cD5eF0gH
```

Atualizar no banco:

```sql
mysql -u hotspotuser -p hotspot

UPDATE nas
SET secret = 'NOVO_SECRET_GERADO'
WHERE nasname = '192.168.1.1';    -- IP do Mikrotik
```

Atualizar no Mikrotik:

```
/radius set [find address=192.168.1.100] secret=NOVO_SECRET_GERADO
```

---

## 🛡️ 2. Firewall (UFW)

```bash
# Habilitar UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Liberar apenas o necessário
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 1812/udp    # RADIUS Auth
sudo ufw allow 1813/udp    # RADIUS Acct

# Opcional: restringir RADIUS apenas ao IP do Mikrotik
# sudo ufw allow from 192.168.1.1 to any port 1812 proto udp
# sudo ufw allow from 192.168.1.1 to any port 1813 proto udp

# Ativar
sudo ufw enable

# Verificar
sudo ufw status verbose
```

---

## 🚫 3. Proteger MySQL

### Bloquear acesso remoto ao MySQL

```bash
# Verificar se MySQL está escutando apenas em localhost
sudo ss -tlnp | grep 3306
# Deve mostrar: 127.0.0.1:3306  (não 0.0.0.0:3306)
```

Se estiver em `0.0.0.0:3306`, edite:

```bash
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
[mysqld]
bind-address = 127.0.0.1
```

```bash
sudo systemctl restart mysql
```

### Remover usuários anônimos e banco de teste

```bash
sudo mysql_secure_installation
```

Responda `Y` para todas as perguntas.

---

## 📂 4. Permissões de arquivos

```bash
# Configurações do FreeRADIUS — apenas root pode ler
sudo chown -R freerad:freerad /etc/freeradius/3.0/
sudo chmod 640 /etc/freeradius/3.0/mods-available/sql

# Backend — usuário do sistema, não root
sudo chown -R www-data:www-data /var/www/hotspot
sudo chmod -R 755 /var/www/hotspot
sudo chmod 600 /var/www/hotspot/backend/.env   # se existir
```

---

## 💾 5. Backup automático

### Script de backup

```bash
sudo nano /usr/local/bin/backup-hotspot.sh
```

```bash
#!/bin/bash
set -e

DATE=$(date +%Y%m%d_%H%M)
BACKUP_DIR="/var/backups/hotspot"
DB_USER="hotspotuser"
DB_PASS="SUA_SENHA"
DB_NAME="hotspot"

mkdir -p "$BACKUP_DIR"

# Backup do banco
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  --single-transaction \
  --routines \
  --triggers \
  > "$BACKUP_DIR/db_${DATE}.sql"

# Backup das configs do FreeRADIUS
tar -czf "$BACKUP_DIR/freeradius_${DATE}.tar.gz" \
  /etc/freeradius/3.0/mods-available/sql \
  /etc/freeradius/3.0/sites-enabled/default

# Manter apenas os 7 backups mais recentes de cada tipo
ls -t "$BACKUP_DIR"/db_*.sql     | tail -n +8 | xargs -r rm
ls -t "$BACKUP_DIR"/freeradius_*.tar.gz | tail -n +8 | xargs -r rm

echo "$(date): Backup concluído" >> /var/log/backup-hotspot.log
```

```bash
sudo chmod +x /usr/local/bin/backup-hotspot.sh

# Agendar: todo dia às 02:00
echo "0 2 * * * root /usr/local/bin/backup-hotspot.sh" \
  | sudo tee /etc/cron.d/backup-hotspot

# Testar agora
sudo /usr/local/bin/backup-hotspot.sh
ls -lh /var/backups/hotspot/
```

---

## 📈 6. Monitoramento

### PM2 com reinício automático em crash

```bash
# Configurar reinício automático
pm2 set pm2:autodump true
pm2 startup
pm2 save

# Limite de memória (reinicia se exceder 500MB)
pm2 restart hotspot-api --max-memory-restart 500M
pm2 save
```

### Monitorar recursos

```bash
# Monitoramento em tempo real
pm2 monit

# Resumo do sistema
htop
```

### Log rotation para FreeRADIUS

```bash
sudo nano /etc/logrotate.d/freeradius
```

```
/var/log/freeradius/radius.log {
    daily
    rotate 14
    compress
    missingok
    notifempty
    postrotate
        systemctl reload freeradius > /dev/null 2>&1 || true
    endscript
}
```

---

## 🔄 7. Manutenção periódica

### Limpeza de sessões antigas

```sql
-- Sessões sem fechamento há mais de 24h (zumbis)
mysql -u hotspotuser -psenhaforte123 hotspot -e "
  UPDATE radacct
  SET acctstoptime = NOW(),
      acctterminatecause = 'Admin-Reset'
  WHERE acctstoptime IS NULL
    AND acctupdatetime < NOW() - INTERVAL 24 HOUR;"
```

### Agendar limpeza semanal

```bash
echo "0 4 * * 0 hotspotuser mysql -u hotspotuser -pSENHA hotspot -e \
  'UPDATE radacct SET acctstoptime=NOW() WHERE acctstoptime IS NULL AND acctupdatetime < NOW()-INTERVAL 24 HOUR;'" \
  | sudo tee /etc/cron.d/radius-cleanup
```

---

## 📋 Checklist final de produção

### Senhas e secrets
- [ ] Senha do `hotspotuser` MySQL trocada
- [ ] RADIUS secret gerado com `openssl rand -base64 32`
- [ ] Secret atualizado no banco (tabela `nas`)
- [ ] Secret atualizado no Mikrotik
- [ ] `.env` do backend com credenciais atualizadas

### Rede e firewall
- [ ] UFW ativo com regras corretas
- [ ] MySQL escutando apenas em `127.0.0.1`
- [ ] RADIUS acessível apenas pelo IP do Mikrotik *(recomendado)*
- [ ] SSL/HTTPS ativo com certificado válido

### Disponibilidade
- [ ] `pm2 startup` configurado (reinicia no boot)
- [ ] `pm2 save` executado
- [ ] `systemctl enable` para mysql, freeradius e nginx
- [ ] Script de backup funcionando
- [ ] Cron de backup agendado

### Monitoramento
- [ ] Log rotation configurado
- [ ] Limpeza de sessões zumbis agendada
- [ ] Alertas configurados (opcional: UptimeRobot, Grafana, etc.)

---

## 🚀 Sistema pronto para produção!

```
✅ Ubuntu Server 22.04+
✅ MySQL 8.x com banco hotspot
✅ FreeRADIUS 3.2.5 sem warnings
✅ Node.js API com PM2
✅ NGINX com SSL
✅ Mikrotik integrado via RADIUS
✅ Firewall configurado
✅ Backups automáticos
✅ Senhas trocadas
```

---

## 📚 Referência rápida de comandos

```bash
# Reiniciar tudo
sudo systemctl restart mysql freeradius nginx && pm2 restart hotspot-api

# Ver logs em tempo real
sudo tail -f /var/log/freeradius/radius.log &
pm2 logs hotspot-api

# Status geral
systemctl is-active mysql freeradius nginx && pm2 status

# Testar autenticação RADIUS
radtest USUARIO SENHA localhost 0 testing123

# Sessões ativas
mysql -u hotspotuser -pSENHA hotspot \
  -e "SELECT username, framedipaddress, acctstarttime FROM radacct WHERE acctstoptime IS NULL;"
```
