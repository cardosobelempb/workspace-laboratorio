# Exemplo Prático — Revisão Completa do Módulo 1
**LAB direto ao ponto — Comandos reais RouterOS v7**

> Este exemplo segue o cenário do curso: roteador `mikrotik-001`, com 4 redes locais (geral, financeiro, servidores, visitantes), bloqueio entre redes e link de internet via CPE roteada (DHCP client).
>
> 💡 Execute os blocos em sequência, via **Terminal** (New Terminal no Winbox) ou SSH. Ajuste interfaces/IPs conforme seu hardware real.

### Convenção de nomenclatura adotada

Em ambiente de produção, evite CamelCase ou misturar maiúsculas/minúsculas em nomes de interface, identidade ou objetos do RouterOS. É prática consolidada no mercado (e evita erro de digitação em script/Terminal, já que o RouterOS é *case-sensitive*) usar:

- **Tudo em minúsculo**
- **Palavras separadas por hífen** (`kebab-case`)
- **Prefixo indicando a função** (`wan-`, `lan-`, `vlan-`, `pool-`, `dhcp-`)

Exemplos: `ether1-wan-operadora`, `ether3-lan-servidores`, `pool-financeiro`, `dhcp-visitantes`.

---

## 1. Ativar RoMON

```bash
/tool romon
set enabled=yes
secrets=cursomikrotik
```

**Verificação:**
```bash
/tool romon print
```

---

## 2. Identificar roteador e interfaces

```bash
# Renomear o roteador (identity)
/system identity
set name="mikrotik-001"

# Renomear as interfaces para facilitar a administracao
/interface ethernet
set [find default-name=ether1] name=ether1-wan-operadora
set [find default-name=ether2] name=ether2-lan-geral
set [find default-name=ether3] name=ether3-ether3-lan-financeiro
set [find default-name=ether4] name=ether4-lan-servidores
set [find default-name=ether5] name=ether5-lan-visitantes
```

**Verificação:**
```bash
/interface print
/system identity print
```

---

## 3. Configurar rede local com DHCP Server

```bash
# IP na interface de LAN geral
/ip address
add address=192.168.1.1/24 interface=ether2-lan-geral

# Pool de enderecos
/ip pool
add name=pool-ether2-lan-geral ranges=192.168.1.10-192.168.1.254

# DHCP Server
/ip dhcp-server
add name=dhcp-ether2-lan-geral interface=ether2-lan-geral address-pool=pool-ether2-lan-geral disabled=no

/ip dhcp-server network
add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=8.8.8.8,1.1.1.1
```

**Verificação:**
```bash
/ip dhcp-server print
/ip dhcp-server lease print
```

---

## 4. Ativar link de internet e NAT

> Exemplo para **CPE Roteada** (DHCP Client na WAN). Se for CPE em Bridge com PPPoE, veja a variação no final desta seção.

```bash
# DHCP Client na interface WAN
/ip dhcp-client
add interface=ether1-wan-operadora disabled=no add-default-route=yes use-peer-dns=no

# NAT (masquerade) para a interface WAN
/ip firewall nat
add chain=srcnat out-interface=ether1-wan-operadora action=masquerade comment="nat - saida internet"
```

**Verificação:**
```bash
/ip dhcp-client print
/ip route print
/ping 8.8.8.8 count=4
```

> 🔁 **Variação — CPE em bridge com PPPoE client:**
> ```bash
> /interface pppoe-client
> add name=pppoe-out1 interface=ether1-wan-operadora user=publico password=123 \
>     disabled=no add-default-route=yes use-peer-dns=no
>
> /ip firewall nat
> add chain=srcnat out-interface=pppoe-out1 action=masquerade comment="nat - pppoe"
> ```

---

## 5. Colocar outras redes locais

```bash
# Rede financeiro - 192.168.2.0/24
/ip address
add address=192.168.2.1/24 interface=-ether3-lan-financeiro
/ip pool
add name=pool-financeiro ranges=192.168.2.10-192.168.2.254
/ip dhcp-server
add name=dhcp-financeiro interface=ether3-lan-financeiro address-pool=pool-financeiro disabled=no
/ip dhcp-server network
add address=192.168.2.0/24 gateway=192.168.2.1 dns-server=8.8.8.8,1.1.1.1

# Rede servidores - 192.168.3.0/24
/ip address
add address=192.168.3.1/24 interface=ether4-lan-servidores
/ip pool
add name=pool-servidores ranges=192.168.3.10-192.168.3.254
/ip dhcp-server
add name=dhcp-servidores interface=ether3-lan-servidores address-pool=pool-servidores disabled=no
/ip dhcp-server network
add address=192.168.3.0/24 gateway=192.168.3.1 dns-server=8.8.8.8,1.1.1.1

# Rede visitantes - 192.168.4.0/24
/ip address
add address=192.168.4.1/24 interface=ether5-lan-visitantes
/ip pool
add name=pool-visitantes ranges=192.168.4.10-192.168.4.254
/ip dhcp-server
add name=dhcp-visitantes interface=ether5-lan-visitantes address-pool=pool-visitantes disabled=no
/ip dhcp-server network
add address=192.168.4.0/24 gateway=192.168.4.1 dns-server=8.8.8.8,1.1.1.1
```

**Verificação:**
```bash
/ip address print
/ip dhcp-server network print
```

---

## 6. Bloquear acesso à rede de servidores

> Regra colocada **antes** do NAT/forward geral, na cadeia `forward`. Bloqueia Financeiro e Visitantes acessando Servidores, mas mantém Servidores podendo acessar a internet normalmente.

```bash
/ip firewall filter
add chain=forward src-address=192.168.4.0/24 dst-address=192.168.3.0/24 \
    action=drop comment="bloqueia visitantes para servidores"

add chain=forward src-address=192.168.2.0/24 dst-address=192.168.3.0/24 \
    action=drop comment="bloqueia financeiro para servidores"

# (Opcional) Bloquear visitantes acessando qualquer rede interna, nao so servidores
add chain=forward src-address=192.168.4.0/24 dst-address=192.168.0.0/16 \
    action=drop comment="bloqueia visitantes para todas redes internas"
```

> ⚠️ A ordem das regras importa: estas regras de bloqueio devem ficar **antes** de qualquer regra genérica de `accept` no forward.

**Verificação:**
```bash
/ip firewall filter print
# Teste prático: do VPC na rede Visitantes, tente pingar um IP da rede Servidores (deve falhar)
```

---

## 7. Aplicar ajustes básicos de segurança

```bash
# 7.1 - Trocar usuario e senha padrao
/user
add name=admin-rb group=full password="rb#2026-acesso!seguro"
disable [find name=admin]

# 7.2 - IP Services: restringir e desabilitar o que nao usa
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set winbox address=192.168.1.0/24,192.168.2.0/24
set ssh address=192.168.1.0/24,192.168.2.0/24 port=22

# 7.3 - Restringir MAC Telnet / MAC Winbox (via interface list)
/interface list
add name=lista-gerencia
/interface list member
add list=lista-gerencia interface=ether2-lan-geral
add list=lista-gerencia interface=ether3-lan-financeiro

/tool mac-server
set allowed-interface-list=lista-gerencia
/tool mac-server mac-winbox
set allowed-interface-list=lista-gerencia

# 7.4 - MNDP: limitar a rede de gerencia (evita "exposicao" do roteador)
/ip neighbor discovery-settings
set discover-interface-list=lista-gerencia

# 7.5 - Bonus: regra basica de protecao do input (drop geral por ultimo!)
/ip firewall filter
add chain=input connection-state=established,related action=accept comment="aceita estabelecidas e relacionadas"
add chain=input src-address=192.168.1.0/24 action=accept comment="aceita rede de suporte e gerencia"
add chain=input protocol=icmp action=accept comment="aceita icmp controlado"
add chain=input action=drop comment="drop geral - manter por ultimo"
```

> ⚠️ **Cuidado:** teste a regra de drop geral do INPUT com uma sessão Winbox/SSH **já aberta** antes de aplicar — se algo sair errado, você ainda terá acesso para corrigir.

**Verificação:**
```bash
/ip service print
/user print
/ip firewall filter print
```

---

## 8. Exportar backup de configuração e de scripts

```bash
# 8.1 - Backup binario completo (.backup) - inclui tudo, inclusive senhas, nao editavel
/system backup save name=mikrotik-001-backup-completo

# 8.2 - Export em script (.rsc) - editavel, sem dados sensiveis
/export file=mikrotik-001-export

# 8.3 - Export incluindo dados sensiveis (senhas, secrets) - use com cautela
/export show-sensitive file=mikrotik-001-export-sensitive

# 8.4 - Verificar os arquivos gerados
/file print
```

**Baixando os arquivos:**
- Via **Winbox**: menu `Files` → arraste o arquivo para o seu computador
- Via **FTP/SFTP**: conecte-se ao roteador e copie os arquivos da raiz
- Via **script automático para Telegram** (bot da Redes Brasil):
  ```bash
  # Exemplo de chamada simplificada ao bot (ajuste conforme a doc do bot)
  # https://t.me/RedesBrasilBackups_bot
  /tool fetch url="https://api.telegram.org/botSEU_TOKEN/sendDocument" \
      http-method=post http-data="chat_id=SEU_CHAT_ID" \
      src-path=mikrotik-001-backup-completo.backup
  ```

> 📅 **Boa prática:** agende isso via `/system scheduler` para rodar automaticamente todo dia ou toda semana.

```bash
/system scheduler
add name=backup-semanal interval=7d start-time=03:00:00 \
    on-event="/system backup save name=(\"backup-\" . [/system clock get date])"
```

---

## ✅ Checklist final de verificação

| # | Passo | Comando de verificação |
|---|---|---|
| 1 | RoMON ativo | `/tool romon print` |
| 2 | Identidade e interfaces renomeadas | `/system identity print` |
| 3 | DHCP Server na rede geral funcionando | `/ip dhcp-server lease print` |
| 4 | Internet ativa (ping externo OK) | `/ping 8.8.8.8` |
| 5 | 4 redes locais com IP e DHCP | `/ip address print` |
| 6 | Bloqueio entre redes testado | `/ip firewall filter print` |
| 7 | Usuário/senha trocados e serviços restritos | `/ip service print` |
| 8 | Backup e export gerados | `/file print` |

---

*Exemplo prático complementar ao "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*