# pagekit
Docker setup for pagekit, the modern Open Source CMS

# Usage

This is a complete example for running pagekit using a MySQL database and running behind a traefik reverse proxy.

Create a `.env` file and adjust content with your information:

```
PAGEKIT_USERNAME=admin
PAGEKIT_PASSWORD=<my-secret-password-1>
PAGEKIT_TITLE=
PAGEKIT_MAIL=
PAGEKIT_DB_DRIVER=mysql
PAGEKIT_DB_PREFIX=
PAGEKIT_DB_HOST=db
PAGEKIT_DB_NAME=pagekit
PAGEKIT_DB_USERNAME=pagekit
PAGEKIT_DB_PASSWORD=<my-secret-password-2>
PAGEKIT_LOCALE=
MYSQL_ROOT_PASSWORD=<my-secret-password-3>
```

Create a `docker-compose.yaml` file and adjust content with your information:

```yaml
version: '3'

services:
  db:
    image: mariadb
    volumes:
      - ./database:/var/lib/mysql:rw
    restart: always
    networks:
      - pagekit
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${PAGEKIT_DB_NAME}
      MYSQL_USER: ${PAGEKIT_DB_USERNAME}
      MYSQL_PASSWORD: ${PAGEKIT_DB_PASSWORD}

  pagekit:
    image: deburau/pagekit:latest
    container_name: pagekit
    depends_on:
      - db
    hostname: pagekit.example.com
    restart: always
    volumes:
      - ./pagekit:/var/www/html:rw
      - ./log:/var/log/nginx:rw
    networks:
      traefik:
      pagekit:
    environment:
      - WAIT_HOSTS=db:3306
      - PAGEKIT_USERNAME
      - PAGEKIT_PASSWORD
      - PAGEKIT_TITLE
      - PAGEKIT_MAIL
      - PAGEKIT_DB_DRIVER
      - PAGEKIT_DB_PREFIX
      - PAGEKIT_DB_HOST
      - PAGEKIT_DB_NAME
      - PAGEKIT_DB_USERNAME
      - PAGEKIT_DB_PASSWORD
      - PAGEKIT_LOCALE
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"
      - "traefik.http.routers.pagekit.rule=Host(`pagekit.example.com`)"
      - "traefik.http.routers.pagekit.entrypoints=websecure"
      - "traefik.http.routers.pagekit.tls=true"
      - "traefik.http.routers.pagekit.tls.domains[0].main=pagekit.example.com"
      - "traefik.http.routers.pagekit.service=pagekit"
      - "traefik.http.services.pagekit.loadbalancer.server.port=80"
      - "traefik.http.services.pagekit.loadbalancer.server.scheme=http"
      - "traefik.http.services.pagekit.loadbalancer.passhostheader=true"

networks:
  traefik:
    external: true
  pagekit:
    name: pagekit
```

Run it with

```sh
docker-compose up -d
```

Watch logs with

```sh
docker-compose logs -f
```
