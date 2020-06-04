FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java11 AS build
# Since JVM has not been ported to alpines musl yet, and still relies on gcc for native binaries
# We'll use the quarkus maven image as build-base

WORKDIR /usr/src/app
USER root
RUN chown -R quarkus /usr/src/app
USER quarkus
COPY --chown=quarkus app/ .

# Lots of workarounds and setup for graalvm to build the native binary
# thankfully none of them end up in the final image
RUN ./mvnw clean package -Pnative


FROM registry.access.redhat.com/ubi8/ubi-minimal

WORKDIR /app
# Since USER only affects RUN, CMD and ENTRYPOINT 
# And not WORKDIR, we have to modify ownership of the workdir
RUN chown nobody. /app

# Copy as Nobody
COPY --from=build --chown=nobody /usr/src/app/target/*-runner /app/quarkusapp

# set up permissions for user `nobody`
RUN chmod 775 /app \
  && chmod -R "g+rwX" /app \
  && chown -R nobody. /app

EXPOSE 8080
USER nobody
CMD ["./quarkusapp", "-Dquarkus.http.host=0.0.0.0"]