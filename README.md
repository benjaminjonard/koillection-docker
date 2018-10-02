# Dockerfile for Koillection

- This is an image for running Koillection using `Docker`.

- It includes `php7` and `nginx`, you only need to add a `postgres` server.

- *IMPORTANT :* Please note that a running `postgres` server must be available before starting the Koillection container. 

## docker-compose

    koillection:
        image: koillection/koillection:latest
        container_name: koillection
        restart: always
        ports:
            - 80:8880
        environment:
            - DATABASE_URL=pgsql://root:root@postgres:5432/koillection?charset=utf8&serverVersion=10.4
        depends_on:
            - postgres
        volumes:
            - "./volumes/koillection/public/uploads:/koillection/public/uploads"

    postgres:
        image: postgres:alpine
        container_name: postgres
        restart: always
        ports:
            - "5432:5432"
        environment:
            - POSTGRES_DB=koillection
            - POSTGRES_USER=root
            - POSTGRES_PASSWORD=root
        volumes:
            - "./volumes/postgresql:/var/lib/postgresql/data"
