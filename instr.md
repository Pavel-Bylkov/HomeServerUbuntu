 Мы сделаем пошаговый алгоритм для установки и настройки **Ubuntu Server**, 
 а также подготовим необходимые скрипты для автоматизации, а затем настроим резервное копирование.

### Этап 1: Скачивание и установка **Ubuntu Server**

1. **Скачивание Ubuntu Server:**
   - Официальная ссылка для скачивания **Ubuntu Server**: [https://ubuntu.com/download/server](https://ubuntu.com/download/server)
   - Выбирай версию **LTS (Long Term Support)** для максимальной стабильности. На текущий момент актуальна **22.04 LTS**.

2. **Создание виртуальной машины** (VM):
   - Ты можешь использовать виртуализацию через программы, такие как:
     - **VirtualBox** (бесплатно)
     - **VMware Workstation Player** (бесплатно)
     - **KVM** (если хочешь использовать Linux на хостовой системе)
   - В настройках виртуальной машины выдели:
     - 2 ядра процессора
     - 4-8 ГБ оперативной памяти (можно меньше для тестирования)
     - Диск на 20-40 ГБ (это для тестов, в реальной системе будет больше)

3. **Процесс установки Ubuntu Server:**
   - Запусти установочный ISO-файл в виртуальной машине.
   - Выбери язык и клавиатуру.
   - Установи базовую систему:
     - **Network configuration**: выбери автоматическое получение IP через DHCP или задай статический IP (это можно изменить позже).
     - **Filesystem**: выбери автоматическую разметку диска с LVM (Logical Volume Manager), чтобы в будущем было удобно управлять хранилищем.
   - Установи сервер SSH, чтобы можно было удаленно подключаться к серверу после установки.

### Этап 2: Установка минимального веб-сервера и файлового хранилища

1. **Установка пакетов для веб-сервера:**
   - После установки системы подключись к серверу через SSH или локально.
   - Обнови систему:
     ```bash
     sudo apt update && sudo apt upgrade -y
     ```

2. **Установка веб-сервера (Nginx или Apache):**
   - **Nginx**:
     ```bash
     sudo apt install nginx -y
     sudo systemctl enable nginx
     sudo systemctl start nginx
     ```
   - **Apache**:
     ```bash
     sudo apt install apache2 -y
     sudo systemctl enable apache2
     sudo systemctl start apache2
     ```

3. **Установка файлового хранилища (Samba для Windows-шар):**
   - Установи **Samba**:
     ```bash
     sudo apt install samba -y
     ```
   - Настрой общую папку (пример):
     - Создай директорию для общего хранилища:
       ```bash
       sudo mkdir -p /srv/samba/share
       sudo chmod 777 /srv/samba/share
       ```
     - Открой файл конфигурации Samba:
       ```bash
       sudo nano /etc/samba/smb.conf
       ```
     - Добавь следующее в конец файла для создания общей папки:
       ```ini
       [Shared]
       path = /srv/samba/share
       browseable = yes
       read only = no
       guest ok = yes
       ```
     - Перезапусти службу Samba:
       ```bash
       sudo systemctl restart smbd
       ```

4. **Настройка программного RAID с mdadm:**
   - Установи **mdadm**:
     ```bash
     sudo apt install mdadm -y
     ```
   - Создай RAID 5 массив (замени `/dev/sdX` на твои диски):
     ```bash
     sudo mdadm --create --verbose /dev/md0 --level=5 --raid-devices=4 /dev/sdX /dev/sdY /dev/sdZ /dev/sdW
     ```
   - Проверь статус массива:
     ```bash
     cat /proc/mdstat
     ```

### Этап 3: Автоматизация настроек с помощью скриптов

Я подготовлю скрипты для автоматической настройки веб-сервера, Samba и RAID. Мы будем их разрабатывать поэтапно, чтобы каждый шаг был понятен.

Давай рассмотрим задачу пошагово. Мы настроим:

1. **Безопасный доступ к общей папке Samba** с поддержкой Mac, Windows и Linux.
2. **Удалённый доступ по SSH через интернет** с защитой от несанкционированных подключений.
3. **Firewall и защитные меры** от внешних атак.

### Этап 1: Настройка доступа к общей папке из локальной сети

Мы уже настроили Samba для общего доступа. Теперь добавим пользователей, настроим права и обеспечим работу с Mac, Windows и Linux.

#### Шаг 1. Настройка прав доступа для Samba

1. Создаём пользователей Samba:
   ```bash
   sudo smbpasswd -a <имя_пользователя>
   ```

2. Убедись, что созданные пользователи имеют доступ к общему каталогу:
   - Открой файл конфигурации Samba:
     ```bash
     sudo nano /etc/samba/smb.conf
     ```
   - Проверь настройки прав:
     ```ini
     [Shared]
     path = /srv/samba/share
     browseable = yes
     read only = no
     guest ok = yes
     create mask = 0777
     directory mask = 0777
     force user = nobody
     ```
   - Перезапусти Samba:
     ```bash
     sudo systemctl restart smbd
     ```

Теперь все пользователи в локальной сети смогут получить доступ к этой папке.

#### Шаг 2. Тестирование на устройствах Mac, Windows и Linux

1. **Windows**: Открой "Проводник" и введи в адресную строку:
   ```bash
   \\<IP-адрес-сервера>\Shared
   ```

2. **Mac**: Используй Finder, выбери "Go" → "Connect to Server", и введи:
   ```bash
   smb://<IP-адрес-сервера>/Shared
   ```

3. **Linux**: Открой файловый менеджер и введи в адресную строку:
   ```bash
   smb://<IP-адрес-сервера>/Shared
   ```

### Этап 2: Настройка удалённого доступа по SSH

1. **Установка и настройка SSH**:
   - Убедись, что SSH установлен и запущен:
     ```bash
     sudo apt install openssh-server -y
     sudo systemctl enable ssh
     sudo systemctl start ssh
     ```

2. **Настройка удалённого доступа**:
   - Открой порт для SSH на роутере (обычно 22). Можно настроить перенаправление порта (например, 2222 снаружи на 22 внутри сети).
   - Добавь дополнительную защиту — например, настроим доступ по ключам SSH вместо пароля:
     ```bash
     ssh-keygen -t rsa -b 4096
     ssh-copy-id user@<IP-сервера>
     ```

   - Отключи вход по паролю:
     ```bash
     sudo nano /etc/ssh/sshd_config
     ```
     Найди и измените следующие строки:
     ```ini
     PermitRootLogin no
     PasswordAuthentication no
     ```
     Перезапусти SSH:
     ```bash
     sudo systemctl restart ssh
     ```

3. **Защита SSH с помощью Fail2ban**:
   Установим **Fail2ban** для защиты от брутфорс-атак на SSH:
   ```bash
   sudo apt install fail2ban -y
   ```

   Настроим Fail2ban для защиты SSH:
   ```bash
   sudo nano /etc/fail2ban/jail.local
   ```

   Добавь следующие строки:
   ```ini
   [sshd]
   enabled = true
   port = 22
   logpath = /var/log/auth.log
   maxretry = 5
   ```

   Перезапусти Fail2ban:
   ```bash
   sudo systemctl restart fail2ban
   ```

### Этап 3: Настройка Firewall

Для базовой защиты мы настроим **UFW (Uncomplicated Firewall)**:

1. **Установка UFW**:
   ```bash
   sudo apt install ufw -y
   ```

2. **Настройка правил Firewall**:
   - Разрешим доступ к SSH:
     ```bash
     sudo ufw allow 22
     ```

   - Разрешим Samba:
     ```bash
     sudo ufw allow samba
     ```

   - Разрешим HTTP (если веб-сервер установлен):
     ```bash
     sudo ufw allow 'Nginx Full'
     ```

   - Включаем UFW:
     ```bash
     sudo ufw enable
     ```

3. **Проверка статуса UFW**:
   ```bash
   sudo ufw status verbose
   ```

### Этап 4: Подключение через интернет с использованием статического IP

1. **Настройка роутера**:
   - В роутере настроить статический IP и перенаправление портов для SSH, Samba и веб-сервера (если нужно).

2. **Доступ через SSH**:
   - Теперь ты сможешь подключиться к серверу через интернет по SSH с использованием статического IP:
     ```bash
     ssh user@<статический-IP>
     ```

### Скрипты для автоматизации настройки безопасности:

#### Скрипт 1: Настройка SSH и Fail2ban
Создай файл `setup_ssh_fail2ban.sh`:


#### Скрипт 2: Настройка UFW
Создай файл `setup_ufw.sh`:


### Этап 5: Резервное копирование

После завершения настройки безопасности, можно настроить резервное копирование системы. Используем **rsync** или **Clonezilla** для создания бэкапа и его восстановления.

Сообщи, как идут дела с тестированием скриптов, и мы продолжим с настройкой резервного копирования.