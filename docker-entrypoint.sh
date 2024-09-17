#!/bin/bash

# Wait for the database to be ready (you can customize this for your DB engine)
#echo "Waiting for database connection..."
#while ! nc -z $DB_HOST $DB_PORT; do
#  sleep 1
#done

# Run migrations
echo "Running migrations..."
php artisan migrate --force

# Start the PHP server
echo "Starting PHP server..."
php artisan serve --host=0.0.0.0 --port=8000
