FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java11 AS build
# Since JVM has not been ported to alpines musl yet
# and quarkus still relies on gcc for native binaries
# We'll use the quarkus maven image as build-base


# Lots of workarounds and setup for graalvm and quarkus to build the native binary
# thankfully none of them end up in the final image
WORKDIR /usr/src/app
USER root
RUN chown -R quarkus /usr/src/app
USER quarkus
COPY --chown=quarkus app/ .

RUN ./mvnw clean package -Pnative


# Due to the very same reason of musl not playing along just yet
# we will use the redhat minimal image for delivery
FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /app
# Since the user should always be nobody (imho) and the USER-Directive only affects RUN, CMD and ENTRYPOINT 
# But not WORKDIR, we have to modify ownership of the workdir
RUN chown nobody. /app

# Copy as nobody
COPY --from=build --chown=nobody /usr/src/app/target/*-runner /app/quarkusapp

# Set up permissions for user `nobody`
RUN chmod 775 /app \
  && chmod -R "g+rwX" /app \
  && chown -R nobody. /app

EXPOSE 8080
USER nobody

# Tell quarkus to listen on all interfaces, instead of localhost
CMD ["./quarkusapp", "-Dquarkus.http.host=0.0.0.0"]
