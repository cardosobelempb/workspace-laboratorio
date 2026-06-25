# Módulo 8 — Wi-Fi
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Configurando uma rede Wi-Fi no roteador colocando na bridge
- Configurando uma rede Wi-Fi no roteador colocando em rede separada
- Configurando uma rede Wi-Fi usando um AP separado do roteador
- Configurando uma rede de visitantes direto no roteador com Wi-Fi
- Configurando uma rede de visitantes com AP separado do roteador
- Configurando HotSpot na rede de visitantes
- Bloqueando acesso da rede de visitantes
- Configurando duas WLANs no roteador

---

## 1. Topologia básica

```
Internet
   │
┌──┴────────┐
│ Roteador  │  (Wi-Fi integrado)
└─────┬─────┘
      │
   ┌──┴──┐
   │ PC  │
   └─────┘
```

> Esse é o ponto de partida mais simples: o roteador já possui rádio Wi-Fi integrado e distribui internet tanto via cabo quanto via Wi-Fi.

---

## 2. Cenários de configuração — visão geral

| Cenário | Onde fica o Wi-Fi | Rede |
|---|---|---|
| **1. Wi-Fi na bridge geral** | No próprio roteador | Mesma rede da LAN cabeada |
| **2. Wi-Fi em rede separada** | No próprio roteador | Sub-rede própria, diferente da LAN cabeada |
| **3. Wi-Fi em AP separado** | Em um Access Point dedicado | Conforme definido na configuração do AP |
| **4. Rede de visitantes direto no roteador** | No próprio roteador | Sub-rede isolada para visitantes |
| **5. Rede de visitantes com AP separado** | Em AP dedicado | Sub-rede isolada, trafegando via VLAN até o roteador |
| **6. HotSpot na rede de visitantes** | Onde estiver o Wi-Fi de visitantes | Autenticação via portal captivo |
| **7. Duas WLANs no mesmo roteador** | No próprio roteador (rádio com suporte a múltiplas SSIDs) | Cada WLAN com sua própria sub-rede/VLAN |

### Passos gerais (aplicáveis à maioria dos cenários)
1. Configure a interface **wlan** (SSID, segurança WPA2/WPA3, canal/frequência)
2. Decida se a wlan vai **entrar em uma bridge existente** (cenário 1) ou ter **sub-rede própria** (cenários 2 em diante)
3. Se for sub-rede própria, crie **IP**, **DHCP Server** e, se necessário, **VLAN** correspondente
4. Aplique **firewall** para isolar a rede de visitantes da rede local (ver seção 5)

---

## 3. Cenário — Wi-Fi com Rede de Visitantes em Segundo AP

```
                         Internet
                            │
                       ┌────┴─────┐
                       │ Roteador │
                       └────┬─────┘
                            │ (porta 1)
                       ┌────┴─────┐
                       │   AP 1   │
                       └─┬──────┬─┘
              (porta 2)  │      │ (porta 3 — trunk)
                          │      │
            ┌─────────────┘      └─────────────┐
            │                                   │
  bridge-rede_local                    [VLANs 50 e 60]
  10.50.50.0/24 (wlan1)                          │
                                            ┌─────┴─────┐
  bridge-rede_visitantes                    │   AP 2    │
  10.60.60.0/24 (wlan2)                     └─┬───────┬─┘
                                          (VLAN 50)  (VLAN 60)
                                               │         │
                                  bridge-rede_local  bridge-rede_visitantes
                                  10.50.50.0/24       10.60.60.0/24
                                  (wlan1 – escritório) (wlan2 – visitantes)
```

### Passos
1. No **AP 1**, crie duas bridges: `bridge-rede_local` (rede local) e `bridge-rede_visitantes` (visitantes)
2. Associe `wlan1` à `bridge-rede_local` (`10.50.50.0/24`) e `wlan2` à `bridge-rede_visitantes` (`10.60.60.0/24`)
3. A porta 3 do AP 1 sai como **trunk**, carregando as VLANs **50** (rede local) e **60** (visitantes) até o **AP 2**
4. No **AP 2**, replique a mesma estrutura: `wlan1 – escritório` na VLAN 50, `wlan2 – visitantes` na VLAN 60
5. Teste que um dispositivo conectado ao Wi-Fi de visitantes em qualquer um dos APs cai sempre na mesma sub-rede `10.60.60.0/24`

---

## 4. Lista de Frequências (DFS — Dynamic Frequency Selection)

> Algumas faixas de 5 GHz exigem que o rádio "escute" antes de transmitir, para evitar interferência com radares. Isso causa um **tempo de espera** ao ativar o canal.

| Faixa | Canais | Frequência (MHz) | Tempo de espera |
|---|---|---|---|
| **U-NII-1** | 36, 40, 44, 48 | 5180–5240 | ✅ Ativação imediata |
| **U-NII-2 (DFS)** | 52, 56, 60, 64 | 5260–5320 | ⏳ Aguarda 1 min |
| **U-NII-2e (DFS)** | 100, 104, 108, 112 | 5500–5560 | ⏳ Aguarda 1 min |
| **U-NII-2e (DFS)** | 116, 120, 124, 128 | 5580–5640 | ⏳⏳ Aguarda **10 min** |
| **U-NII-2e (DFS)** | 132, 136, 140 | 5660–5700 | ⏳ Aguarda 1 min |
| **U-NII-3** | 149, 153, 157, 161, 165 | 5745–5825 | ✅ Ativação imediata |

> 💡 **Dica prática:** se o seu AP demora muito para "subir" o Wi-Fi após reiniciar, verifique se o canal configurado está em uma faixa DFS — especialmente as marcadas com **10 minutos** de espera (116–128), que costumam ser a causa de demoras inesperadas.

---

## 5. Bloqueando acesso da rede de visitantes

Depois de isolar a rede de visitantes em sua própria sub-rede/VLAN (`10.60.60.0/24` no exemplo), aplique regras de **firewall** (ver Módulo 3) para:
- Bloquear acesso da rede de visitantes à rede local (`10.50.50.0/24`)
- Bloquear acesso a outras redes internas sensíveis (servidores, financeiro, etc.)
- Permitir **apenas** a saída para a internet

---

## 6. HotSpot na rede de visitantes

O HotSpot adiciona um **portal de autenticação** (captive portal) antes de liberar o acesso à internet — útil para visitantes em ambientes corporativos, hotéis, eventos, etc.

**Passos gerais:**
1. Configure o HotSpot na interface/bridge da rede de visitantes
2. Defina o **perfil de usuário** (página de login, tempo de sessão, limite de banda)
3. Escolha o método de autenticação (usuário/senha, voucher, redes sociais, etc., conforme suportado)
4. Combine com as regras de firewall de isolamento já aplicadas

---

## 7. Duas WLANs no roteador

Quando o hardware suporta múltiplas SSIDs simultâneas no mesmo rádio (ou possui dois rádios), você pode configurar, por exemplo:
- **WLAN 1** — rede principal/escritório
- **WLAN 2** — rede de visitantes

Cada uma com sua própria bridge, sub-rede e regras de firewall, seguindo a mesma lógica dos cenários anteriores — só que sem precisar de um segundo equipamento físico.

---

## ✅ Checklist do módulo

- [ ] SSID e segurança (WPA2/WPA3) configurados em cada WLAN
- [ ] Decidido se cada WLAN entra na bridge geral ou tem sub-rede própria
- [ ] IP e DHCP Server criados para cada sub-rede Wi-Fi independente
- [ ] VLANs configuradas corretamente entre APs (se houver mais de um AP)
- [ ] Canal/frequência escolhido considerando o tempo de espera DFS
- [ ] Firewall bloqueando rede de visitantes → rede local/servidores
- [ ] HotSpot configurado na rede de visitantes (se aplicável)
- [ ] Testado o acesso Wi-Fi em todos os APs/SSIDs configurados

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
