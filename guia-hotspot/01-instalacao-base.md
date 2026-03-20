# 01 · Instalação Base

> **Script:** `install-1.sh`  
> **Tempo estimado:** ~10 minutos  
> **Pré-requisito:** Ubuntu Server 22.04+ limpo com acesso root

---

## 📋 O que este script faz

```
[1] Atualiza o sistema         apt update && apt upgrade -y
[2] Instala pacotes base       nginx, mysql-server, freeradius,
                               freeradius-mysql, nodejs, npm,
                               git, unzip, curl
[3] Cria banco de dados        hotspot (UTF8MB4)
[4] Cria usuário MySQL         hotspotuser / senhaforte123
[5] Cria diretórios            /var/www/hotspot
[6] Habilita serviços          mysql, freeradius, nginx no boot
```

---

## ▶️ Como executar

### Passo 1 — Enviar o script para o servidor

```bash
# Do seu computador local
scp install-1.sh usuario@IP_DO_SERVIDOR:~/
```

### Passo 2 — Conectar ao servidor

```bash
ssh usuario@IP_DO_SERVIDOR
```

### Passo 3 — Executar

```bash
chmod +x install-1.sh
sudo bash install-1.sh
```

> 💡 O processo pode levar alguns minutos dependendo da velocidade da internet do servidor.

---

## 🔍 Verificação pós-instalação

Execute cada comando e compare com o resultado esperado:

### Versões instaladas

```bash
node -v
```
```
v18.x.x  (ou superior)
```

```bash
npm -v
```
```
9.x.x  (ou superior)
```

```bash
mysql --version
```
```
mysql  Ver 8.0.x  Distrib 8.0.x, for Linux (x86_64)
```

```bash
freeradius -v
```
```
radiusd: FreeRADIUS Version 3.2.5 ...
```

---

### Status dos serviços

```bash
systemctl status mysql freeradius nginx
```

Todos devem mostrar:
```
Active: active (running)
```

---

### Banco de dados criado

```bash
mysql -u hotspotuser -psenhaforte123 -e "SHOW DATABASES;"
```

```
+--------------------+
| Database           |
+--------------------+
| hotspot            |
+--------------------+
```

---

## ⚙️ O que o script cria no MySQL

```sql
CREATE DATABASE IF NOT EXISTS hotspot
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'hotspotuser'@'localhost'
  IDENTIFIED BY 'senhaforte123';

GRANT ALL PRIVILEGES ON hotspot.* TO 'hotspotuser'@'localhost';
```

---

## ❗ Problemas comuns nesta etapa

### `E: Could not get lock /var/lib/dpkg/lock`

```bash
# Aguarde ou force:
sudo killall apt apt-get
sudo rm /var/lib/dpkg/lock-frontend
sudo dpkg --configure -a
sudo bash install-1.sh
```

### `Job for freeradius.service failed`

Pode ocorrer na primeira vez — é esperado. O FreeRADIUS precisa ser configurado antes de iniciar corretamente. Prossiga para a próxima etapa.

### `mysql: command not found`

```bash
sudo apt install -y mysql-client
```

---

## ✅ Checklist desta etapa

- [ ] `node -v` retorna v18+
- [ ] `mysql --version` retorna 8.x
- [ ] `freeradius -v` retorna 3.2.5
- [ ] `systemctl status mysql` → `active (running)`
- [ ] `systemctl status nginx` → `active (running)`
- [ ] Banco `hotspot` criado e acessível com `hotspotuser`

---

## ➡️ Próxima etapa

→ **[02-deploy-sistema.md](./02-deploy-sistema.md)** — Executar o `install-2.sh`
