ARG NGINX_VERSION=latest

FROM nginx:${NGINX_VERSION} AS nginx
ARG USER=nginx
ARG UID=101
ARG GID=101

COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
COPY snippets/ /etc/nginx/snippets/
COPY templates/ /etc/nginx/templates/

COPY --chown=$USER:$USER html/ /usr/share/nginx/html/

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
    curl -sL https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-Linux-x86_64 -o /usr/bin/envsubst && \
    chmod +x /usr/bin/envsubst; fi; \
    if [ "$(cat /etc/apk/arch)" = "x86_64" ]; then \
    curl -sL https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-Linux-x86_64 -o /usr/local/bin/envsubst && \
    chmod +x /usr/local/bin/envsubst; fi;
