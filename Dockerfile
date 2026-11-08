FROM php:8.2-cli

# Установка системных зависимостей, Git и расширений PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    && docker-php-ext-install zip pdo pdo_mysql

# Установка Node.js (версия 20, нужна для сборки Vite и фронтенда)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Установка официального Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Сначала копируем зависимости, чтобы Docker кешировал слои
COPY . .

# Установка PHP и Node.js зависимостей + сборка фронта через Vite
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

# Настройка порта для Render
ENV PORT=10000
EXPOSE 10000

# Генерация ключа, кеширование конфигов и запуск сервера Laravel
CMD php artisan key:generate --force && php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=10000
