# ⚠️ DEPRECATED, see https://github.com/koillection/koillection dor Dockerfile ⚠️

# Dockerfile for Koillection

- This is an image for running Koillection using `Docker`.

- It includes `php7` and `nginx`, you only need to add a `postgres` server.

- *IMPORTANT :* Please note that a running `postgres` server must be available before starting the Koillection container. 

## docker-compose
    version: '3'

    services:
        # Koillection
        koillection:
            image: koillection/koillection
            container_name: koillection
            restart: unless-stopped
            ports:
                - 80:80
            environment:
                - DB_DRIVER=pdo_pgsql (or pdo_mysql)
                - DB_NAME=koillection
                - DB_HOST=db
                - DB_PORT=5432 (3306 for mysql)
                - DB_USER=root
                - DB_PASSWORD=root
                - DB_VERSION=12.2
                - PHP_TZ=Europe/Paris
                - HTTPS_ENABLED=1 (1 or 0)
            depends_on:
                - db
            volumes:
                - ./docker/volumes/koillection/conf:/conf
                - ./docker/volumes/koillection/uploads:/uploads

        # Database : choose one of the following
        db:
            image: postgres:latest
            container_name: db
            restart: unless-stopped
            environment:
                - POSTGRES_DB=koillection
                - POSTGRES_USER=root
                - POSTGRES_PASSWORD=root
            volumes:
                - "./volumes/postgresql:/var/lib/postgresql/data"

        db:
            image: mysql:latest
            container_name: db       
            restart: unless-stopped 
            environment:
                - MYSQL_ROOT_PASSWORD=root
                - MYSQL_DATABASE=koillection
                - MYSQL_USER=root
            volumes:
                - "./docker/volumes/mysql:/var/lib/mysql"
