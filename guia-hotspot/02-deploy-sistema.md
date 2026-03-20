# 02 · Deploy do Sistema

> **Script:** `install-2.sh`  
> **Tempo estimado:** ~15 minutos  
> **Pré-requisito:** Etapa 01 concluída + `freeradius.zip` e `hotspot.zip` no diretório atual

---

## ⚠️ Antes de executar

Este script **não funciona** sem os dois arquivos abaixo no mesmo diretório:

```bash
ls -lh freeradius.zip hotspot.zip
```

```
-rw-r--r-- 1 user user  XXK  freeradius.zip
-rw-r--r-- 1 user user  XXM  hotspot.zip
```

Se não estiverem presentes, copie-os primeiro:

```bash
# Do seu computador local
scp freeradius.zip hotspot.zip usuario@IP_DO_SERVIDOR:~/
```

---

## 📋 O que este script faz

```
[1] Verifica freeradius.zip e hotspot.zip
[2] Descompacta os arquivos
[3] Copia configs do FreeRADIUS → /etc/freeradius/3.0/
[4] Ativa módulo SQL (cria symlink mods-enabled/sql)
[5] Instala sistema em /var/www/hotspot
[6] npm install no backend
[7] Inicia backend com PM2 (hotspot-api na porta 3001)
[8] npm install + npm run build no frontend
[9] Configura NGINX (porta 80, proxy /api/ → :3001)
[10] Importa estrutura.sql no MySQL
[11] Reinicia freeradius e nginx
```

---

## ▶️ Como executar

```bash
# Certifique-se de estar no diretório com os zips
cd ~/
ls freeradius.zip hotspot.zip   # ambos devem aparecer

chmod +x install-2.sh
sudo bash install-2.sh
```

---

## 🔍 Verificação pós-instalação

### PM2 — Backend rodando

```bash
pm2 list
```

```
┌────┬────────────────┬─────────┬──────┬───────────┐
│ id │ name           │ status  │ cpu  │ memory    │
├────┼────────────────┼─────────┼──────┼───────────┤
│ 0  │ hotspot-api    │ online  │ 0%   │ XX MB     │
└────┴────────────────┴─────────┴──────┴───────────┘
```

> Se o status for `errored`, veja os logs: `pm2 logs hotspot-api`

---

### API respondendo

```bash
curl -s http://localhost:3001/api/
```

Deve retornar uma resposta JSON (não erro de conexão recusada).

---

### NGINX configurado

```bash
sudo nginx -t
```

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

```bash
# Verificar se o site hotspot está ativo
ls -la /etc/nginx/sites-enabled/
```

Deve conter `hotspot` (symlink) e **não** deve conter `default`.

---

### Frontend acessível

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost/
```

```
200
```

---

### FreeRADIUS config OK

```bash
sudo freeradius -XC
```

```
...
Configuration appears to be OK
```

> ⚠️ Se houver erros aqui, vá para **[03-freeradius.md](./03-freeradius.md)** antes de prosseguir.

---

### Banco importado

```bash
mysql -u hotspotuser -psenhaforte123 hotspot -e "SHOW TABLES;"
```

Deve listar as tabelas RADIUS:

```
+-------------------+
| Tables_in_hotspot |
+-------------------+
| nas               |
| radacct           |
| radcheck          |
| radgroupcheck     |
| radgroupreply     |
| radpostauth       |
| radreply          |
| radusergroup      |
+-------------------+
```

---

## 📄 Configuração do NGINX gerada

O script cria automaticamente `/etc/nginx/sites-available/hotspot`:

```nginx
server {
    listen 80;
    server_name _;

    root /var/www/hotspot/frontend/dist;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://localhost:3001/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

---

## ❗ Problemas comuns nesta etapa

### `freeradius.zip ou hotspot.zip não encontrados`

```bash
# Verifique se está no diretório correto
pwd
ls *.zip
```

### `PM2 hotspot-api em status errored`

```bash
pm2 logs hotspot-api --lines 50
# Leia o erro — geralmente é porta ocupada ou variável de ambiente faltando
```

### `npm run build falhou`

```bash
cd /var/www/hotspot/frontend
cat package.json | grep node   # verificar versão exigida
node -v                        # comparar com a instalada
npm install
npm run build
```

### `NGINX 502 Bad Gateway`

O backend não está rodando:
```bash
pm2 restart hotspot-api
pm2 status
```

---

## ✅ Checklist desta etapa

- [ ] `pm2 list` mostra `hotspot-api` com status `online`
- [ ] `curl http://localhost:3001/api/` retorna resposta
- [ ] `nginx -t` retorna syntax ok
- [ ] `curl http://localhost/` retorna HTTP 200
- [ ] `freeradius -XC` retorna `Configuration appears to be OK`
- [ ] `SHOW TABLES` lista as tabelas RADIUS no banco

---

## ➡️ Próxima etapa

→ **[03-freeradius.md](./03-freeradius.md)** — Configuração detalhada do FreeRADIUS
