#!/bin/bash
# chmod +x setup_webserver.sh // Сделай скрипт исполняемым
# Обновление системы
echo "Обновляем систему..."
sudo apt update && sudo apt upgrade -y

# Установка Nginx
echo "Устанавливаем Nginx..."
sudo apt install nginx -y

# Запуск и включение Nginx
echo "Запускаем и включаем Nginx..."
sudo systemctl enable nginx
sudo systemctl start nginx

# Создание простой HTML-страницы
echo "Создаем тестовую страницу..."
echo "<html><head><title>Мой сервер</title></head><body><h1>Добро пожаловать на сервер!</h1></body></html>" | sudo tee /var/www/html/index.html

# Проверка состояния Nginx
echo "Проверяем состояние Nginx..."
sudo systemctl status nginx
