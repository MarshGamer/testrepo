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
    gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Yarn
RUN curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn


# Copy existing application directory contents
COPY . /var/www

# Install Yarn dependencies
RUN yarn install

# Build Vite assets
RUN yarn run build

# Run Composer install
RUN composer install --optimize-autoloader --no-dev

# Change permissions
RUN chown -R www-data:www-data /var/www

# Add an entrypoint script to run migrations at runtime
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose port 8000 and run PHP's built-in server
EXPOSE 8000

# Set entrypoint to run the custom script
ENTRYPOINT ["docker-entrypoint.sh"]
