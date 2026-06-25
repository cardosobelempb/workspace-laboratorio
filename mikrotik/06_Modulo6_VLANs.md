# Módulo 6 — VLANs
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Configurando VLAN entre o roteador e switch da empresa
- Fazendo um LAN-to-LAN (VLANs nos roteadores)

---

## 1. Tipos de interfaces VLAN

| Tipo | Também chamada de | Função |
|---|---|---|
| **Tagged** | Trunk | Geralmente transporta mais de uma VLAN — usada entre switches/roteadores |
| **Untagged** | Access | Interface que transporta somente uma VLAN — ligada a um dispositivo de usuário (PC, impressora, AP) |

> 💡 Pense assim: **Trunk** é a "rodovia" que carrega o tráfego de várias VLANs identificadas (com tag); **Access** é a "rua" que entrega apenas uma VLAN, sem tag, para o dispositivo final que não entende VLAN.

---

## 2. Configurando VLAN entre o Roteador e o Switch da Empresa

### Cenário típico
- O roteador MikroTik se conecta ao switch da empresa por uma interface **trunk (tagged)**, carregando várias VLANs (ex.: VLAN 10 — Financeiro, VLAN 20 — Servidores, VLAN 30 — Visitantes)
- O switch então distribui cada VLAN para as portas **access (untagged)** corretas, onde os dispositivos finais estão conectados

### Passos gerais
1. No MikroTik, **crie as interfaces VLAN** sobre a interface física que vai para o switch (ex.: `vlan10`, `vlan20`, `vlan30`, todas sobre `ether2`)
2. Atribua um **IP** a cada interface VLAN criada (uma sub-rede por VLAN)
3. No switch, configure a porta que liga ao MikroTik como **trunk**, permitindo as VLANs necessárias
4. Configure as demais portas do switch como **access**, cada uma associada à VLAN correta
5. Se necessário, crie **DHCP Server** para cada VLAN/sub-rede no MikroTik

---

## 3. Fazendo um LAN-to-LAN com VLANs (entre roteadores)

> Esse cenário é usado quando você precisa estender a mesma VLAN entre duas pontas distantes — por exemplo, interligando duas unidades de uma empresa através de VLANs nos roteadores, ao invés de criar sub-redes separadas.

### Conceito
- Os roteadores em ambas as pontas usam interfaces **tagged** para transportar a mesma VLAN através do link entre eles (físico, fibra dedicada, ou mesmo sobre uma VPN)
- O resultado é uma única VLAN/broadcast domain estendida entre os dois locais, como se estivessem na mesma rede física

### Passos gerais
1. Identifique a interface de **uplink** entre os dois roteadores (link físico ou túnel)
2. Crie a interface VLAN correspondente em **ambas as pontas**, com a mesma VLAN ID
3. Associe essa VLAN à **bridge** local de cada ponta, se o objetivo for estender a LAN (camada 2) entre os locais
4. Verifique que **não há conflito de IP** entre os dispositivos das duas pontas, já que estarão na mesma sub-rede lógica

> ⚠️ **Atenção:** estender VLANs/LANs entre locais distantes aumenta o domínio de broadcast e pode impactar performance/segurança. Avalie se um cenário roteado (com OSPF/BGP — Módulos 5 e 7) não seria mais adequado, dependendo do caso de uso.

---

## ✅ Checklist do módulo

- [ ] Entendido a diferença entre **Tagged (Trunk)** e **Untagged (Access)**
- [ ] Interfaces VLAN criadas no MikroTik sobre a interface física correta
- [ ] IPs atribuídos a cada VLAN/sub-rede
- [ ] Porta trunk configurada corretamente no switch da empresa
- [ ] Portas access do switch associadas às VLANs corretas
- [ ] DHCP Server criado para cada VLAN, se necessário
- [ ] (Se aplicável) VLAN estendida entre roteadores via LAN-to-LAN configurada e testada
- [ ] Testes de conectividade realizados em cada VLAN

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
