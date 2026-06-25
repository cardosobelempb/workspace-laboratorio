# Guia Passo a Passo — Curso MikroTik RouterOS v7
**Redes Brasil**

> Resumo organizado a partir do material do curso, para te guiar na configuração prática, módulo por módulo.

---

## 📋 Índice

1. [Preparando o Ambiente de LAB](#1-preparando-o-ambiente-de-lab)
2. [Módulo 1 — Configuração Inicial](#módulo-1--configuração-inicial)
3. [Módulo 2 — Configurando um Provedor de Internet](#módulo-2--configurando-um-provedor-de-internet)
4. [Módulo 3 — Firewall](#módulo-3--firewall)
5. [Módulo 4 — VPN](#módulo-4--vpn)
6. [Módulo 5 — OSPF](#módulo-5--ospf)
7. [Módulo 6 — VLANs](#módulo-6--vlans)
8. [Módulo 7 — BGP](#módulo-7--bgp)
9. [Módulo 8 — Wi-Fi](#módulo-8--wi-fi)
10. [Módulo 9 — Extras](#módulo-9--extras)
11. [Tabela de Referência — Operadoras (LAB)](#tabela-de-referência--operadoras-lab)

---

## 1. Preparando o Ambiente de LAB

O curso usa **EVE-NG** como plataforma de laboratório. Você tem 3 caminhos:

### Opção A — LAB em Nuvem (Redes Brasil)
- Rápido e simples, **não consome CPU/RAM/Disco** da sua máquina
- Acesso direto aos roteadores MikroTik
- **Passos:**
  1. Localize o LAB em seu ambiente ou importe-o
  2. Ligue e teste o acesso direto aos roteadores
  3. Faça `ping` do roteador ligado à nuvem para a internet
  4. Baixe e importe as configurações iniciais das operadoras

### Opção B — LAB Local (VM no seu PC)
**Requisitos mínimos:**
- PC 64 bits
- Virtualização ativada na BIOS
- 8 GB RAM (16 GB preferível)
- 4 cores de CPU
- 30 GB de SSD livre

**Passos de instalação:**
1. Baixe e instale o VMware
2. Baixe a VM da Redes Brasil
3. Importe a VM
4. Verifique se a VM pegou IP
5. Verifique se `kvm-ok` está funcionando
6. Acesse o LAB e confirme que os roteadores ligam
7. Instale o **EVE Client Side**
8. Verifique se o roteador pega IP pela nuvem
9. Acesse o roteador da operadora via **Winbox**

> ⚠️ **Problemas comuns na VM (Windows):**
> - Erro de virtualização mesmo com BIOS ativada → pode ser necessário **desabilitar a Integridade de Memória** (Isolamento de núcleo, no Windows 11)
> - Pode ser necessário desabilitar o **Hyper-V**:
>   ```powershell
>   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
>   ```
> - Em "Recursos do Windows", desmarque **"Plataforma de Máquina Virtual"**
> - Notebooks **Dell**: desabilite na BIOS a opção **"SMM Security Mitigation"**

### Opção C — Já tenho EVE-NG rodando
1. Baixe e importe as imagens de roteadores e PCs
2. Baixe e importe o template do laboratório
3. Baixe e importe as configurações iniciais das operadoras
4. Teste se tudo está funcionando
5. Use **Moba Terminal** ou **EVE-Client** (telnet/VNC) e **Winbox** para acessar os equipamentos (há também acesso via **RoMON**)

### Topologia geral do LAB
- 3 operadoras simuladas: **VIVO**, **CLARO** e **GOIAS TECH**
- Estrutura de cliente: `Internet → Roteador da Operadora → CPE → MIKROTIK-001 → VPC-1`
- Rede extra: **Contabilidade Brasil** (usada em exercícios específicos)

---

## Módulo 1 — Configuração Inicial

### Conceitos prévios: CPE Bridge x Roteada
| Tipo | Comportamento |
|---|---|
| **CPE em Bridge** | Repassa tudo (DHCP, PPPoE, IP fixo) direto para o MikroTik |
| **CPE Roteada** | As informações de rede da operadora ficam retidas na própria CPE |

### IP Público x IP de CGNAT (referência rápida)
- **IPs privados (não públicos):** `10.0.0.0/8`, `192.168.0.0/16`, `172.16.0.0/12`
- **IPs de CGNAT (não públicos):** `100.64.0.0/10`
- **Tudo o mais** é considerado IP público

### Passo a passo — Configuração inicial básica (LAN + DHCP)
1. **Ative o RoMON**
2. **Renomeie o roteador** e as **interfaces** (identificação clara)
3. **Configure o link de internet:**
   - Se **CPE Roteada**: coloque DHCP Client na interface da CPE → NAT → IP na LAN → DHCP Server na LAN
   - Se **CPE em Bridge**: configure conforme o tipo de WAN (PPPoE, DHCP, IP fixo com/sem VLAN) → NAT na interface correta → IP na LAN → DHCP Server na LAN
4. **Coloque IP na interface de LAN**
5. **Crie o DHCP Server** na LAN

### Escalando a rede local
- **2 redes locais:** Rede Geral `192.168.1.0/24` + Rede Financeiro `192.168.2.0/24`
- **3 redes locais (com bridge no roteador):** adiciona Rede Servidores `192.168.3.0/24`
- **4 redes locais (com switch):** adiciona Rede Visitantes `192.168.4.0/24`
- **Bloqueio entre redes:** crie regras de **Firewall** para impedir que uma rede acesse a outra (ex.: Visitantes não acessa Servidores)

### Acesso remoto ao roteador
- Configure **IP Cloud (DDNS)**: `IP > Cloud > marcar "DDNS Enabled"` — gera um hostname público mesmo com CGNAT

### Ajustes básicos de segurança
- Trocar **usuário e senha** padrão
- Configurar **IP Services** (desabilitar serviços não usados)
- Restringir **MAC Telnet** e **MAC Winbox**
- Ajustar/desabilitar **MNDP** se não for necessário

### Backup
- **Backup binário** (`.backup`) — completo, mas não editável
- **Comando `export`** — gera script `.rsc` editável
- **`export show-sensitive`** — inclui senhas no export
- Bot do Telegram para backups automáticos: `https://t.me/RedesBrasilBackups_bot`

### Template de configuração padrão (checklist para replicar em novos roteadores)
- [ ] Identificação do roteador
- [ ] Usuário e senha
- [ ] RoMON
- [ ] IP Services
- [ ] Lista/nomes de interfaces
- [ ] Envio de backup
- [ ] DNS
- [ ] IPs, DHCP Server, Firewall, NAT, Bridges

### ✅ Revisão rápida do módulo (ordem de execução)
1. Ativar RoMON
2. Identificar roteador e interfaces
3. Configurar rede local com DHCP Server
4. Ativar link de internet e NAT
5. Adicionar outras redes locais
6. Bloquear acesso entre redes (ex.: servidores)
7. Aplicar ajustes básicos de segurança
8. Exportar backup

---

## Módulo 2 — Configurando um Provedor de Internet

### Passo a passo — PPPoE Server e Client
1. **Criar Pool de endereços** (faixa de IPs para os clientes)
2. **Criar Profile** dentro de `PPP`
3. **Criar usuários** dentro de `PPP`
4. **Criar o PPPoE Server** na interface voltada para os clientes

### RADIUS (integração com MK-AUTH)
**No MK-AUTH:**
1. Cadastrar os roteadores
2. Cadastrar planos
3. Cadastrar usuários

**No MikroTik:**
1. Configurar o RADIUS apontando para o servidor MK-AUTH

### Outros tópicos do módulo (presentes no curso completo)
- Separar PPPoE server do NAT
- Receber bloco de IP público da operadora
- Escolher o IP usado no NAT dos clientes
- Entregar IP público para cliente PPPoE
- Entregar IP público `/30` e `/32`
- Entregar bloco de IP público completo
- Colocar IP público em servidor
- Redirecionamento de portas (com e sem IP público)
- CGNAT

---

## Módulo 3 — Firewall

### Protegendo o próprio roteador (regras de INPUT)
1. ⚠️ **Drop geral** (regra final — cuidado para não se trancar fora)
2. Aceitar conexões **established/related**
3. Aceitar **rede de suporte** (sua rede de gerência)
4. Aceitar **ICMP** de forma controlada
5. Considerar **Port Knocking** (Toc-Toc) para acesso seguro
6. Liberar outras portas somente se necessário

### Firewall para empresas (INPUT + FORWARD)
**INPUT:**
1. Drop geral (cuidado)
2. Aceitar established/related
3. Aceitar rede de suporte
4. Aceitar ICMP controlado
5. Port Knocking

**FORWARD:**
1. Liberar somente o necessário
2. Bloquear todo o restante
3. Aplicar filtro **Anti-Spoofing**
4. Avaliar uso de **fasttrack**

### Exemplos práticos de regras
- Bloquear acesso ao **Winbox**
- Bloquear acesso ao **SSH**
- Bloquear navegação **WEB**
- Bloquear **PING**

### Bloqueando acesso a IPs públicos — 3 cenários
| Caso | Cenário |
|---|---|
| **Case 1** | Todos os clientes com IPs públicos |
| **Case 2** | IPs públicos entregues só para quem contratou |
| **Case 3** | IPs públicos em servidores |

---

## Módulo 4 — VPN

### Preparação básica no roteador da Filial
1. Criar o **PPPoE Server** (ex.: na Claro) na interface da filial
2. Configurar nome do roteador e interfaces
3. Configurar **RoMON** (não necessário se já estiver no LAB em nuvem)
4. Configurar **PPPoE client** e verificar internet
5. Configurar **IP e DHCP Server** na LAN
6. Criar regra de **NAT** e testar `ping` do VPC para a internet

### Passo a passo — WireGuard (Matriz ↔ Filial)
1. **Criar as interfaces WireGuard**
2. **Colocar IP** nas interfaces WireGuard
3. **Criar rotas** nos dois lados
4. **Criar os Peers** do WireGuard nos dois lados

### Configuração WireGuard — Cliente Windows
```ini
[Interface]   ; gerado automaticamente ao criar o peer — não copiar manualmente
PrivateKey = CHAVE_PRIVADA   ; gerado automaticamente — não copiar manualmente
Address = IP_DA_INTERFACE_WIREGUARD/32   ; lembrar do /32

[Peer]
PublicKey = CHAVE_PUBLICA_DO_SERVIDOR_WIREGUARD
AllowedIPs = REDES   ; ex: 10.0.0.0/8, 100.64.0.0/10  |  para navegar tudo pela VPN: 0.0.0.0/0
Endpoint = IP_PÚBLICO:PORTA   ; do servidor WireGuard
```
> 💡 Nota do curso: VPN client nativo do Windows é só para testes — pode ficar lento por causa de atualizações em segundo plano.

### Outros tópicos do módulo
- Interligar matriz e filial com **L2TP**
- Conexão remota com **L2TP**
- Adicionar mais uma filial com WireGuard
- Conexão remota com WireGuard

---

## Módulo 5 — OSPF

### Passo a passo — Ativar OSPF básico
1. **Adicionar os IPs** nas interfaces
2. **Adicionar as interfaces** que participarão do OSPF
3. **Adicionar as interfaces/redes** que precisam ser anunciadas

### Boas práticas de OSPF
- Usar **interfaces PTP** (ponto a ponto) quando aplicável
- **Tirar o OSPF do NAT** (não anunciar redes que já passam por NAT)
- Cuidado com **PPPoEs** dentro do OSPF
- Configurar **interface passiva** onde não há vizinho OSPF
- Usar **senha** nas interfaces OSPF
- Configurar **interface de Loopback**

### Configurando a Loopback
1. Adicionar o **IP** na interface de loopback
2. **Anunciar a loopback** no OSPF
3. Ajustar o **Router ID** de cada roteador (usar o IP da loopback)
4. Usar o **IP de loopback como origem** nas requisições RADIUS

---

## Módulo 6 — VLANs

### Tipos de interface
| Tipo | Também chamada de | Função |
|---|---|---|
| **Tagged** | Trunk | Transporta geralmente mais de uma VLAN |
| **Untagged** | Access | Transporta uma única VLAN — conectada a dispositivo final do usuário |

### Cenários do módulo
1. Configurar VLAN entre o roteador e o switch da empresa (trunk + access)
2. Fazer um **LAN-to-LAN** usando VLANs entre roteadores

---

## Módulo 7 — BGP

### BGP com a VIVO (exemplo do LAB)
- **ASN RB Telecom:** `5050`
- **Prefixo IPv4 anunciado:** `50.50.0.0/22`
- **ASN Vivo:** `20011`
- **IP Vivo:** `200.10.3.1/30`
- **IP RB Telecom:** `200.10.3.2/30`

### BGP com a CLARO (exemplo do LAB)
- **ASN RB Telecom:** `5050`
- **Prefixo IPv4 anunciado:** `50.50.0.0/22`
- **ASN Claro:** `7711`
- **IP Claro:** `77.10.3.1/30`
- **IP RB Telecom:** `77.10.3.2/30`
- **Senha BGP:** `senhabgp`

### Failover e Balanceamento — visão geral
| Cenário | Complexidade |
|---|---|
| Failover de **upload** | Simples — recebe full routing |
| Balanceamento de **upload** | Simples — recebe full routing |
| Failover de **download** | Simples — anuncia o bloco inteiro em todas as operadoras |
| Balanceamento de **download** | **Requer atenção:** anúncios mais específicos, prepend, communities, ajustes no CGNAT e no uso interno de IPs públicos |

### Roteiro de implementação completa (LAB final)
1. Configurar sessão BGP entre **VIVO** e **CLARO**
2. Criar e endereçar **interface de Loopback**
3. Configurar sessão **Vivo → Cliente** (sem senha)
4. Configurar sessão **Claro → Cliente** (com senha)
5. Bloquear acesso dos clientes à **rede de CGNAT**

---

## Módulo 8 — Wi-Fi

### Cenário 1 — Wi-Fi com Rede de Visitantes em segundo AP
```
Internet → Roteador → AP1 (porta 1)
                        ├─ bridge-rede_local (wlan1) → 10.50.50.0/24
                        └─ bridge-rede_visitantes (wlan2) → 10.60.60.0/24
                              ↓ (porta 3, trunk com VLANs 50 e 60)
                            AP2
                              ├─ bridge-rede_local (wlan1 – escritório) → 10.50.50.0/24
                              └─ bridge-rede_visitantes (wlan2 – visitantes) → 10.60.60.0/24
```
> A interface trunk (porta 3) entre os APs carrega as VLANs **50** (rede local) e **60** (visitantes).

### Lista de canais Wi-Fi e tempo de ativação (DFS)
| Faixa | Canais | Tempo de espera |
|---|---|---|
| U-NII-1 | 36, 40, 44, 48 | ✅ Ativação imediata |
| U-NII-2 (DFS) | 52, 56, 60, 64 | ⏳ Aguarda 1 min |
| U-NII-2e (DFS) | 100, 104, 108, 112 | ⏳ Aguarda 1 min |
| U-NII-2e (DFS) | 116, 120, 124, 128 | ⏳⏳ Aguarda **10 min** |
| U-NII-2e (DFS) | 132, 136, 140 | ⏳ Aguarda 1 min |
| U-NII-3 | 149, 153, 157, 161, 165 | ✅ Ativação imediata |

### Cenários do módulo (resumo)
1. Wi-Fi no roteador colocando na **bridge** geral
2. Wi-Fi no roteador em **rede separada**
3. Wi-Fi usando um **AP separado** do roteador
4. Rede de visitantes **direto no roteador** com Wi-Fi
5. Rede de visitantes com **AP separado**
6. **HotSpot** na rede de visitantes
7. **Bloqueio de acesso** da rede de visitantes (ex.: à rede local/servidores)
8. **Duas WLANs** no mesmo roteador

---

## Módulo 9 — Extras

### Netwatch
Ferramenta para testar conectividade contínua. Tipos de teste suportados:
- ICMP
- TCP
- HTTP
- HTTPS

> 💡 Use IPs de servidores Root DNS como alvos de teste confiáveis (ex.: `198.41.0.4`, `192.33.4.12`, `192.5.5.241`, entre outros).

### Failover (opções de implementação)
- **Check Gateway**
- **Rota recursiva**
- **Netwatch**
- **Scripts personalizados**

### Bloqueio de sites — opções disponíveis
- Firewall com **tls-host** (identificar SNI — equivalente ao filtro `tls.handshake.extensions_server_name` no Wireshark)
- Firewall **content**
- Firewall **Layer 7**
- **Address-list** estática
- **Address-list** dinâmica
- **DNS** com entradas estáticas
- **Adlist** (ex.: lista pronta do GitHub StevenBlack/hosts)
- **Proxy transparente** (com redirecionamento)
- **Proxy configurado** direto no dispositivo do usuário

### Outros tópicos do módulo
- IPv6
- Container no RouterOS
- BTH (VPN própria MikroTik via Cloud)

---

## Tabela de Referência — Operadoras (LAB)

### VIVO
| Tipo de conexão | Faixa |
|---|---|
| PPPoE | `100.64.1.0/24` ou `200.10.1.0/24` |
| DHCP | `100.64.2.0/24` ou `200.10.2.0/24` |
| IP fixo sem VLAN | `200.10.3.0/30` |
| IP fixo com VLAN (VLAN 200) | `200.10.3.4/30` |
| Bloco para rotear | `200.10.3.248/29` |
| Bloco Goias Tech | `200.10.3.8/30` |

### CLARO
| Tipo de conexão | Faixa |
|---|---|
| PPPoE | `100.77.1.0/24` ou `77.10.1.0/24` |
| DHCP | `100.77.2.0/24` ou `77.10.2.0/24` |
| IP fixo sem VLAN | `77.10.3.0/30` |
| IP fixo com VLAN (VLAN 77) | `77.10.3.4/30` |
| Bloco para rotear | `77.10.3.248/29` |
| Bloco 2 para rotear | `77.10.3.xxx/26` |

### Setup geral das operadoras no LAB
1. Descobrir o IP do roteador da VIVO
2. Configurar **nome** do roteador
3. Configurar **RoMON**
4. **Exportar configurações**
5. **Importar** nos demais roteadores
6. Configurar IP para **GOIAS TECH**

---

## 🎯 Dicas finais do curso

- O curso **não é oficial MikroTik** — é independente do programa de certificações (MTCNA, MTCRE, MTCWE, etc.), mas cobre conceitos práticos usados no dia a dia.
- Foca tanto em **provedores de internet** quanto em **ambiente corporativo**.
- Sempre **teste cada etapa isoladamente** antes de avançar (ex.: testar internet básica antes de adicionar firewall, VPN, OSPF etc.).
- **Cuidado especial** com regras de "drop geral" no firewall — sempre garanta uma porta de acesso de emergência (ex.: rede de suporte liberada) antes de aplicar.

---

*Guia gerado a partir do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
