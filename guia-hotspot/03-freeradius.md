# 03 · Configuração do FreeRADIUS

> **Tempo estimado:** ~20 minutos  
> **Pré-requisito:** Etapa 02 concluída  
> **Arquivos editados:**
> - `/etc/freeradius/3.0/mods-available/sql`
> - `/etc/freeradius/3.0/sites-enabled/default`

---

## 📁 Estrutura de arquivos relevantes

```
/etc/freeradius/3.0/
├── mods-available/
│   └── sql                ← Config da conexão MySQL
├── mods-enabled/
│   └── sql -> ../mods-available/sql   ← Symlink (deve existir)
└── sites-enabled/
    ├── default            ← Virtual server principal
    └── inner-tunnel       ← EAP inner tunnel (porta 18120)
```

---

## 1️⃣ Módulo SQL — `mods-available/sql`

### Abrir o arquivo

```bash
sudo nano /etc/freeradius/3.0/mods-available/sql
```

### Conteúdo correto e completo

```
sql {
  driver  = "rlm_sql_mysql"
  dialect = "mysql"

  # ── Conexão ──────────────────────────────────────────
  server    = "localhost"
  port      = 3306
  login     = "hotspotuser"
  password  = "senhaforte123"
  radius_db = "hotspot"

  # ── Tabelas ──────────────────────────────────────────
  read_clients      = yes
  client_table      = "nas"
  acct_table1       = "radacct"
  acct_table2       = "radacct"
  postauth_table    = "radpostauth"
  authcheck_table   = "radcheck"
  groupcheck_table  = "radgroupcheck"
  authreply_table   = "radreply"
  groupreply_table  = "radgroupreply"
  usergroup_table   = "radusergroup"
  delete_stale_sessions = yes

  # ── Driver MySQL ─────────────────────────────────────
  # Resolve: WARNING: MYSQL_OPT_RECONNECT is deprecated
  mysql {
    warnings                    = no
    connect_failure_retry_delay = 60
  }

  # ── Pool de conexões ─────────────────────────────────
  pool {
    start        = ${thread[pool].start_servers}
    min          = ${thread[pool].min_spare_servers}
    max          = ${thread[pool].max_servers}
    spare        = ${thread[pool].max_spare_servers}
    uses         = 0
    retry_delay  = 30
    lifetime     = 3600   # recria conexão a cada 1h
    idle_timeout = 60     # fecha conexões ociosas
    max_retries  = 5
  }

  group_attribute = "SQL-Group"
  $INCLUDE ${modconfdir}/${.:name}/main/${dialect}/queries.conf
}
```

> ⚠️ **Importante:** O bloco `mysql { warnings = no }` é o que resolve o warning  
> `MYSQL_OPT_RECONNECT is deprecated` que aparece com MySQL 8.x.

---

### Verificar symlink do módulo

```bash
ls -la /etc/freeradius/3.0/mods-enabled/sql
```

Se não existir, crie:

```bash
sudo ln -sf /etc/freeradius/3.0/mods-available/sql \
            /etc/freeradius/3.0/mods-enabled/sql
```

---

## 2️⃣ Virtual Server — `sites-enabled/default`

### Abrir o arquivo

```bash
sudo nano /etc/freeradius/3.0/sites-enabled/default
```

### Conteúdo correto e completo

```
server default {

    # ── Listeners ────────────────────────────────────────
    listen {
        type   = auth
        ipaddr = *
        port   = 1812
    }

    listen {
        type   = acct
        ipaddr = *
        port   = 1813
    }

    # ── Autorização ──────────────────────────────────────
    authorize {
        preprocess
        chap
        mschap
        suffix
        sql
        files
        dailycounter

        # Verificação de limite diário de sessão
        if ("%{control:Max-Daily-Session}" && \
            "%{control:Daily-Session-Time}" >= "%{control:Max-Daily-Session}") {
            update control {
                Auth-Type := Reject
            }
            reject
        }

        pap
    }

    # ── Autenticação ─────────────────────────────────────
    authenticate {
        Auth-Type CHAP {
            chap
        }
        Auth-Type MS-CHAP {
            mschap
        }
        Auth-Type PAP {
            pap
        }
    }

    # ── Pré-contabilidade ────────────────────────────────
    preacct {
        preprocess
        acct_unique
        suffix
        files
    }

    # ── Contabilidade ────────────────────────────────────
    accounting {
        sql
        exec
        attr_filter.accounting_response
    }

    # ── Sessão ───────────────────────────────────────────
    session {
        sql
    }

    # ── Pós-autenticação ─────────────────────────────────
    post-auth {
        sql
        exec
        remove_reply_message_if_eap

        Post-Auth-Type REJECT {
            attr_filter.access_reject
            sql
            update reply {
                Reply-Message := "Acesso negado. Verifique suas credenciais."
            }
        }
    }

    pre-proxy  { }
    post-proxy { }
}
```

> ⚠️ **Atenção:** O bloco `sql { driver = ... }` de configuração do banco  
> **NÃO deve existir** dentro do `sites-enabled/default`.  
> Ele pertence **exclusivamente** ao `mods-available/sql`.

---

## 3️⃣ Senhas no banco — Cleartext-Password

Para que o FreeRADIUS consiga autenticar, o atributo de senha no banco deve ser `Cleartext-Password`.

### Verificar como estão os atributos

```bash
mysql -u hotspotuser -psenhaforte123 hotspot \
  -e "SELECT username, attribute FROM radcheck LIMIT 10;"
```

### Se estiver como MD5-Password, SHA-Password etc., corrija

```sql
mysql -u hotspotuser -psenhaforte123 hotspot

UPDATE radcheck
SET attribute = 'Cleartext-Password'
WHERE attribute IN ('MD5-Password', 'SHA-Password', 'Crypt-Password');
```

### Inserir um usuário de teste

```sql
INSERT INTO radcheck (username, attribute, op, value)
VALUES ('teste', 'Cleartext-Password', ':=', 'senha123');
```

---

## 4️⃣ Aplicar e validar

### Validar configuração

```bash
sudo freeradius -XC
```

Saída esperada no final:
```
...
Configuration appears to be OK
```

### Reiniciar o serviço

```bash
sudo systemctl restart freeradius
sudo systemctl status freeradius
```

### Confirmar que o warning sumiu

```bash
sudo freeradius -X 2>&1 | grep -i reconnect
# Não deve retornar nada
```

---

## 5️⃣ Teste rápido de autenticação

```bash
radtest teste senha123 localhost 0 testing123
```

### Sucesso ✅
```
Received Access-Accept Id 0 from 127.0.0.1:1812
```

### Falha ❌
```
Received Access-Reject Id 0 from 127.0.0.1:1812
```

Se receber `Access-Reject`, rode em modo debug para ver o motivo:

```bash
sudo systemctl stop freeradius
sudo freeradius -X &
radtest teste senha123 localhost 0 testing123
```

Procure por linhas `ERROR:` ou `WARN:` na saída.

---

## 📊 Referência de atributos úteis no radcheck

| Atributo | Operador | Exemplo de valor | Descrição |
|----------|----------|-----------------|-----------|
| `Cleartext-Password` | `:=` | `minhasenha` | Senha em texto puro |
| `Max-All-Session` | `:=` | `3600` | Tempo máximo total (segundos) |
| `Session-Timeout` | `:=` | `3600` | Timeout por sessão |
| `Simultaneous-Use` | `:=` | `1` | Máximo de sessões simultâneas |
| `Expiration` | `:=` | `01 Jan 2026` | Data de expiração da conta |

---

## ✅ Checklist desta etapa

- [ ] `mods-available/sql` com bloco `mysql { warnings = no }`
- [ ] `mods-enabled/sql` symlink existe
- [ ] `sites-enabled/default` sem bloco sql interno
- [ ] Atributo `Cleartext-Password` no radcheck
- [ ] `freeradius -XC` retorna `Configuration appears to be OK`
- [ ] `systemctl status freeradius` → `active (running)`
- [ ] `radtest` retorna `Access-Accept`

---

## ➡️ Próxima etapa

→ **[04-mikrotik.md](./04-mikrotik.md)** — Integração RADIUS com o Mikrotik
