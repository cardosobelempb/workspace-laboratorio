# 00 · Arquitetura e Pré-requisitos

> **Leia antes de executar qualquer script.** Esta seção explica o que cada componente faz e o que você precisa ter em mãos.

---

## 🧱 Componentes do Sistema

| Camada | Tecnologia | Função |
|--------|-----------|--------|
| 🌐 **Frontend** | React + Vite | Portal cativo e painel administrativo |
| ⚙️ **Backend** | Node.js + Express | API REST, vouchers, lógica de negócio |
| 🔑 **AAA** | FreeRADIUS 3.2.5 | Autenticação, Autorização e Contabilidade |
| 🗄️ **Banco** | MySQL 8.x | Usuários, sessões, logs, configurações |
| 🔀 **Proxy** | NGINX | Serve frontend + proxy reverso `/api/` |
| 📡 **NAS** | Mikrotik RouterOS | Envia requisições RADIUS, controla acesso |

---

## 🌐 Fluxo de Autenticação

```
1. Cliente conecta no WiFi do Mikrotik
2. Mikrotik redireciona para portal cativo (NGINX → React)
3. Usuário insere login/senha no portal
4. Backend envia credenciais ao FreeRADIUS via RADIUS
5. FreeRADIUS consulta o MySQL (tabela radcheck)
6. FreeRADIUS responde: Access-Accept ou Access-Reject
7. Mikrotik libera ou bloqueia o acesso à internet
8. Contabilidade (radacct) registra tempo e tráfego
```

---

## 🖥️ Pré-requisitos do Servidor

### Sistema Operacional
```
Ubuntu Server 22.04 LTS  (recomendado)
Ubuntu Server 24.04 LTS  (compatível)
```

### Recursos mínimos

| Recurso | Mínimo | Recomendado (produção) |
|---------|--------|------------------------|
| CPU | 1 vCPU | 2 vCPUs |
| RAM | 2 GB | 4 GB |
| Disco | 20 GB | 40 GB SSD |
| Rede | 1 IP fixo | 1 IP fixo + domínio |

### Portas que devem estar abertas

| Porta | Protocolo | Serviço | Acesso |
|-------|-----------|---------|--------|
| 22 | TCP | SSH | Admin |
| 80 | TCP | HTTP / NGINX | Público |
| 443 | TCP | HTTPS / NGINX | Público |
| 1812 | UDP | RADIUS Auth | Mikrotik → Servidor |
| 1813 | UDP | RADIUS Acct | Mikrotik → Servidor |
| 3306 | TCP | MySQL | Apenas localhost |
| 3001 | TCP | Node.js API | Apenas localhost |

---

## 📡 Pré-requisitos do Mikrotik

- RouterOS **6.48+** ou **7.x**
- Interface configurada na VLAN/rede dos clientes hotspot
- Rota ou conectividade IP com o servidor Ubuntu
- Acesso via **WinBox**, **SSH** ou **terminal web**
- Saber o IP da interface WAN/LAN do Mikrotik

---

## 📦 Arquivos necessários

Antes de executar o `install-2.sh`, você precisará de:

```
freeradius.zip    ← Configurações prontas do FreeRADIUS
hotspot.zip       ← Código do sistema (backend + frontend)
```

> ⚠️ **Esses arquivos devem estar no diretório atual ao executar o `install-2.sh`.**

---

## 🗄️ Banco de Dados — Tabelas RADIUS

| Tabela | Função |
|--------|--------|
| `radcheck` | Credenciais e atributos de verificação dos usuários |
| `radreply` | Atributos retornados ao NAS após autenticação |
| `radgroupcheck` | Atributos de verificação por grupo |
| `radgroupreply` | Atributos de resposta por grupo |
| `radusergroup` | Associação usuário ↔ grupo |
| `radacct` | Contabilidade de sessões (accounting) |
| `radpostauth` | Log de todas as tentativas de autenticação |
| `nas` | Clientes RADIUS autorizados (ex: Mikrotik) |

---

## 🔐 Credenciais padrão pós-instalação

> ⚠️ **Troque todas estas senhas antes de ir para produção!**

| Serviço | Usuário | Senha padrão |
|---------|---------|--------------|
| MySQL | `hotspotuser` | `senhaforte123` |
| MySQL | `root` | *(definida na instalação)* |
| FreeRADIUS test | `testing` | `testing123` |

---

## ➡️ Próxima etapa

→ **[01-instalacao-base.md](./01-instalacao-base.md)** — Executar o `install-1.sh`
