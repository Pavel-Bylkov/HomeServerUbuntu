#!/bin/bash
# chmod +x setup_samba.sh
# Установка Samba
echo "Устанавливаем Samba..."
sudo apt install samba -y

# Создание общей папки
echo "Создаем папку для общего доступа..."
sudo mkdir -p /srv/samba/share
sudo chmod 777 /srv/samba/share

# Настройка Samba
echo "Настраиваем Samba..."
sudo bash -c 'cat <<EOF >> /etc/samba/smb.conf
[Shared]
path = /srv/samba/share
browseable = yes
read only = no
guest ok = yes
EOF'

# Перезапуск Samba
echo "Перезапускаем Samba..."
sudo systemctl restart smbd

# Проверка статуса Samba
echo "Проверяем статус Samba..."
sudo systemctl status smbd
