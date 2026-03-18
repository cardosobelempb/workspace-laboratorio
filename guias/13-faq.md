# ❓ FAQ - Perguntas Frequentes

## Geral

### O que é EVE-NG?

EVE-NG (Emulated Virtual Environment - Next Generation) é uma plataforma de emulação de rede que permite criar topologias complexas de rede virtual para treinamento, testes e demonstrações.

### Qual a diferença entre EVE-NG Community e Pro?

| Recurso                  | Community    | Pro          |
| ------------------------ | ------------ | ------------ |
| **Preço**                | Gratuito     | Pago         |
| **Dispositivos básicos** | ✅ Ilimitado | ✅ Ilimitado |
| **Docker support**       | ✅ Sim       | ✅ Sim       |
| **Clusters**             | ❌ Não       | ✅ Sim       |
| **Multi-user**           | Básico       | Avançado     |
| **Suporte oficial**      | Fórums       | Email/Ticket |

**Para laboratório pessoal**: Community é suficiente!

### Posso usar EVE-NG comercialmente?

**Community Edition**: Apenas uso não-comercial  
**Professional Edition**: Uso comercial permitido

### EVE-NG vs GNS3 - Qual escolher?

| Aspecto                  | EVE-NG    | GNS3         |
| ------------------------ | --------- | ------------ |
| **Interface**            | Web       | Desktop      |
| **Multi-usuário**        | ✅ Nativo | ⚠️ Limitado  |
| **Docker**               | ✅ Sim    | ✅ Sim       |
| **Curva de aprendizado** | Média     | Média        |
| **Performance**          | ✅ Melhor | Boa          |
| **Comunidade**           | Grande    | Muito grande |

**Nossa escolha**: EVE-NG para sua flexibilidade e interface web.

## Instalação e Configuração

### Quanto de RAM preciso?

| Cenário                                    | RAM Recomendada |
| ------------------------------------------ | --------------- |
| **Laboratório básico** (2-3 dispositivos)  | 8 GB            |
| **Laboratório médio** (4-6 dispositivos)   | 16 GB           |
| **Laboratório avançado** (7+ dispositivos) | 32 GB+          |

**Dica**: Use UKSM (memory deduplication) para economizar RAM.

### Meu PC não tem RAM suficiente. E agora?

**Opções**:

1. **Use dispositivos mais leves**:
   - MikroTik: 256MB (não 1GB)
   - Linux TinyCore ao invés de Ubuntu Desktop

2. **Execute menos dispositivos simultaneamente**:
   - Organize labs em etapas
   - Pare dispositivos não utilizados

3. **Aumente swap**:

   ```bash
   fallocate -l 8G /swapfile
   chmod 600 /swapfile
   mkswap /swapfile
   swapon /swapfile
   ```

4. **Use EVE-NG na nuvem** (AWS, GCP, Azure)

### Posso instalar EVE-NG diretamente no Windows?

❌ Não. EVE-NG é baseado em Linux (Ubuntu).

**Opções**:

- ✅ EVE-NG em VM (VMware/VirtualBox)
- ✅ EVE-NG em servidor dedicado
- ❌ WSL2 (não suportado)

### Posso usar VirtualBox ao invés de VMware?

✅ Sim, mas com limitações:

**VirtualBox**:

- ✅ Gratuito
- ⚠️ Performance inferior
- ⚠️ Menos recursos

**VMware Workstation**:

- 💰 Pago (trial disponível)
- ✅ Melhor performance
- ✅ Mais recursos
- ✅ Recomendado

## Dispositivos e Imagens

### Onde consigo imagens de dispositivos?

**Legais e gratuitas**:

- ✅ MikroTik CHR: https://mikrotik.com/download
- ✅ Linux (Ubuntu, Debian): Sites oficiais
- ✅ VyOS: https://vyos.io/

**Cisco, Juniper, etc**:

- Requer conta/licença do fabricante
- ⚠️ Não distribua imagens com direitos autorais

### MikroTik CHR é limitado?

**Licenças MikroTik CHR**:

| Licença         | Velocidade | Preço    | Uso         |
| --------------- | ---------- | -------- | ----------- |
| **Free**        | 1 Mbps     | Gratuito | Laboratório |
| **P1**          | 1 Gbps     | ~$45     | Produção    |
| **P10**         | 10 Gbps    | ~$95     | Produção    |
| **P-Unlimited** | Ilimitado  | ~$250    | Produção    |

**Para laboratório**: Free é suficiente!

### Posso adicionar switches gerenciáveis?

✅ Sim!

**Opções**:

- Linux switch (emulado)
- Cisco vIOS-L2 (requer imagem)
- Open vSwitch (Docker)
- Use MikroTik como switch (bridge + VLANs)

### Como adicionar Windows ao laboratório?

1. **Crie disco virtual**:

   ```bash
   /opt/qemu/bin/qemu-img create -f qcow2 virtioa.qcow2 50G
   ```

2. **Adicione ISO do Windows**:

   ```bash
   # Upload para:
   /opt/unetlab/addons/qemu/win10/cdrom.iso
   ```

3. **No EVE-NG**: Adicione node "Windows"

4. **Instale** normalmente via console

**Dica**: Use Windows 10 LTSC (mais leve)

## Rede e Conectividade

### Como dar internet para os dispositivos?

**Método recomendado**: Cloud0 (pnet0)

1. Adicione Cloud0 ao lab
2. Conecte router ao Cloud0
3. Configure DHCP client ou IP estático no router
4. Configure NAT:
   ```routeros
   /ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade
   ```

### Posso acessar dispositivos do laboratório da minha rede física?

✅ Sim!

**Método 1: Bridge para rede física**

1. Use Cloud0 (pnet0)
2. Conecte dispositivos
3. Configure IPs na mesma subnet da rede física

**Método 2: VPN**

Configure VPN no router do lab para acesso remoto.

### Como conectar dois labs diferentes?

**Método 1: Links dentro do EVE-NG**

Use redes networks para conectar labs.

**Método 2: GRE Tunnel**

```routeros
# Lab 1
/interface gre add name=tunnel-lab2 remote-address=[IP-Lab2] local-address=[IP-Lab1]

# Lab 2
/interface gre add name=tunnel-lab1 remote-address=[IP-Lab1] local-address=[IP-Lab2]
```

### Dispositivos ficam sem IP (DHCP não funciona)

**Verificações**:

1. DHCP server configurado e rodando?
2. DHCP server na mesma VLAN/network?
3. Firewall bloqueando DHCP (porta 67/68)?
4. Interface do DHCP server está UP?

**Solução temporária**: Configure IP estático.

## Performance

### Lab está muito lento. O que fazer?

**Otimizações**:

1. **Aumente recursos da VM EVE-NG**
2. **Habilite UKSM**:
   ```bash
   echo 1 > /sys/kernel/mm/uksm/run
   ```
3. **Reduza dispositivos simultâneos**
4. **Use imagens leves**
5. **Feche aplicações no host**
6. **Use SSD** para VMs

### Console dos dispositivos está lento

**Causas**:

- Cliente Telnet/SSH lento
- EVE-NG sobrecarregado

**Soluções**:

- Use EVE-NG Client Pack
- Reduza número de consoles abertos
- Aumente RAM da VM EVE-NG

### Upload de imagens é muito lento

**Solução**: Aumente limite de upload

```bash
# No EVE-NG
nano /etc/php/8.1/apache2/php.ini

# Alterar:
upload_max_filesize = 2G
post_max_size = 2G
max_execution_time = 3600

# Reiniciar
systemctl restart apache2
```

## Licenças e Custos

### Preciso pagar por algo?

**Gratuito**:

- ✅ EVE-NG Community
- ✅ VMware Workstation Player (uso não-comercial)
- ✅ MikroTik CHR (versão free)
- ✅ Linux (Ubuntu, Debian, etc)

**Pago** (opcional):

- 💰 VMware Workstation Pro (~$200)
- 💰 EVE-NG Pro (~$240/ano)
- 💰 MikroTik CHR licenças P1/P10 (se precisar velocidade)

**Total para laboratório pessoal**: R$ 0,00!

### Vale a pena pagar EVE-NG Pro?

**Para uso pessoal**: Não necessário  
**Para empresa/treinamento**: Recomendado

## Backup e Segurança

### Como fazer backup do laboratório?

**Método 1: Backup de labs**

```bash
# Via SSH no EVE-NG
cd /opt/unetlab/labs/
tar -czf /tmp/backup-labs.tar.gz .

# Download via SCP
scp root@[IP-EVE-NG]:/tmp/backup-labs.tar.gz .
```

**Método 2: Snapshot da VM**

No VMware: VM → Snapshot → Take Snapshot

### Como compartilhar um lab?

```bash
# Exportar lab específico
cd /opt/unetlab/labs/
tar -czf meu-lab.tar.gz Meu-Lab.unl

# Enviar para outro usuário
# Importar: extrair em /opt/unetlab/labs/
```

### EVE-NG é seguro?

**Considerações**:

- ✅ Isolar EVE-NG em rede separada
- ✅ Alterar senhas padrão
- ✅ Habilitar firewall
- ⚠️ Não exponha diretamente à internet
- ✅ Use VPN para acesso remoto

## Certificações e Estudos

### EVE-NG é bom para estudar para certificações?

✅ **Excelente para**:

- CCNA, CCNP (Cisco)
- MTCNA, MTCRE (MikroTik)
- CompTIA Network+
- Estudos de redes em geral

### Posso usar no CCNA/CCNP?

✅ Sim, mas precisa de imagens Cisco:

- Cisco VIOS (Router)
- Cisco VIOS-L2 (Switch)
- Cisco ASA (Firewall)

**Alternativa gratuita**: Use VyOS ou MikroTik (conceitos similares)

### Há cursos específicos de EVE-NG?

**Recursos**:

- 📹 YouTube: Tutoriais gratuitos
- 📚 Documentação oficial: https://www.eve-ng.net/
- 🎓 Udemy: Cursos pagos de EVE-NG + Networking
- 📖 Este guia! 😊

## Problemas Comuns

### "Module virsh not found"

```bash
# Instalar libvirt
apt install -y libvirt-daemon-system libvirt-clients
```

### "Cannot allocate memory"

**Causa**: RAM insuficiente

**Soluções**:

- Aumente RAM da VM EVE-NG
- Pare dispositivos não utilizados
- Adicione swap

### "VNC connection failed"

**Solução**:

- Use Telnet ao invés de VNC
- Ou instale EVE-NG Client Pack

### Navegador não abre consoles

**Causa**: Client Pack não instalado

**Solução**:

1. Baixe EVE-NG Client Pack
2. Instale no seu PC
3. Configure navegador para usar o client pack

## Miscelânea

### Posso rodar EVE-NG em Raspberry Pi?

❌ Não recomendado. ARM não é bem suportado.

### EVE-NG roda em Mac M1/M2?

⚠️ Com dificuldade (ARM64):

- Use VMware Fusion (ARM)
- Performance limitada
- Melhor usar:
  - Mac Intel
  - Ou servidor na nuvem

### Quanto tempo leva para aprender?

| Nível                                    | Tempo Estimado |
| ---------------------------------------- | -------------- |
| **Básico** (criar labs simples)          | 1-2 dias       |
| **Intermediário** (topologias complexas) | 1-2 semanas    |
| **Avançado** (otimizações, VLANs, etc)   | 1-2 meses      |

### Onde encontro mais labs prontos?

**Recursos**:

- Eve-ng.net (labs da comunidade)
- GitHub (procure por "eve-ng labs")
- Fórums de networking
- Este guia (exemplos práticos)

## 🔄 Ainda tem dúvidas?

**Suporte adicional**:

- 📖 Revise os guias específicos
- 🔧 Consulte [Troubleshooting](12-troubleshooting.md)
- 🌐 Fórums EVE-NG: https://www.eve-ng.net/index.php/community/
- 💬 Reddit r/eve_ng: https://www.reddit.com/r/eve_ng/

## 📞 Contato

Para sugestões ou correções neste guia:

- Abra uma issue no repositório
- Ou contribua com melhorias

---

**Última Atualização**: Março 2026  
**Mantido por**: Comunidade Lab EVE-NG

---

**Bons estudos e experimentos no seu laboratório! 🚀**
