FROM ghcr.io/buschlab/cbioportal:${RELEASE:-latest} as static

FROM openresty/openresty:1.21.4.1-7-alpine-fat
COPY ./start.sh /start.sh
RUN apk update && apk add git ca-certificates && rm -rf /var/cache/apk/*
COPY --from=static /cbioportal-webapp /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-openidc
ENTRYPOINT [ "/start.sh" ]