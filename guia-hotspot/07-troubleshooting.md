# 07 · Troubleshooting

> Guia de referência para os erros mais comuns. Organize pelo componente que está falhando.

---

## 🔑 FreeRADIUS

### ❌ `MYSQL_OPT_RECONNECT is deprecated`

```
WARNING: MYSQL_OPT_RECONNECT is deprecated and will be removed in a future version.
```

**Causa:** MySQL 8.x marcou essa opção como deprecated.  
**Impacto:** Nenhum — apenas cosmético.

**Solução:** Adicionar bloco `mysql { }` em `/etc/freeradius/3.0/mods-available/sql`:

```
mysql {
  warnings = no
  connect_failure_retry_delay = 60
}
```

---

### ❌ `Address already in use — port 18120`

```
Failed binding to auth address 127.0.0.1 port 18120
/etc/freeradius/3.0/sites-enabled/inner-tunnel[33]: Error binding to port
```

**Causa:** Processo FreeRADIUS travado ainda ocupa a porta.

```bash
# Encontrar o processo
sudo ss -tlnpu | grep 18120
sudo lsof -i :18120

# Matar pelo PID encontrado
sudo kill -9 <PID>

# Reiniciar
sudo systemctl restart freeradius
```

---

### ❌ `control:Cleartext-Password is required for authentication`

```
(0) chap: ERROR: &control:Cleartext-Password is required for authentication
```

**Causa:** Senha armazenada em hash no banco, protocolo CHAP não consegue autenticar.

```sql
-- Verificar atributos atuais
SELECT username, attribute FROM radcheck LIMIT 10;

-- Corrigir
UPDATE radcheck
SET attribute = 'Cleartext-Password'
WHERE attribute IN ('MD5-Password', 'SHA-Password', 'Crypt-Password');
```

Ou configure o Mikrotik para usar PAP:
```
/ip hotspot profile set [find] login-by=http-pap
```

---

### ❌ `Access-Reject` para usuário correto

**Debug passo a passo:**

```bash
# 1. Parar serviço e rodar em modo debug
sudo systemctl stop freeradius
sudo freeradius -X 2>&1 | tee /tmp/radius-debug.log

# 2. Em outro terminal, fazer o teste
radtest USUARIO SENHA localhost 0 testing123

# 3. Analisar o log
grep -E "ERROR|WARN|Reject|Accept" /tmp/radius-debug.log
```

**Causas comuns:**

| Sintoma no log | Causa | Solução |
|----------------|-------|---------|
| `No Auth-Type found` | Módulo PAP/CHAP não ativo | Verificar `authorize { pap }` no default |
| `User not found` | Usuário não existe no radcheck | Inserir usuário no banco |
| `Wrong password` | Senha errada ou atributo errado | Verificar valor no radcheck |
| `Client not found` | NAS não cadastrado | Inserir na tabela `nas` |
| `SQL query failed` | Erro de conexão MySQL | Verificar credenciais no mods-available/sql |

---

### ❌ `Configuration appears to NOT be OK` no `freeradius -XC`

```bash
# Ver erro completo
sudo freeradius -XC 2>&1 | grep -A3 "Error\|error"
```

**Erros mais comuns:**

```
# Módulo não encontrado
/etc/freeradius/3.0/sites-enabled/default[X]: Failed to find module "dailycounter"
```
→ `sudo ln -s /etc/freeradius/3.0/mods-available/sqlcounter /etc/freeradius/3.0/mods-enabled/sqlcounter`

```
# Bloco SQL dentro do sites-enabled/default
Unexpected section 'sql' in ...
```
→ Remover o bloco `sql { driver = ... }` do `sites-enabled/default`

---

## 🗄️ MySQL

### ❌ `Access denied for user 'hotspotuser'`

```bash
# Recriar o usuário
mysql -u root -e "
DROP USER IF EXISTS 'hotspotuser'@'localhost';
CREATE USER 'hotspotuser'@'localhost' IDENTIFIED BY 'senhaforte123';
GRANT ALL PRIVILEGES ON hotspot.* TO 'hotspotuser'@'localhost';
FLUSH PRIVILEGES;"
```

### ❌ Tabelas RADIUS não existem

```bash
# Importar estrutura manualmente
mysql -u hotspotuser -psenhaforte123 hotspot \
  < /var/www/hotspot/backend/jobs/estrutura.sql

# Verificar
mysql -u hotspotuser -psenhaforte123 hotspot -e "SHOW TABLES;"
```

---

## ⚙️ PM2 / Backend

### ❌ `hotspot-api` com status `errored`

```bash
# Ver logs de erro
pm2 logs hotspot-api --lines 50

# Tentar reiniciar
pm2 restart hotspot-api
pm2 status
```

**Causas comuns:**

```bash
# Porta 3001 já em uso
sudo lsof -i :3001
sudo kill -9 <PID>
pm2 restart hotspot-api
```

```bash
# Dependências faltando
cd /var/www/hotspot/backend
npm install
pm2 restart hotspot-api
```

```bash
# Variável de ambiente faltando
cat /var/www/hotspot/backend/.env    # verificar se existe
# Se não existir, criar baseado no .env.example
```

### ❌ PM2 não inicia no boot

```bash
pm2 startup
# Execute o comando que ele imprimir (começa com 'sudo env ...')
pm2 save
```

---

## 🌐 NGINX

### ❌ `nginx -t` com erro de sintaxe

```bash
sudo nginx -t 2>&1
# Leia a linha que diz 'in /etc/nginx/...: line X'
sudo nano /etc/nginx/sites-available/hotspot
```

### ❌ 502 Bad Gateway

Backend não está respondendo:

```bash
pm2 list
pm2 restart hotspot-api
curl http://localhost:3001/api/    # deve responder
```

### ❌ 404 no frontend

Build não foi gerado ou está no lugar errado:

```bash
ls /var/www/hotspot/frontend/dist/    # deve existir index.html
# Se não existir:
cd /var/www/hotspot/frontend
npm install && npm run build
```

---

## 🔒 SSL / Certbot

### ❌ `DNS problem: NXDOMAIN`

```bash
# Verificar propagação DNS
dig seudominio.com.br +short
nslookup seudominio.com.br
# Deve retornar o IP do servidor
```

### ❌ `Too many certificates already issued`

Limite de 5 certificados por semana por domínio no Let's Encrypt.

```bash
# Teste sem solicitar certificado real
sudo certbot certonly --dry-run --nginx -d seudominio.com.br
```

Aguarde a janela de 7 dias ou use um subdomínio diferente.

---

## 📡 Mikrotik

### ❌ Mikrotik não consegue autenticar no RADIUS

```bash
# 1. Verificar conectividade
# No terminal do Mikrotik:
/ping 192.168.1.100        # IP do servidor

# 2. Verificar portas abertas no servidor
sudo ufw allow 1812/udp
sudo ufw allow 1813/udp

# 3. Verificar se o NAS está cadastrado com o IP correto
mysql -u hotspotuser -psenhaforte123 hotspot \
  -e "SELECT * FROM nas;"
```

### ❌ Autenticação OK mas portal não carrega

```bash
# Verificar NGINX
sudo systemctl status nginx
curl http://IP_DO_SERVIDOR/    # HTTP 200?

# Verificar DNS do hotspot no Mikrotik
/ip hotspot print    # ver 'dns-name'
```

---

## 🔁 Reset geral dos serviços

Quando em dúvida, reinicie tudo na ordem correta:

```bash
# 1. MySQL primeiro
sudo systemctl restart mysql

# 2. FreeRADIUS (depende do MySQL)
sudo systemctl restart freeradius

# 3. Backend (depende do MySQL)
pm2 restart hotspot-api

# 4. NGINX por último
sudo systemctl restart nginx

# 5. Verificar tudo
systemctl is-active mysql freeradius nginx
pm2 status
```

---

## 📋 Coleta de logs para suporte

Se precisar de ajuda, colete esses logs:

```bash
# Script de coleta rápida
echo "=== FreeRADIUS ===" > /tmp/suporte.log
sudo freeradius -XC 2>&1 >> /tmp/suporte.log
echo "=== NGINX ===" >> /tmp/suporte.log
sudo nginx -t 2>&1 >> /tmp/suporte.log
echo "=== PM2 ===" >> /tmp/suporte.log
pm2 list >> /tmp/suporte.log
echo "=== Services ===" >> /tmp/suporte.log
systemctl is-active mysql freeradius nginx >> /tmp/suporte.log
echo "=== Portas ===" >> /tmp/suporte.log
sudo ss -tlnpu | grep -E '80|443|1812|1813|3001' >> /tmp/suporte.log

cat /tmp/suporte.log
```

---

## ➡️ Próxima etapa

→ **[08-seguranca-producao.md](./08-seguranca-producao.md)** — Hardening e produção
