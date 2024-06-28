# Stage 1: Build the AMQProxy binary
FROM 84codes/crystal:latest-alpine AS builder
WORKDIR /tmp
COPY shard.yml shard.lock ./
RUN shards install --production
COPY src/ src/
RUN shards build --production --release

# Stage 2: Create the runtime image
FROM alpine:latest
RUN apk add --no-cache libssl3 pcre2 libevent libgcc \
    && addgroup --gid 1000 amqpproxy \
    && adduser --no-create-home --disabled-password --uid 1000 amqpproxy -G amqpproxy
COPY --from=builder /tmp/bin/amqproxy /usr/bin/amqproxy

# Copy the configuration file
COPY amqproxy.conf /etc/amqproxy/amqproxy.conf

USER 1000:1000
EXPOSE 5672
ENTRYPOINT ["/usr/bin/amqproxy", "--config=/etc/amqproxy/amqproxy.conf"]
