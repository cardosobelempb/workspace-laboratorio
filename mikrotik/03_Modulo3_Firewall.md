# Módulo 3 — Firewall
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Funcionamento do Firewall
- Protegendo seu roteador
- Bloqueando acessos a IPs públicos
- Bloqueando acesso a portas baixas
- Bloqueando acesso à rede de servidores
- Bloqueando IP Spoofing

---

## 1. Protegendo seu Roteador (cadeia INPUT)

> ⚠️ **Cuidado:** a ordem das regras importa. Sempre garanta uma porta de acesso de emergência antes de aplicar um "drop geral".

**Sequência recomendada:**
1. ⚠️ **Drop Geral** (regra final da cadeia — cuidado para não se trancar fora do roteador)
2. **Aceita conexões estabelecidas ou relacionadas** (`established`, `related`)
3. **Aceita rede de suporte** (sua rede de gerência/administração)
4. **Aceita ICMP de forma controlada** (não libere todo ICMP sem limites)
5. **Toc-Toc ou Port Knocking** (camada extra de segurança para liberar acesso só após uma sequência de "toques")
6. Se for necessário, faça outras liberações específicas

---

## 2. Firewall para Empresas (INPUT + FORWARD)

### Cadeia INPUT
1. ⚠️ Drop Geral (Cuidado)
2. Aceita conexões estabelecidas ou relacionadas
3. Aceita rede de suporte
4. Aceita ICMP de forma controlada
5. Toc-Toc ou Port Knocking

### Cadeia FORWARD
1. **Liberar somente o necessário**
2. **Bloquear todo o restante**
3. **Filtro Anti-Spoofing**
4. **Avaliar uso de fasttrack** — atenção: fasttrack acelera o tráfego, mas faz o pacote "pular" etapas do firewall (incluindo regras de bloqueio/conteúdo aplicadas depois dele). Avalie se isso é compatível com suas necessidades de filtragem.

---

## 3. Exemplos práticos de regras

Regras comuns para bloquear acesso indesejado vindo da internet:

- **Bloquear acesso ao Winbox** (porta TCP 8291)
- **Bloquear acesso ao SSH** (porta TCP 22)
- **Bloquear acesso à navegação WEB** (portas 80/443, quando aplicável a um destino específico)
- **Bloquear PING** (protocolo ICMP, echo-request)

> 💡 Essas regras servem tanto para proteger o próprio roteador (INPUT) quanto para impedir que clientes acessem certos serviços (FORWARD), dependendo de onde forem aplicadas.

---

## 4. Bloqueando Acesso a IPs Públicos — 3 Cenários (Cases)

| Caso | Cenário | O que considerar |
|---|---|---|
| **Case 1** | Todos os clientes com IPs públicos | Firewall precisa proteger individualmente cada cliente, já que todos são alcançáveis diretamente da internet |
| **Case 2** | IPs públicos entregues somente para quem contratou | Misture regras gerais (para a maioria via CGNAT) com regras específicas para os clientes com IP público |
| **Case 3** | IPs públicos em servidores | Foque em liberar **apenas as portas dos serviços oferecidos** pelo servidor, bloqueando todo o restante |

---

## 5. Bloqueando IP Spoofing

O **filtro Anti-Spoofing** (mencionado na cadeia FORWARD) evita que pacotes com IP de origem falsificado entrem ou saiam da sua rede.

**Conceito geral:**
- Pacotes vindos de **dentro** da sua rede com IP de origem que **não pertence** à sua faixa interna → devem ser descartados
- Pacotes vindos de **fora** com IP de origem que **pertence** à sua própria rede interna → também devem ser descartados (alguém tentando se passar por um cliente seu)

---

## ✅ Checklist do módulo

- [ ] Regra de drop geral criada **por último** na cadeia INPUT
- [ ] Conexões established/related liberadas
- [ ] Rede de suporte/gerência liberada
- [ ] ICMP liberado de forma controlada (não irrestrito)
- [ ] Port Knocking avaliado/implementado (se necessário)
- [ ] Cadeia FORWARD: liberar o necessário, bloquear o resto
- [ ] Filtro Anti-Spoofing aplicado
- [ ] Decisão tomada sobre uso de fasttrack
- [ ] Regras de bloqueio de Winbox/SSH/Web/Ping testadas
- [ ] Estratégia de IP público definida (Case 1, 2 ou 3) e aplicada

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
