# Módulo 7 — BGP
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Introdução ao BGP
- Fechando BGP com uma operadora
- Fechando BGP com duas operadoras
- Usando BGP para troca de rotas em uma VPN

---

## 1. Introdução ao BGP

O BGP é o protocolo usado para anunciar seus próprios blocos de IP para a internet (via operadoras) e receber rotas de volta — essencial para provedores com **ASN próprio** que querem ter independência de operadora, fazer failover e balanceamento de links.

**Pré-requisitos para usar BGP "de verdade":**
- Ter um **ASN** (Autonomous System Number) registrado, no Brasil isso é feito via **NIC.br**
- Ter um **bloco de IP** próprio (PI — Provider Independent) também registrado
- Ter pelo menos uma operadora dispostas a fazer sessão BGP com você (peering)

---

## 2. BGP com a VIVO (exemplo do LAB)

### Dados da sessão
| Informação | Valor |
|---|---|
| **ASN RB Telecom** | `5050` |
| **Prefixo IPv4 anunciado** | `50.50.0.0/22` |
| **ASN Vivo** | `20011` |
| **IP Vivo** | `200.10.3.1/30` |
| **IP RB Telecom** | `200.10.3.2/30` |

### Passos gerais
1. Configure o IP `200.10.3.2/30` na interface que liga à Vivo
2. Crie a sessão BGP apontando para o **peer** `200.10.3.1` (ASN remoto `20011`)
3. Defina seu próprio ASN (`5050`) na instância BGP local
4. Configure o anúncio do prefixo `50.50.0.0/22` para a Vivo
5. Verifique o estado da sessão (deve chegar a `Established`)
6. Confirme o recebimento de rotas (full routing ou rotas parciais, conforme acordado)

---

## 3. BGP com a CLARO (exemplo do LAB)

### Dados da sessão
| Informação | Valor |
|---|---|
| **ASN RB Telecom** | `5050` |
| **Prefixo IPv4 anunciado** | `50.50.0.0/22` |
| **ASN Claro** | `7711` |
| **IP Claro** | `77.10.3.1/30` |
| **IP RB Telecom** | `77.10.3.2/30` |
| **Senha BGP** | `senhabgp` |

### Passos gerais
1. Configure o IP `77.10.3.2/30` na interface que liga à Claro
2. Crie a sessão BGP apontando para o **peer** `77.10.3.1` (ASN remoto `7711`)
3. **Configure a senha** `senhabgp` na sessão (autenticação MD5) — diferente da sessão com a Vivo, que não usa senha nesse exemplo
4. Confirme o anúncio do mesmo prefixo `50.50.0.0/22`
5. Verifique o estado `Established` da sessão

> ⚠️ Repare que, nesse exemplo, a Vivo **não exige senha**, mas a Claro **exige**. Sempre confirme com cada operadora real qual o método de autenticação exigido.

---

## 4. Failover e Balanceamento no BGP

| Cenário | Complexidade | Como funciona |
|---|---|---|
| **Failover de upload** | ✅ Simples | Recebe full routing — o roteador escolhe automaticamente o melhor caminho de saída |
| **Balanceamento de upload** | ✅ Simples | Recebe full routing — múltiplos caminhos válidos podem ser usados simultaneamente |
| **Failover de download** | ✅ Simples | Anuncia o bloco inteiro (ex.: `/22`) em **todas** as operadoras; se uma cair, o tráfego de entrada migra para a outra |
| **Balanceamento de download** | ⚠️ Precisa de atenção | Requer técnicas mais avançadas (ver abaixo) |

### Técnicas para balanceamento de download
- **Anúncios mais específicos** — dividir o bloco maior em sub-blocos (ex.: `/23` ou `/24`) e anunciar partes diferentes para operadoras diferentes
- **Prepend** — "alongar" artificialmente o caminho AS-PATH em uma operadora para torná-la menos atrativa, direcionando mais tráfego pela outra
- **Communities** — usar BGP communities (se suportado pela operadora) para sinalizar preferências de roteamento
- **Ajustes no seu CGNAT** — garantir que o NAT de saída esteja alinhado com a operadora de entrada escolhida para aquele tráfego
- **Ajustes de uso de IPs públicos internamente** — distribuir IPs públicos de cada operadora conforme a política de balanceamento definida

---

## 5. Usando BGP para troca de rotas em uma VPN

Quando você tem múltiplos sites conectados via VPN (WireGuard, ver Módulo 4) e quer trocar rotas dinamicamente sem usar OSPF, o BGP também é uma opção — especialmente útil em cenários com **múltiplos ASNs** ou quando é necessário aplicar políticas de roteamento mais granulares (ex.: route-maps, filtros por prefixo) do que o OSPF permite nativamente.

---

## 6. Roteiro de implementação completa (LAB final do módulo)

1. **Configurar sessão BGP entre VIVO e CLARO** (transit entre as duas operadoras simuladas, conforme o cenário do LAB)
2. **Criar e endereçar interface de Loopback** (ver Módulo 5 — usar como Router ID e origem de sessões)
3. **Configurar sessão da Vivo para o Cliente** (sem senha, conforme exemplo)
4. **Configurar sessão da Claro para o Cliente** (com senha, conforme exemplo)
5. **Bloquear acesso dos clientes à rede de CGNAT** (regra de firewall — ver Módulo 3)

---

## ✅ Checklist do módulo

- [ ] ASN e bloco de IP definidos (ou simulados, no LAB)
- [ ] Sessão BGP com a Vivo configurada e `Established`
- [ ] Sessão BGP com a Claro configurada (com senha) e `Established`
- [ ] Prefixo `50.50.0.0/22` anunciado corretamente para ambas
- [ ] Estratégia de failover de upload/download validada
- [ ] (Se necessário) Estratégia de balanceamento de download definida — anúncios específicos, prepend ou communities
- [ ] Interface de Loopback criada e usada como Router ID
- [ ] Sessão BGP com o cliente final configurada (Vivo sem senha / Claro com senha)
- [ ] Firewall bloqueando acesso dos clientes à rede de CGNAT

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
