# Módulo 4 — VPN
**Curso MikroTik RouterOS v7 — Redes Brasil**

## 📋 O que este módulo cobre
- Interligando Matriz e Filial com L2TP
- Conexão remota com L2TP
- Interligando Matriz e Filial com WireGuard
- Adicionando mais uma filial com WireGuard
- Conexão remota com WireGuard

---

## 1. Preparação básica no roteador da Filial

Antes de configurar qualquer VPN, a filial precisa ter internet funcionando:

1. **Criar o PPPoE Server** (ex.: na Claro) na interface que vai para a filial
2. **Configurar nome do roteador e das interfaces**
3. **Configurar RoMON** (não necessário se já estiver no LAB em nuvem)
4. **Configurar PPPoE cliente** e verificar se o roteador tem internet
5. **Configurar IP e DHCP Server** na LAN
6. **Fazer regra de NAT** e testar `ping` do VPC para a internet

> ✅ Só avance para a configuração da VPN depois que a filial tiver internet funcionando normalmente.

---

## 2. VPN com WireGuard (Matriz ↔ Filial)

### Passos para configurar
1. **Criar as interfaces WireGuard** (uma em cada ponta — matriz e filial)
2. **Colocar IP nas interfaces WireGuard** (geralmente uma sub-rede `/30` ou `/32` ponto a ponto)
3. **Criar Rotas dos dois lados** (apontando a rede remota através da interface WireGuard)
4. **Criar os Peers do WireGuard dos dois lados** (trocando as chaves públicas)

### Checklist de configuração do Peer
- [ ] Chave pública do lado remoto inserida corretamente
- [ ] `Endpoint` configurado com IP público + porta do lado que "inicia" a conexão
- [ ] `Allowed Address` cobrindo as redes que devem trafegar pela VPN
- [ ] Keepalive configurado (recomendado para manter o túnel ativo atrás de NAT)

---

## 3. Adicionando mais uma filial com WireGuard

- Repita o processo de criação de interface, IP, rota e peer para a nova filial
- Avalie a topologia:
  - **Hub-and-spoke**: todas as filiais se conectam à matriz, e a matriz roteia entre elas
  - **Full mesh**: cada filial se conecta diretamente às demais (mais peers para gerenciar, porém menor latência entre filiais)

> 💡 Se for usar várias filiais com necessidade de troca dinâmica de rotas, considere combinar WireGuard com **OSPF** (ver Módulo 5) ou **BGP** (ver Módulo 7) ao invés de rotas estáticas.

---

## 4. Conexão Remota com WireGuard (cliente individual)

### Configuração WireGuard — Cliente Windows

```ini
[Interface]
; ISSO JÁ VEM QUANDO CRIA O PEER — NÃO COPIAR MANUALMENTE
PrivateKey = CHAVE_PRIVADA
Address = IP_DA_INTERFACE_WIREGUARD/32   ; lembrar de colocar o /32

[Peer]
PublicKey = CHAVE_PUBLICA_DO_SERVIDOR_WIREGUARD
AllowedIPs = REDES   ; ex: 10.0.0.0/8, 100.64.0.0/10  —  para navegar tudo pela VPN use 0.0.0.0/0
Endpoint = IP_PÚBLICO:PORTA   ; do servidor WireGuard
```

**Pontos de atenção:**
- `PrivateKey` e o bloco `[Interface]` são gerados automaticamente ao criar o peer no MikroTik — **não digite manualmente**
- Não esquecer o `/32` no `Address`
- Em `AllowedIPs`, use `0.0.0.0/0` apenas se quiser que **todo** o tráfego do cliente passe pela VPN

> ⚠️ **Nota do curso sobre VPN cliente no Windows:**
> O cliente nativo usado nos testes pode ficar **lento ao ligar**, devido a atualizações em segundo plano disputando a conexão. Isso é uma limitação do ambiente de teste, não da configuração da VPN em si.

---

## 5. VPN com L2TP

### Interligando Matriz e Filial com L2TP
- Configure o **L2TP Server** na matriz (com IPsec, se desejar criptografia adicional)
- Configure o **L2TP Client** na filial, apontando para o IP público da matriz
- Crie as rotas necessárias para que as redes locais de ambos os lados se enxerguem

### Conexão remota com L2TP
- Mesmo princípio, mas o cliente é um usuário individual (notebook, celular) ao invés de outro roteador
- Sistemas operacionais (Windows, macOS, Android, iOS) costumam ter cliente L2TP nativo, facilitando o acesso sem instalar software adicional

---

## ✅ Checklist do módulo

- [ ] Filial com internet funcionando (PPPoE configurado e testado)
- [ ] Interfaces WireGuard criadas nos dois lados
- [ ] IPs atribuídos às interfaces WireGuard
- [ ] Rotas criadas nos dois lados
- [ ] Peers configurados com chaves corretas
- [ ] Teste de `ping` entre redes da matriz e da filial
- [ ] (Se aplicável) L2TP Server configurado na matriz
- [ ] (Se aplicável) L2TP Client configurado na filial ou no usuário remoto
- [ ] Conexão remota individual testada (WireGuard ou L2TP)

---

*Parte do material "Curso MikroTik — Com RouterOS v7" (Redes Brasil).*
