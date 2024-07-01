FROM dart:latest AS build

WORKDIR /app-be

COPY . ./
COPY pubspec.* ./
RUN dart pub get
COPY . .

RUN dart pub get --offline
RUN dart compile exe bin/shortner.dart -o bin/app-be

# Get libsqlite3.so
FROM debian:bullseye-slim as sqlite

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libsqlite3-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives && \
    cp /usr/lib/$(uname -m)-linux-gnu/libsqlite3.so /tmp/libsqlite3.so

FROM scratch
EXPOSE 9090
COPY --from=build /runtime/ /
COPY --from=build /app-be/bin/app-be /app-be/bin/
COPY --from=build /app-be/views/ /views/
COPY --from=sqlite /tmp/libsqlite3.so /usr/lib/libsqlite3.so

CMD ["/app-be/bin/app-be"]
  