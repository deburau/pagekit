ARG HTML_DIR=/var/www/html
ARG VERSION=1.0.18

FROM php:7.2-fpm-alpine
ARG HTML_DIR
ARG CONFIG_DIR
ARG VERSION
ARG NAME=$DOCKER_REPO
ARG VCS_REF=$SOURCE_COMMIT

ENV PAGEKIT_USERNAME=
ENV PAGEKIT_PASSWORD=
ENV PAGEKIT_TITLE=
ENV PAGEKIT_MAIL=
ENV PAGEKIT_DB_DRIVER=
ENV PAGEKIT_DB_PREFIX=
ENV PAGEKIT_DB_HOST=
ENV PAGEKIT_DB_NAME=
ENV PAGEKIT_DB_USERNAME=
ENV PAGEKIT_DB_PASSWORD=
ENV PAGEKIT_LOCALE=

WORKDIR $HTML_DIR

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.8.0/wait /usr/local/bin/
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
ADD https://github.com/pagekit/pagekit/releases/download/${VERSION}/pagekit-${VERSION}.zip /opt/pagekit.zip
ADD entrypoint.sh /usr/local/bin/
ADD start.sh /usr/local/bin/

RUN apk update \
    && apk add nginx \
    && chmod +x /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/start.sh \
    && chmod +x /usr/local/bin/install-php-extensions \
    && chmod +x /usr/local/bin/wait \
    && sync \
    && install-php-extensions apcu_bc pdo_mysql zip

ADD nginx.conf /etc/nginx/nginx.conf

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="pagekit"
LABEL org.label-schema.description="Docker image for the Pagekit modular and lightweight CMS"
LABEL org.label-schema.url="https://pagekit.com/"
LABEL org.label-schema.vcs-url="https://github.com/deburau/pagekit"
LABEL org.label-schema.vcs-ref="$VCS_REF"
LABEL org.label-schema.vendor="YOOtheme"
LABEL org.label-schema.version="$VERSION"
LABEL org.label-schema.docker.cmd="docker run -it -p 8080:80 deburau/pagekit:latest"

EXPOSE 80
VOLUME ["$HTML_DIR"]
ENTRYPOINT ["entrypoint.sh"]
CMD ["start.sh"]
