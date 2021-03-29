FROM harbor.miracum.org/cbioportal/cbioportal:${RELEASE:-latest} as static

FROM nginx:stable-alpine
COPY --from=static /cbioportal-webapp /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./cbioportal.conf /etc/nginx/conf.d/default.conf
