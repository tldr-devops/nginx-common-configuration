FROM nginx:latest

RUN mkdir -p /workspace/sites-enabled; \
cp /etc/nginx/conf.d/default.conf /workspace/sites-enabled; \
rm -rf /etc/nginx/nginx.conf /etc/nginx/conf.d /etc/nginx/snippets \
/etc/nginx/templates /var/log/nginx/access.log /var/log/nginx/error.log; \
ln -s /workspace/nginx.conf /etc/nginx/nginx.conf; \
ln -s /workspace/conf.d /etc/nginx/conf.d; \
ln -s /workspace/snippets /etc/nginx/snippets; \
ln -s /workspace/templates /etc/nginx/templates

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
    curl -sL https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-Linux-x86_64 -o /usr/bin/envsubst && \
    chmod +x /usr/bin/envsubst; fi; \
    if [ "$(cat /etc/apk/arch)" = "x86_64" ]; then \
    curl -sL https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-Linux-x86_64 -o /usr/local/bin/envsubst && \
    chmod +x /usr/local/bin/envsubst; fi;
