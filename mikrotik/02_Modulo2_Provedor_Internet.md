# Módulo 2 — Configurando um Provedor de Internet do Zero
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Planejamento de rede
- PPPoE server e client
- Separação de PPPoE server e NAT
- RADIUS (integração com MK-AUTH)
- Recebimento e distribuição de blocos de IP público
- Redirecionamento de portas
- CGNAT

---

## 1. Planejamento de rede

Antes de configurar qualquer coisa, planeje:
- Quantos clientes você vai atender e qual o crescimento esperado
- Quais blocos de IP você tem disponível (público e CGNAT)
- Que tipo de entrega vai oferecer (PPPoE, IP fixo `/30`, `/32`, bloco roteado)
- Onde o RADIUS (MK-AUTH) vai ficar hospedado

---

## 2. Passo a passo — PPPoE Server e PPPoE Client

1. **Criar Pool de endereços**
   - Faixa de IPs que será distribuída aos clientes que conectarem via PPPoE
2. **Criar Profile** dentro de `PPP`
   - Define parâmetros como DNS, taxa de upload/download, pool usado
3. **Criar usuários** dentro de `PPP`
   - Login e senha de cada cliente (ou integração via RADIUS)
4. **Criar o PPPoE Server** na interface que vai para os clientes
   - Vincule ao profile e à interface correta (ex.: interface da rede de acesso)

> 💡 Boa prática: separe a interface/serviço do **PPPoE server** do NAT, para facilitar regras de firewall e troubleshooting.

---

## 3. RADIUS (MK-AUTH)

A integração com RADIUS permite gerenciar usuários, planos e autenticação de forma centralizada via MK-AUTH.

### No MK-AUTH
1. **Cadastrar os roteadores** (NAS) que vão consultar o RADIUS
2. **Cadastrar Planos** (velocidades, perfis de banda)
3. **Cadastrar usuários** (login/senha de cada cliente)

### No MikroTik
1. **Configurar RADIUS**
   - Apontar para o IP do servidor MK-AUTH
   - Definir o "secret" (senha compartilhada) usado na comunicação
   - Habilitar RADIUS para uso em `PPP`

> 🔄 Lembrete do Módulo 5 (OSPF): se você usa Loopback, **coloque o IP de loopback como origem** nas requisições do RADIUS — isso evita problemas de autenticação quando há múltiplos caminhos de rede.

---

## 4. Recebendo e distribuindo IP público

### Recebendo um bloco de IP público da operadora
- O bloco chega via BGP, IP fixo ou outra forma combinada com a operadora (ver Módulo 7 — BGP, para integração completa).

### Como escolher o IP usado no NAT dos clientes
- Reserve um IP específico (ou pool dedicado) para a saída NAT dos clientes que **não** têm IP público — geralmente um IP de CGNAT (`100.64.0.0/10`) ou um IP público comum de saída.

### Entregando IP público para diferentes tipos de cliente
| Cenário | Como entregar |
|---|---|
| **Cliente PPPoE** | IP público atribuído via pool específico no profile PPP do cliente |
| **Cliente com `/30`** | Sub-rede ponto a ponto dedicada (2 IPs utilizáveis) |
| **Cliente com `/32`** | IP único roteado diretamente para o cliente |
| **Bloco de IP público completo** | Roteamento de um bloco maior (ex.: `/29`) para o roteador do cliente |

### Colocando IP público em um servidor
- Atribua o IP público diretamente na interface do servidor (ou via NAT 1:1), garantindo que o firewall libere apenas o necessário (ver Módulo 3 — Firewall).

---

## 5. Redirecionamento de portas (Port Forward)

- **Com IP público:** redirecionamento direto via regra de **dst-nat** apontando para o IP interno do servidor.
- **Sem IP público (atrás de CGNAT):** é necessário um IP público intermediário (ex.: do próprio provedor) fazendo o redirecionamento até o cliente, já que o cliente não possui IP roteável diretamente.

---

## 6. CGNAT

> Use a faixa reservada `100.64.0.0/10` para os clientes que não recebem IP público, evitando conflito com redes privadas internas (`10.0.0.0/8`, `192.168.0.0/16`, `172.16.0.0/12`).

**Pontos de atenção:**
- Planeje o tamanho do bloco de CGNAT conforme a quantidade de clientes
- Avalie a necessidade de **logging de NAT** (importante para questões legais/Marco Civil, dependendo da legislação aplicável)
- Combine CGNAT com regras de firewall que bloqueiem acesso indevido entre clientes

---

## ✅ Checklist do módulo

- [ ] Pool de endereços PPPoE criado
- [ ] Profile PPP configurado (DNS, taxas, pool)
- [ ] Usuários PPP criados (locais ou via RADIUS)
- [ ] PPPoE Server ativo na interface correta
- [ ] RADIUS configurado e comunicando com MK-AUTH (roteador, planos e usuários cadastrados)
- [ ] Estratégia definida para distribuição de IP público (PPPoE, `/30`, `/32`, bloco)
- [ ] IP de NAT dos clientes sem IP público definido
- [ ] Regras de redirecionamento de porta testadas
- [ ] CGNAT dimensionado e configurado

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
