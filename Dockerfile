# Use an official PHP runtime as a parent image
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    g++ \
    libpq-dev \
    libssl-dev \
    netcat-openbsd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip intl calendar

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Node.js (for Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs


# Copy existing application directory contents
COPY . /var/www

# Run Composer install
RUN composer install --optimize-autoloader --no-dev

# Install NPM dependencies
RUN npm install

# Build Vite assets
RUN npm run build

# Change permissions
RUN chown -R www-data:www-data /var/www

# Add an entrypoint script to run migrations at runtime
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 8000 and run PHP's built-in server
EXPOSE 8000

# Set entrypoint to run the custom script
ENTRYPOINT ["docker-entrypoint.sh"]
