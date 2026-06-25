# Módulo 9 — Extras
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Netwatch
- Failover
- Bloqueio de sites
- IPv6
- Container
- BTH
- Criando e configurando a estrutura de laboratórios (LAB final completo)

---

## 1. Netwatch

> Ferramenta de testes de conectividade contínua — monitora se um host/serviço está disponível e pode disparar scripts quando o estado muda (up/down).

### Tipos de teste suportados
- **ICMP**
- **TCP**
- **HTTP**
- **HTTPS**

### Lista de IPs de servidores Root DNS (alvos confiáveis para teste)
```
198.41.0.4       170.247.170.2    192.33.4.12      199.7.91.13
192.203.230.10   192.5.5.241      192.112.36.4     198.97.190.53
192.36.148.17    192.58.128.30    193.0.14.129     199.7.83.42
202.12.27.33
```

> 💡 Servidores Root DNS são uma excelente referência porque têm altíssima disponibilidade — se eles não responderem, é bem provável que o problema seja no seu próprio link, não no destino.

---

## 2. Failover

Opções de implementação, da mais simples à mais sofisticada:

| Método | Como funciona |
|---|---|
| **Check Gateway** | O próprio MikroTik testa periodicamente se o gateway responde (ping/arp); se não responder, a rota é removida automaticamente |
| **Rota Recursiva** | A rota de failover depende de alcançar um IP intermediário (não o gateway direto), útil quando o "link down" da interface não é suficiente para detectar a falha |
| **Netwatch** | Mais flexível — permite testar qualquer host/serviço (não só o gateway) e disparar scripts personalizados conforme o resultado |
| **Scripts Personalizados** | Máxima flexibilidade — lógica própria para decidir quando trocar de rota, alertar, ou tomar outras ações |

> 🔗 Esse módulo se conecta diretamente ao conceito de **Failover de upload/download** já visto no Módulo 7 (BGP) — aqui usamos métodos mais simples, sem depender de sessões BGP.

---

## 3. Bloqueio de Sites

Várias camadas possíveis, do mais simples ao mais robusto:

| Método | Descrição |
|---|---|
| **Firewall — tls-host** | Identifica o domínio através do campo SNI no handshake TLS (equivalente ao filtro `tls.handshake.extensions_server_name` no Wireshark) |
| **Firewall — content** | Inspeciona o conteúdo do pacote em busca de strings específicas (funciona melhor em tráfego não criptografado) |
| **Firewall — Layer 7** | Usa expressões regulares (regex) para identificar protocolos/conteúdo na camada de aplicação |
| **Address-list estática** | Lista de IPs cadastrados manualmente para bloqueio |
| **Address-list dinâmica** | Lista de IPs populada automaticamente (ex.: via DNS ou scripts) |
| **DNS — Entradas estáticas** | Resolve o domínio bloqueado para um IP inválido/local, impedindo o acesso |
| **Adlist** | Lista pronta de domínios para bloqueio, como a do projeto [StevenBlack/hosts](https://github.com/StevenBlack/hosts) |
| **Proxy transparente** (com redirecionamento) | Todo tráfego HTTP/HTTPS é redirecionado para um proxy que decide o que bloquear, sem configuração no dispositivo do usuário |
| **Proxy configurado direto no dispositivo** | O próprio usuário configura o proxy nas configurações de rede do seu dispositivo |

> 💡 Na prática, muitos provedores combinam **DNS + Address-list dinâmica + tls-host** para conseguir bloquear sites mesmo com HTTPS, já que a inspeção de conteúdo tradicional não funciona em tráfego criptografado.

---

## 4. IPv6

Tópico abordado nos adicionais do curso — cobre a configuração básica de IPv6 no RouterOS, incluindo atribuição de prefixos e DHCPv6/SLAAC para distribuição às redes locais.

---

## 5. Container

O RouterOS v7 trouxe suporte nativo a **containers**, permitindo rodar aplicações adicionais diretamente no roteador (dependendo do hardware/arquitetura suportada), sem precisar de um servidor externo para tarefas auxiliares.

---

## 6. BTH

Recurso de VPN própria da MikroTik, integrado ao **IP Cloud**, permitindo criar túneis ponto a ponto usando a infraestrutura de Cloud da própria MikroTik como intermediária — útil quando ambas as pontas estão atrás de NAT/CGNAT e não é possível abrir portas facilmente.

---

## 7. Criando e Configurando a Estrutura de Laboratórios (LAB completo)

Esta seção fecha o curso replicando, na prática, toda a estrutura de operadoras usada nos exemplos anteriores.

### 7.1 Configurando a Estrutura de Operadoras

1. **Descobrir IP do Roteador da VIVO**
2. **Configurar NOME** do roteador
3. **Configurar RoMON**
4. **Exportar Configs**
5. **Importar nos outros** roteadores
6. **Configurar IP para GOIAS TECH**

### 7.2 Informações das Operadoras (referência completa)

**Vivo**
| Tipo de conexão | Faixa |
|---|---|
| PPPoE | `100.64.1.0/24` ou `200.10.1.0/24` |
| DHCP | `100.64.2.0/24` ou `200.10.2.0/24` |
| IP fixo sem VLAN | `200.10.3.0/30` |
| IP fixo com VLAN (VLAN 200) | `200.10.3.4/30` |
| Bloco para rotear | `200.10.3.248/29` |
| Bloco Goias Tech | `200.10.3.8/30` |

**Claro**
| Tipo de conexão | Faixa |
|---|---|
| PPPoE | `100.77.1.0/24` ou `77.10.1.0/24` |
| DHCP | `100.77.2.0/24` ou `77.10.2.0/24` |
| IP fixo sem VLAN | `77.10.3.0/30` |
| IP fixo com VLAN (VLAN 77) | `77.10.3.4/30` |
| Bloco para rotear | `77.10.3.248/29` |
| Bloco 2 para rotear | `77.10.3.xxx/26` |

### 7.3 BGP e Ajustes Finais

1. **Configurar sessão BGP entre VIVO e Claro**
2. **Criar e endereçar interface de Loopback**
3. **Configurar sessão da Vivo para o Cliente** (sem senha)
4. **Configurar sessão da Claro para o Cliente** (com senha)
5. **Bloquear acesso dos clientes à rede de CGNAT**

> 🎓 Esse roteiro final integra praticamente todos os módulos do curso: configuração inicial, firewall, OSPF/loopback e BGP — é o exercício mais completo para fixar o conteúdo.

---

## ✅ Checklist do módulo

- [ ] Netwatch configurado para monitorar gateway/serviços críticos
- [ ] Estratégia de failover escolhida (Check Gateway, rota recursiva, Netwatch ou script)
- [ ] Pelo menos um método de bloqueio de sites implementado e testado
- [ ] (Opcional) IPv6 configurado na rede
- [ ] (Opcional) Container testado, se o hardware suportar
- [ ] (Opcional) BTH avaliado como alternativa de VPN simplificada
- [ ] Estrutura completa de operadoras (Vivo + Claro) replicada no LAB
- [ ] Sessões BGP finais configuradas e validadas
- [ ] Firewall final bloqueando clientes → rede de CGNAT

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
