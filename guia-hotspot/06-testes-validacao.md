# 06 · Testes e Validação

> Use este arquivo como **checklist final** antes de considerar o sistema em produção.

---

## ✅ Checklist Completo

### 🗄️ Banco de Dados

```bash
# Conectar ao banco
mysql -u hotspotuser -psenhaforte123 hotspot

# Verificar tabelas
SHOW TABLES;

# Verificar usuário de teste
SELECT username, attribute, value FROM radcheck LIMIT 5;

# Verificar NAS cadastrado
SELECT nasname, shortname, secret FROM nas;
```

- [ ] Banco `hotspot` acessível com `hotspotuser`
- [ ] Tabelas RADIUS presentes (radcheck, radacct, nas, etc.)
- [ ] Usuário de teste com `Cleartext-Password` no `radcheck`
- [ ] NAS do Mikrotik cadastrado na tabela `nas`

---

### 🔑 FreeRADIUS

```bash
# Validar configuração
sudo freeradius -XC

# Verificar serviço
sudo systemctl status freeradius

# Verificar portas abertas
sudo ss -tlnpu | grep -E '1812|1813'

# Verificar módulo SQL ativo
ls -la /etc/freeradius/3.0/mods-enabled/sql

# Teste de autenticação local
radtest USUARIO SENHA localhost 0 testing123

# Confirmar que MYSQL_OPT_RECONNECT sumiu
sudo freeradius -X 2>&1 | grep -i reconnect
```

- [ ] `freeradius -XC` → `Configuration appears to be OK`
- [ ] `systemctl status freeradius` → `active (running)`
- [ ] Porta `1812/udp` e `1813/udp` em escuta
- [ ] Symlink `mods-enabled/sql` existe
- [ ] `radtest` retorna `Access-Accept`
- [ ] Sem warning de `MYSQL_OPT_RECONNECT`

---

### ⚙️ Backend Node.js

```bash
# Status PM2
pm2 list
pm2 show hotspot-api

# Testar API
curl -s http://localhost:3001/api/

# Logs sem erros críticos
pm2 logs hotspot-api --lines 20
```

- [ ] `pm2 list` → `hotspot-api` com status `online`
- [ ] API responde na porta `3001`
- [ ] Sem erros críticos nos logs do PM2

---

### 🌐 NGINX + Frontend

```bash
# Validar configuração
sudo nginx -t

# Status do serviço
sudo systemctl status nginx

# Frontend acessível
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost/

# Proxy API funcionando
curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost/api/

# SSL (se configurado)
curl -Is https://seudominio.com.br/ | head -3

# Redirecionamento HTTP → HTTPS
curl -Is http://seudominio.com.br/ | grep location
```

- [ ] `nginx -t` → syntax ok
- [ ] Frontend retorna HTTP 200
- [ ] Proxy `/api/` funciona
- [ ] SSL ativo com certificado válido *(se domínio configurado)*
- [ ] HTTP redireciona para HTTPS *(se SSL configurado)*

---

### 📡 Integração Mikrotik

```bash
# No servidor — portas acessíveis externamente
sudo ufw status
sudo ss -tlnpu | grep -E '1812|1813'
```

No Mikrotik:
```
# Verificar servidor RADIUS
/radius print

# Verificar hotspot profile
/ip hotspot profile print detail

# Listar sessões ativas
/ip hotspot active print
```

- [ ] Mikrotik consegue pingar o servidor
- [ ] Servidor RADIUS aparece no `/radius print`
- [ ] Hotspot profile com `use-radius=yes`
- [ ] Login pelo portal redireciona corretamente

---

### 🔄 Teste de ponta a ponta

1. Conecte um dispositivo no WiFi gerenciado pelo Mikrotik
2. Abra qualquer site — deve redirecionar para o portal cativo
3. Faça login com `teste` / `senha123`
4. Confirme a sessão:

```bash
# No servidor
mysql -u hotspotuser -psenhaforte123 hotspot \
  -e "SELECT username, framedipaddress, acctstarttime FROM radacct ORDER BY acctstarttime DESC LIMIT 3;"
```

```bash
# Mikrotik
/ip hotspot active print
```

- [ ] Portal cativo carrega corretamente
- [ ] Login com usuário válido libera acesso
- [ ] Login com usuário inválido retorna erro
- [ ] Sessão aparece na tabela `radacct`

---

## 📊 Comandos de monitoramento contínuo

```bash
# Logs do FreeRADIUS em tempo real
sudo tail -f /var/log/freeradius/radius.log

# Logs do NGINX
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Logs do backend
pm2 logs hotspot-api

# Sessões ativas no banco
watch -n5 "mysql -u hotspotuser -psenhaforte123 hotspot \
  -e 'SELECT COUNT(*) AS sessoes_ativas FROM radacct WHERE acctstoptime IS NULL;'"

# Status geral dos serviços
watch -n10 "systemctl is-active mysql freeradius nginx"
```

---

## 🧪 Teste de carga básico

```bash
# Instalar ferramenta de teste
sudo apt install -y freeradius-utils

# Múltiplos testes de autenticação
for i in {1..10}; do
  radtest teste senha123 localhost 0 testing123 2>&1 | grep -c "Accept"
done
```

---

## ✅ Resultado esperado — sistema 100% operacional

| Componente | Status esperado |
|-----------|----------------|
| MySQL | `active (running)` |
| FreeRADIUS | `active (running)` |
| NGINX | `active (running)` |
| PM2 hotspot-api | `online` |
| Portas 1812/1813 | Em escuta (UDP) |
| Porta 80/443 | Em escuta (TCP) |
| radtest | `Access-Accept` |
| Portal cativo | Carregando |
| Login real | Funcionando |

---

## ➡️ Próximas etapas

→ **[07-troubleshooting.md](./07-troubleshooting.md)** — Se algo não funcionou  
→ **[08-seguranca-producao.md](./08-seguranca-producao.md)** — Hardening para produção
