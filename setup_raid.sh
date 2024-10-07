#!/bin/bash
# chmod +x setup_raid.sh
# Установка mdadm
echo "Устанавливаем mdadm..."
sudo apt install mdadm -y

# Создание RAID 5
echo "Создаем RAID 5 массив..."
sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sdX /dev/sdY /dev/sdZ /dev/sdW

# Проверка состояния RAID
echo "Проверяем состояние массива..."
cat /proc/mdstat

# Создание конфигурационного файла mdadm
echo "Сохраняем конфигурацию RAID..."
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

# Обновление initramfs
sudo update-initramfs -u
