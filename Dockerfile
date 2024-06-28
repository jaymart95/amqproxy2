# Stage 1: Build the AMQProxy binary
FROM 84codes/crystal:latest-alpine AS builder
WORKDIR /tmp
COPY amqproxy/shard.yml amqproxy/shard.lock ./
RUN shards install --production
COPY amqproxy/src/ src/
RUN shards build --production --release

# Stage 2: Create the runtime image
FROM alpine:latest
RUN apk add --no-cache libssl3 pcre2 libevent libgcc \
    && addgroup --gid 1000 amqpproxy \
    && adduser --no-create-home --disabled-password --uid 1000 amqpproxy -G amqpproxy
COPY --from=builder /tmp/bin/amqproxy /usr/bin/amqproxy
USER 1000:1000
EXPOSE 5672
ENTRYPOINT ["/usr/bin/amqproxy", "--config=/amqproxy/amqproxy.conf
