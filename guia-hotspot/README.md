# 📡 Sistema Hotspot — Guia de Instalação Completo

> **Stack:** Ubuntu Server 22.04+ · FreeRADIUS 3.2.5 · MySQL 8.x · Node.js · NGINX · Mikrotik RouterOS

---

## 📋 Índice de Etapas

| # | Arquivo | Descrição | Tempo estimado |
|---|---------|-----------|----------------|
| 00 | [00-arquitetura.md](./00-arquitetura.md) | Visão geral do sistema e pré-requisitos | Leitura |
| 01 | [01-instalacao-base.md](./01-instalacao-base.md) | Instalação dos pacotes e banco de dados | ~10 min |
| 02 | [02-deploy-sistema.md](./02-deploy-sistema.md) | Deploy do hotspot, PM2, NGINX e frontend | ~15 min |
| 03 | [03-freeradius.md](./03-freeradius.md) | Configuração completa do FreeRADIUS + MySQL | ~20 min |
| 04 | [04-mikrotik.md](./04-mikrotik.md) | Integração RADIUS com Mikrotik RouterOS | ~15 min |
| 05 | [05-ssl-dominio.md](./05-ssl-dominio.md) | SSL/HTTPS com Let's Encrypt e domínio | ~10 min |
| 06 | [06-testes-validacao.md](./06-testes-validacao.md) | Checklist de testes e validação final | ~10 min |
| 07 | [07-troubleshooting.md](./07-troubleshooting.md) | Erros conhecidos e como resolver | Referência |
| 08 | [08-seguranca-producao.md](./08-seguranca-producao.md) | Hardening, firewall, backup e produção | ~15 min |

---

## ⚡ Início Rápido

```bash
# 1. Servidor limpo — instalar base
sudo bash install-1.sh

# 2. Com freeradius.zip e hotspot.zip no diretório
sudo bash install-2.sh

# 3. Configurar FreeRADIUS (ver 03-freeradius.md)

# 4. Configurar Mikrotik (ver 04-mikrotik.md)

# 5. SSL com domínio (opcional)
sudo bash Install-3_dominio.sh
```

---

## 🏗️ Arquitetura Resumida

```
Cliente WiFi
    │
    ▼
┌─────────────┐     RADIUS Auth/Acct      ┌──────────────────┐
│   Mikrotik  │ ──────────────────────── ▶│   FreeRADIUS     │
│  RouterOS   │◀── Accept / Reject ───────│   porta 1812/13  │
└─────────────┘                           └────────┬─────────┘
                                                   │ SQL
                                          ┌────────▼─────────┐
                                          │     MySQL 8.x    │
                                          │  DB: hotspot     │
                                          └────────┬─────────┘
                                                   │
                                          ┌────────▼─────────┐
                                          │   Node.js API    │◀── NGINX (80/443)
                                          │   PM2 :3001      │
                                          └──────────────────┘
```

---

## 📁 Estrutura de Arquivos no Servidor

```
/var/www/hotspot/
├── backend/
│   ├── server.js
│   ├── jobs/
│   │   └── estrutura.sql
│   └── ...
└── frontend/
    ├── dist/         ← Build servido pelo NGINX
    └── ...

/etc/freeradius/3.0/
├── mods-available/sql
├── mods-enabled/sql  ← symlink
└── sites-enabled/default
```

---

## ⚠️ Antes de Começar

- [ ] Ubuntu Server 22.04 LTS instalado e atualizado
- [ ] Acesso root ou sudo configurado
- [ ] IP fixo no servidor
- [ ] Arquivos `freeradius.zip` e `hotspot.zip` disponíveis
- [ ] Portas `1812/UDP` e `1813/UDP` liberadas no firewall

---

> 💡 **Dica:** Siga os arquivos na ordem numérica. Cada etapa depende da anterior.
