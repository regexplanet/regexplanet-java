# this one makes 352 MB image
#FROM jetty:12-jre21-eclipse-temurin
# this one makes a 271 MB image
FROM jetty:12-jre21-alpine

ARG COMMIT=(not set)
ARG LASTMOD=(not set)
ENV COMMIT=$COMMIT
ENV LASTMOD=$LASTMOD

USER jetty

# why the f*** isn't in the Dockerfile README???
RUN java -jar "$JETTY_HOME/start.jar" --add-modules=ee10-webapp,ee10-deploy,ee10-jsp,ee10-jstl,ee10-websocket-jetty,ee10-websocket-jakarta

COPY ./www /var/lib/jetty/webapps/ROOT
