# Módulo 5 — OSPF
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Adicionando 2 novos concentradores na rede
- Ativando o OSPF básico
- Implementando boas práticas
- Implementando OSPF entre VPNs

---

## 1. Ativar OSPF (passo a passo básico)

1. **Adicionar os IPs das interfaces**
   - Cada roteador que vai participar do OSPF precisa ter IPs configurados nas interfaces relevantes
2. **Adicionar as interfaces que serão usadas pelo OSPF**
   - Defina em quais interfaces o roteador deve formar vizinhança OSPF (ex.: interfaces entre concentradores, VPNs)
3. **Adicionar as interfaces ou redes que precisam ser anunciadas**
   - As redes locais (LANs) que devem ser conhecidas pelos demais roteadores via OSPF

---

## 2. Adicionando concentradores na rede

Ao expandir a rede com novos concentradores:
- Cada novo concentrador deve ter OSPF habilitado nas interfaces que o conectam à rede já existente
- Verifique se as vizinhanças (neighbors) OSPF se formam corretamente antes de seguir para anúncio de redes
- Use o comando/menu de **neighbors** do OSPF para confirmar o estado `Full` da adjacência

---

## 3. OSPF — Boas Práticas

| Prática | Por quê |
|---|---|
| **Interfaces PTP** (ponto a ponto) | Em links exclusivos entre dois roteadores, reduz overhead de eleição de DR/BDR, comum em redes broadcast |
| **Tirar o OSPF do NAT** | Evita anunciar redes que já passam por NAT, prevenindo loops de roteamento ou anúncios incorretos |
| **Cuidado com PPPoEs** | Interfaces PPPoE têm comportamento específico — avalie se o OSPF deve rodar diretamente sobre elas |
| **Interface passiva** | Em interfaces onde não há vizinho OSPF esperado (ex.: interface de acesso a clientes), evita tráfego de hello desnecessário e reduz superfície de ataque |
| **Senha no OSPF** | Autenticação evita que um roteador não autorizado entre na área OSPF e injete rotas falsas |
| **Interface de Loopback** | Fornece um identificador estável para o roteador, independente de qual interface física esteja ativa |

---

## 4. Configurando a Interface de Loopback

1. **Adicionar o IP na interface** (crie uma interface do tipo `loopback` ou `bridge` dedicada, sem conexão física)
2. **Anunciar a Loopback no OSPF**
3. **Ajustar o RouterID dos Roteadores**
   - Use o IP da loopback como **Router ID**, garantindo que ele não mude mesmo se uma interface física cair
4. **Colocar IP de Loopback como origem nas requisições do RADIUS**
   - Importante para ambientes com múltiplos caminhos de rede — garante que o servidor RADIUS sempre veja o mesmo IP de origem, independente da rota usada

> 🔗 Esse ajuste de loopback conecta-se diretamente ao **Módulo 2 (RADIUS/MK-AUTH)** — usar a loopback como origem evita problemas de autenticação quando há failover ou múltiplos uplinks.

---

## 5. Implementando OSPF entre VPNs

Quando você tem múltiplas filiais conectadas via WireGuard ou L2TP (ver **Módulo 4 — VPN**), rodar OSPF sobre os túneis traz vantagens:

- **Convergência automática**: se um túnel cair, o OSPF recalcula a rota por outro caminho (se existir)
- **Menos rotas estáticas para manter**: você não precisa atualizar rotas manualmente a cada nova filial
- **Boas práticas aplicáveis**: trate as interfaces de VPN como interfaces PTP quando o túnel for ponto a ponto, e considere torná-las passivas se não houver necessidade de formar vizinhança ali

---

## ✅ Checklist do módulo

- [ ] IPs configurados em todas as interfaces participantes
- [ ] OSPF habilitado nas interfaces corretas
- [ ] Redes locais anunciadas via OSPF
- [ ] Vizinhança OSPF (`neighbor`) no estado `Full` entre os roteadores
- [ ] Interfaces PTP configuradas onde aplicável
- [ ] OSPF retirado do escopo de NAT
- [ ] Interfaces sem vizinho esperado marcadas como passivas
- [ ] Senha de autenticação OSPF configurada
- [ ] Interface de Loopback criada e anunciada
- [ ] Router ID ajustado com base na Loopback
- [ ] RADIUS configurado para usar a Loopback como origem
- [ ] OSPF testado sobre os túneis de VPN (se aplicável)

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
