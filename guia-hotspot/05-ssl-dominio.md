# 05 · SSL com Domínio

> **Script:** `Install-3_dominio.sh`  
> **Tempo estimado:** ~10 minutos  
> **Pré-requisito:** Sistema funcionando + domínio apontando para o IP do servidor

---

## ⚠️ Pré-requisitos obrigatórios

Antes de executar este script, confirme:

```bash
# 1. DNS já propagou?
nslookup wifi.seudominio.com.br
# Deve retornar o IP do seu servidor

# 2. Porta 80 está acessível externamente?
curl -s http://wifi.seudominio.com.br/ | head -5
# Deve retornar HTML (não timeout)
```

> ❌ Se o DNS não estiver propagado, o Certbot vai **falhar**.  
> Aguarde a propagação antes de continuar (pode levar até 1h).

---

## 📋 O que o script faz

```
[1] Instala Certbot + plugin NGINX
[2] Faz backup do nginx.conf atual
[3] Substitui server_name _ pelo domínio informado
[4] Para o NGINX temporariamente
[5] Solicita certificado SSL ao Let's Encrypt
[6] Configura redirecionamento HTTP → HTTPS automaticamente
[7] Adiciona cron de renovação automática (03:00 diariamente)
```

---

## ▶️ Como executar

```bash
chmod +x Install-3_dominio.sh
sudo bash Install-3_dominio.sh
```

O script vai perguntar o domínio:

```
Informe o domínio completo (ex: wifi.seudominio.com.br):
>> wifi.seudominio.com.br
```

---

## 🔍 O que acontece durante a execução

```
✅ Certbot instalado com sucesso.
📁 Atualizando configuração NGINX para domínio wifi.seudominio.com.br
🔄 Parando o NGINX para aplicar alterações...
🔒 Solicitando certificado SSL para wifi.seudominio.com.br...

Saving debug log to /var/log/letsencrypt/letsencrypt.log
...
Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/wifi.seudominio.com.br/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/wifi.seudominio.com.br/privkey.pem
...
✅ Certificado SSL instalado com sucesso.
```

---

## 🔍 Verificação pós-instalação

### Certificado ativo

```bash
sudo certbot certificates
```

```
Found the following certs:
  Certificate Name: wifi.seudominio.com.br
    Domains: wifi.seudominio.com.br
    Expiry Date: 2026-06-xx (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/wifi.seudominio.com.br/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/wifi.seudominio.com.br/privkey.pem
```

### NGINX com SSL

```bash
sudo nginx -t && sudo systemctl status nginx
```

### Testar HTTPS

```bash
curl -Is https://wifi.seudominio.com.br/ | head -3
```

```
HTTP/2 200
server: nginx
...
```

### Testar redirecionamento HTTP → HTTPS

```bash
curl -Is http://wifi.seudominio.com.br/ | grep -i location
```

```
location: https://wifi.seudominio.com.br/
```

### Renovação automática configurada

```bash
cat /etc/cron.d/certbot-renew
```

```
0 3 * * * /usr/bin/certbot renew --quiet
```

---

## 📄 Configuração NGINX após SSL

O Certbot modifica o arquivo `/etc/nginx/sites-available/hotspot` automaticamente:

```nginx
server {
    listen 80;
    server_name wifi.seudominio.com.br;

    return 301 https://$host$request_uri;   # ← adicionado pelo Certbot
}

server {
    listen 443 ssl;
    server_name wifi.seudominio.com.br;

    ssl_certificate     /etc/letsencrypt/live/wifi.seudominio.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/wifi.seudominio.com.br/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

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

## 🔄 Renovação do certificado

Os certificados Let's Encrypt expiram em **90 dias**. A renovação é automática via cron.

### Testar renovação manualmente

```bash
sudo certbot renew --dry-run
```

```
Congratulations, all simulated renewals succeeded
```

### Forçar renovação agora (se necessário)

```bash
sudo certbot renew --force-renewal
sudo systemctl reload nginx
```

---

## ❗ Problemas comuns

### `DNS problem: NXDOMAIN`

O domínio não resolve. Verifique:
```bash
dig wifi.seudominio.com.br +short
# Deve retornar o IP do servidor
```

### `Connection refused` ou `Timeout`

A porta 80 está bloqueada:
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### `too many certificates already issued`

Let's Encrypt tem limite de 5 certificados por domínio por semana.  
Aguarde ou use um subdomínio diferente.

### NGINX não reinicia após SSL

```bash
sudo nginx -t        # ver o erro específico
sudo journalctl -u nginx --no-pager | tail -20
```

---

## ✅ Checklist desta etapa

- [ ] DNS do domínio aponta para o IP do servidor
- [ ] `certbot certificates` mostra o certificado como VALID
- [ ] `curl https://seudominio.com.br/` retorna HTTP 200
- [ ] HTTP redireciona para HTTPS automaticamente
- [ ] Cron de renovação em `/etc/cron.d/certbot-renew`
- [ ] `certbot renew --dry-run` retorna sucesso

---

## ➡️ Próxima etapa

→ **[06-testes-validacao.md](./06-testes-validacao.md)** — Checklist completo de validação
