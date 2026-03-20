# 04 · Integração com Mikrotik

> **Tempo estimado:** ~15 minutos  
> **Pré-requisito:** Etapa 03 concluída — FreeRADIUS operacional  
> **Ferramentas:** WinBox, SSH ou terminal web do Mikrotik

---

## 🗺️ Visão geral da integração

```
                    ┌─────────────────────────────┐
                    │         Mikrotik            │
  Cliente WiFi ────▶│  Hotspot Server             │
                    │  NAS-IP: 192.168.1.1        │
                    └────────────┬────────────────┘
                                 │ RADIUS Request (UDP 1812)
                                 │ secret: SUA_SENHA_SECRETA
                                 ▼
                    ┌─────────────────────────────┐
                    │      Servidor Ubuntu        │
                    │  FreeRADIUS :1812/:1813     │
                    │  IP: 192.168.1.100          │
                    └────────────┬────────────────┘
                                 │ SQL query
                                 ▼
                    ┌─────────────────────────────┐
                    │      MySQL — hotspot        │
                    │  tabela: radcheck / nas     │
                    └─────────────────────────────┘
```

---

## 1️⃣ Cadastrar o NAS no banco de dados

O FreeRADIUS só aceita requisições de NAS registrados na tabela `nas`.  
Substitua os valores pelos seus dados reais:

```bash
mysql -u hotspotuser -psenhaforte123 hotspot
```

```sql
INSERT INTO nas (nasname, shortname, type, secret, description)
VALUES (
  '192.168.1.1',          -- IP da interface do Mikrotik
  'mikrotik-principal',   -- Nome identificador
  'other',                -- Tipo (other = genérico)
  'SUA_SENHA_SECRETA',    -- Secret RADIUS (defina um valor forte)
  'Roteador Principal'
);
```

> 💡 O valor do `secret` precisa ser **idêntico** ao configurado no Mikrotik.  
> Exemplo seguro: `xK9#mP2$vL7@nQ4!wR6`

---

## 2️⃣ Configurar o servidor RADIUS no Mikrotik

### Via WinBox

```
Menu: RADIUS → botão Add (+)
```

| Campo | Valor |
|-------|-------|
| **Service** | ✅ hotspot |
| **Address** | IP do servidor Ubuntu (ex: `192.168.1.100`) |
| **Secret** | Mesmo valor inserido no banco (`SUA_SENHA_SECRETA`) |
| **Authentication Port** | `1812` |
| **Accounting Port** | `1813` |
| **Timeout** | `3000` (ms) |

### Via Terminal / SSH

```
/radius add \
  service=hotspot \
  address=192.168.1.100 \
  secret=SUA_SENHA_SECRETA \
  authentication-port=1812 \
  accounting-port=1813 \
  timeout=3000ms
```

### Verificar se foi adicionado

```
/radius print
```

```
Flags: X - disabled
 #   SERVICE   ADDRESS          SECRET
 0   hotspot   192.168.1.100    SUA_SENHA_SECRETA
```

---

## 3️⃣ Configurar o Hotspot Server Profile

### Via WinBox

```
Menu: IP → Hotspot → Server Profiles → selecione o perfil → aba RADIUS
```

| Campo | Valor |
|-------|-------|
| **Use RADIUS** | ✅ yes |
| **Accounting** | ✅ yes |
| **Interim Update** | `00:05:00` |
| **NAS Port Type** | `wireless-802.11` (ou `ethernet`) |

### Via Terminal

```
/ip hotspot profile set [find] \
  use-radius=yes \
  radius-accounting=yes \
  radius-interim-update=5m
```

### Verificar

```
/ip hotspot profile print detail
```

Procure por:
```
use-radius: yes
radius-accounting: yes
radius-interim-update: 5m
```

---

## 4️⃣ Protocolo de autenticação — PAP vs CHAP

| Protocolo | Como funciona | Requisito no banco | Recomendado? |
|-----------|--------------|-------------------|--------------|
| **PAP** | Senha em texto simples na requisição | `Cleartext-Password` | ✅ Com HTTPS |
| **CHAP** | Hash MD5 da senha | `Cleartext-Password` obrigatório | ⚠️ Sem ganho real |
| **MS-CHAP** | Hash Microsoft | `Cleartext-Password` obrigatório | ❌ Para hotspot web |

> ✅ **Recomendação:** Use **PAP com HTTPS ativo**. O canal já está criptografado pelo TLS,  
> então o PAP é seguro e mais simples de configurar.

### Forçar PAP no Mikrotik

```
/ip hotspot profile set [find] login-by=http-pap
```

---

## 5️⃣ Verificar conectividade RADIUS

### No servidor Ubuntu

```bash
# Verificar se as portas estão abertas e ouvindo
sudo ss -tlnpu | grep -E '1812|1813'
```

```
udp   UNCONN  0  0  0.0.0.0:1812  0.0.0.0:*  users:(("freeradius",...))
udp   UNCONN  0  0  0.0.0.0:1813  0.0.0.0:*  users:(("freeradius",...))
```

### Teste de autenticação a partir do Mikrotik

```
/radius test \
  name=0 \
  username=teste \
  password=senha123
```

Resposta esperada:
```
reply: Access-Accept
```

### Teste com `radtest` no servidor

```bash
# Simula uma requisição do NAS (Mikrotik)
radtest teste senha123 localhost 0 testing123
```

---

## 6️⃣ Configurar Hotspot Server (interface)

### Via WinBox

```
Menu: IP → Hotspot → Servers → Add (+)
```

| Campo | Valor |
|-------|-------|
| **Interface** | Interface dos clientes (ex: `bridge-local`) |
| **Address Pool** | Pool de IPs dos clientes |
| **Profile** | Perfil com RADIUS habilitado (etapa 3) |
| **DNS Name** | Opcional (ex: `hotspot.local`) |

### Via Terminal

```
/ip hotspot add \
  interface=bridge-local \
  address-pool=pool-hotspot \
  profile=hsprof1 \
  name=hotspot1
```

---

## 7️⃣ Validar sessão completa

### Teste de ponta a ponta

1. Conecte um dispositivo no WiFi do Mikrotik
2. Abra o navegador — deve redirecionar para o portal
3. Faça login com o usuário `teste` / `senha123` (criado na etapa 03)
4. Verifique a sessão no FreeRADIUS:

```bash
mysql -u hotspotuser -psenhaforte123 hotspot \
  -e "SELECT username, acctstarttime, acctstoptime, framedipaddress FROM radacct ORDER BY acctstarttime DESC LIMIT 5;"
```

5. Verifique a sessão no Mikrotik:

```
/ip hotspot active print
```

---

## ❗ Problemas comuns

### Access-Reject — usuário correto

```bash
# Debug no servidor
sudo systemctl stop freeradius
sudo freeradius -X 2>&1 | grep -A5 "Auth:"
```

Causas comuns:
- `secret` diferente entre banco e Mikrotik
- `nasname` na tabela `nas` não bate com o IP do Mikrotik
- Atributo `Cleartext-Password` ausente no `radcheck`

### Timeout na autenticação

```bash
# Verificar firewall no servidor
sudo ufw status
# Se ativo, liberar:
sudo ufw allow 1812/udp
sudo ufw allow 1813/udp
```

### Mikrotik não encontra o servidor

```
/ping 192.168.1.100   # No terminal do Mikrotik
```

Se não pingar, verifique roteamento e firewall entre os dois equipamentos.

---

## ✅ Checklist desta etapa

- [ ] NAS cadastrado na tabela `nas` com o IP do Mikrotik
- [ ] Servidor RADIUS adicionado no Mikrotik (porta 1812/1813)
- [ ] Secret igual no banco e no Mikrotik
- [ ] Hotspot Server Profile com `use-radius=yes`
- [ ] `ss -tlnpu` mostra FreeRADIUS nas portas 1812 e 1813
- [ ] `radtest` retorna `Access-Accept`
- [ ] Teste real de login pelo portal funciona

---

## ➡️ Próxima etapa

→ **[05-ssl-dominio.md](./05-ssl-dominio.md)** — Configurar HTTPS com domínio
