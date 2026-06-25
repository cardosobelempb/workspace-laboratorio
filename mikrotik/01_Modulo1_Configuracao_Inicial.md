# Módulo 1 — Configuração Inicial
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Configuração inicial para empresas (1 rede, múltiplas redes)
- Acesso remoto ao roteador (CGNAT, Cloud)
- Bloqueio entre redes (firewall básico)
- Ajustes de segurança (NTP, Services, MNDP, MAC Telnet)
- Backup completo
- Template de configuração padrão

---

## 1. Conceitos prévios

### CPE Bridge x Roteada
| Tipo | Comportamento |
|---|---|
| **CPE em Bridge** | Repassa tudo (DHCP, PPPoE, IP fixo) direto para o MikroTik |
| **CPE Roteada** | As informações de rede da operadora ficam retidas na própria CPE |

### IP Público x IP de CGNAT
- **IPs privados (não públicos):** `10.0.0.0/8`, `192.168.0.0/16`, `172.16.0.0/12`
- **IPs de CGNAT (não públicos):** `100.64.0.0/10`
- **Tudo o mais** é considerado IP público (ex.: `200.10.16.247`, `8.8.8.8`, `1.1.1.1`)

### Objetivos ao trabalhar com IP Público x CGNAT
1. Acessar o MikroTik remotamente
2. Acessar serviço dentro da rede do cliente

Cenários possíveis:
- CPE em Bridge e IP Público no MikroTik
- CPE em Bridge e IP de CGNAT no MikroTik
- CPE Roteada e com IP Público
- CPE Roteada e com IP de CGNAT

---

## 2. Passo a passo — Configuração Inicial com LAN e DHCP Server

1. **Ativar RoMON**
2. **Colocar IP na interface de LAN**
3. **Criar DHCP Server**
4. **Renomear roteador**
5. **Renomear interfaces**

---

## 3. Ativando o Link de Internet

### Cenário A — CPE Roteada
> As informações de rede recebidas da operadora ficam retidas na CPE.

**Passos para configurar:**
1. Coloque um **DHCP Client** na interface que vai para a CPE da operadora
2. Faça o **NAT**
3. Coloque **IP na interface de LAN**
4. Crie o **DHCP Server** na interface de LAN

### Cenário B — CPE em Bridge
> Você recebe diretamente as informações da operadora no MikroTik.

**Opções de recebimento de WAN:**
- PPPoE Client (ex.: usuário `cgnat/123` ou `publico/123`)
- DHCP Client
- IP fixo e público **sem** VLAN
- IP fixo e público **com** VLAN

**Passos para configurar:**
1. Configure o roteador para receber as informações de WAN de acordo com sua realidade
2. Faça a regra de **NAT** para a interface correta
3. Coloque **IP na interface de LAN**
4. Crie o **DHCP Server** na interface de LAN

---

## 4. Acesso remoto ao roteador — IP Cloud (DDNS)

Caminho no Winbox: `IP > Cloud`

1. Acesse `IP > Cloud`
2. Marque ✅ **DDNS Enabled**
3. O sistema gera automaticamente:
   - **Public Address** (IP público detectado)
   - **DNS Name** (ex.: `hd8081wt5hf.sn.mynetname.net`)

> 💡 Útil principalmente quando o roteador está atrás de **CGNAT** — o DDNS resolve para o IP público mais externo, permitindo acesso remoto via VPN/serviços compatíveis.

---

## 5. Escalando redes locais

### 2 Redes Locais e 1 Link de Internet
- **Rede 1** — Rede interna geral — `192.168.1.0/24`
- **Rede 2** — Rede Financeiro — `192.168.2.0/24`

### 3 Redes Locais (bridge no roteador)
- **Rede 1** — Rede interna geral — `192.168.1.0/24`
- **Rede 2** — Rede Financeiro — `192.168.2.0/24`
- **Rede 3** — Rede Servidores — `192.168.3.0/24`

### 4 Redes Locais (colocando um switch)
- **Rede 1** — Rede interna geral — `192.168.1.0/24`
- **Rede 2** — Rede Financeiro — `192.168.2.0/24`
- **Rede 3** — Rede Servidores — `192.168.3.0/24`
- **Rede 4** — Rede Visitantes — `192.168.4.0/24`

### Bloqueando acesso de uma rede a outra
Com as 4 redes acima criadas, use o **Firewall** para impedir que, por exemplo, a Rede Visitantes (`192.168.4.0/24`) acesse a Rede Servidores (`192.168.3.0/24`) ou a Rede Financeiro (`192.168.2.0/24`).

---

## 6. Ajustes básicos de segurança

- [ ] Trocar **usuário e senha** padrão
- [ ] Configurar **IP Services** (desabilitar serviços não usados, ex.: FTP, Telnet inseguro)
- [ ] Restringir **MAC Telnet**
- [ ] Restringir **MAC Winbox**
- [ ] Ajustar/desabilitar **MNDP** se não for necessário (evita que o roteador "apareça" na rede para descoberta)

---

## 7. Exportando Backup Completo

| Tipo | Característica |
|---|---|
| **Backup comum** (binário) | Arquivo `.backup` completo, não editável, restaura tudo de uma vez |
| **Comando `export`** | Gera script `.rsc`, **editável**, ideal para versionamento |
| **`export show-sensitive`** | Inclui senhas e dados sensíveis no export |

> 📦 Bot do Telegram para automatizar envio de backups: `https://t.me/RedesBrasilBackups_bot`

---

## 8. Criando um Template de Configurações Padrões

Itens essenciais para um template replicável em qualquer roteador novo:

- [ ] Identificação do roteador
- [ ] Usuário e senha
- [ ] RoMON
- [ ] IP Services
- [ ] Lista de interfaces (nomes padronizados)
- [ ] Envio de backup
- [ ] DNS

**Outros itens (configuração de rede):**
- [ ] Identificação das interfaces
- [ ] IPs
- [ ] DHCP Server
- [ ] Firewall
- [ ] NAT
- [ ] Bridges

---

## ✅ Revisão completa — LAB direto ao ponto

Sequência recomendada de execução para fixar o módulo:

1. **Ativar RoMON**
2. **Identificar roteador e interfaces**
3. **Configurar rede local com DHCP Server**
4. **Ativar link de internet e NAT**
5. **Colocar outras redes locais**
6. **Bloquear acesso à rede de servidores**
7. **Aplicar ajustes básicos de segurança**
8. **Exportar backup**

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
