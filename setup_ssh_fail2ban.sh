#!/bin/bash

# Установка SSH и Fail2ban
sudo apt update && sudo apt install openssh-server fail2ban -y

# Настройка SSH
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Перезапуск SSH
sudo systemctl restart ssh

# Настройка Fail2ban
sudo bash -c 'cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 22
logpath = /var/log/auth.log
maxretry = 5
EOF'

# Перезапуск Fail2ban
sudo systemctl restart fail2ban

echo "Настройка SSH и Fail2ban завершена."
