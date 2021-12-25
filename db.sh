#!/bin/bash

docker pull yandex/clickhouse-server && #pulling latest instance of clickhouse
docker run -d --name mb-clickhouse -p 8123:8123 --ulimit nofile=262144:262144 yandex/clickhouse-server && #starting a custom server with port forwarding 0.0.0.0:8123->8123/tcp
#docker run -it --rm --link mb-clickhouse:clickhouse-server yandex/clickhouse-client --host clickhouse-server #connecting to the damn container and using cickhouse-client
docker exec -it mb-clickhouse /bin/sh &&
apt-get update 