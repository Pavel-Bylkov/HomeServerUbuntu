#!/bin/bash

# Установка UFW
sudo apt install ufw -y

# Настройка правил
sudo ufw allow 22
sudo ufw allow samba
sudo ufw allow 'Nginx Full'

# Включение UFW
sudo ufw enable

# Проверка статуса
sudo ufw status verbose

echo "Настройка UFW завершена."
