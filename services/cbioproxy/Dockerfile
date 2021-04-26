FROM ghcr.io/buschlab/cbioportal:${RELEASE:-latest} as static

FROM openresty/openresty:alpine-fat
COPY --from=static /cbioportal-webapp /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf \
    && /usr/local/openresty/luajit/bin/luarocks install lua-resty-openidc
