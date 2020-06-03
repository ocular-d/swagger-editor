FROM alpine:3.12 as builder

WORKDIR /dist

RUN apk --no-cache add \
	curl \
	bash \
    && curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor.js.map \
    && curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor.js \
    #&& curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor.css.map \
    #&& curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor.css \
    && curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor-standalone-preset.js.map \
    && curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor-standalone-preset.js \
    #&& curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor-bundle.js.map \
    #&& curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/swagger-editor-bundle.js \
    && curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/favicon-32x32.png \
    && curl -O https://raw.githubusercontent.com/swagger-api/swagger-editor/master/dist/favicon-16x16.png

# ---- Release ----
# Copy static docs to alpine-based nginx container.
FROM nginx:1.19-alpine
LABEL maintainer "Sven <sven@ocular-d.tech>"

#RUN apk --no-cache add bash

# Set ownership nginx.pid and cache folder in order to run nginx as non-root user
#RUN touch /var/run/nginx.pid && \
#    chown -R nginx /var/run/nginx.pid && \
#    chown -R nginx /var/cache/nginx

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
# Copy index.html
COPY index.html /usr/share/nginx/html/index.html
# Copy docker-run.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
# Copy dir with dist files
COPY --from=builder /dist /usr/share/nginx/html/dist
COPY swagger-editor.css /usr/share/nginx/html/dist/swagger-editor.css
COPY swagger-editor.css.map /usr/share/nginx/html/dist/swagger-editor.css.map
COPY swagger-editor-bundle.js /usr/share/nginx/html/dist/swagger-editor-bundle.js
COPY swagger-editor-bundle.js.map /usr/share/nginx/html/dist/swagger-editor-bundle.js.map

RUN find /usr/share/nginx/html/ -type f -regex ".*\.\(html\|js\|css\)" -exec sh -c "gzip < {} > {}.gz" \;

#USER nginx

EXPOSE 8080

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
#ENTRYPOINT [ "bash" ]
#CMD ["sh", "/usr/share/nginx/docker-run.sh"]
