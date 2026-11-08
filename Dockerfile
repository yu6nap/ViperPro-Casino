FROM php:8.2-cli

# Установка системных зависимостей, ICU для intl, Git и расширений PHP
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install zip pdo pdo_mysql intl

# Установка Node.js (версия 20, нужна для сборки Vite и фронтенда)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Установка официального Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Копируем проект
COPY . .

# Установка зависимостей с игнорированием платформенных ошибок (на всякий случай) и сборка фронта
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-intl
RUN npm install && npm run build

# Настройка порта для Render
ENV PORT=10000
EXPOSE 10000

# Генерация ключа, кеширование и запуск сервера
CMD php artisan key:generate --force && php artisan config:cache && php artisan route:cache && php artisan serve --host=0.0.0.0 --port=10000
