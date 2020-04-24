# Dockerfile for Koillection

- This is an image for running Koillection using `Docker`.

- It includes `php7` and `nginx`, you only need to add a `postgres` server.

- *IMPORTANT :* Please note that a running `postgres` server must be available before starting the Koillection container. 

## docker-compose

    koillection:
        image: benjaminjonard/koillection:dev
        container_name: koillection
        restart: unless-stopped
        ports:
            - 80:80
        environment:
            - DB_NAME=koillection
            - DB_HOST=postgres
            - DB_PORT=5432
            - DB_USER=root
            - DB_PASSWORD=root
            - DB_VERSION=10.4
            - PHP_TZ=Europe/Paris
        depends_on:
            - postgres
        volumes:
            - ./:/var/www/koillection

    postgres:
        image: postgres:alpine
        container_name: postgres
        restart: unless-stopped
        ports:
            - "5432:5432"
        environment:
            - POSTGRES_DB=koillection
            - POSTGRES_USER=root
            - POSTGRES_PASSWORD=root
        volumes:
            - "./volumes/postgresql:/var/lib/postgresql/data"
