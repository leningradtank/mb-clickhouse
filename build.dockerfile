# docker run -d \
#    --name some-clickhouse-server \
#    --ulimit nofile=262144:262144 \
#    --volume=$(pwd)/data:/var/lib/clickhouse \
#    --volume=$(pwd)/logs:/var/log/clickhouse-server \
#    --volume=$(pwd)/configs/memory_adjustment.xml:/etc/clickhouse-server/config.d/memory_adjustment.xml \
#    --cap-add=SYS_NICE \
#    --cap-add=NET_ADMIN \
#    --cap-add=IPC_LOCK \
#    --cap-add=SYS_PTRACE \
#    --network=host \
#    yandex/clickhouse-server:21.1.7

# docker exec -it some-clickhouse-server clickhouse-client
# docker exec -it some-clickhouse-server bash









# docker run -d --name clickhouse-syncer --ulimit nofile=262144:262144 clickhouse/clickhouse-syncer

FROM ubuntu:18.04

ARG repository="deb http://repo.yandex.ru/clickhouse/deb/stable/ main/"
ARG version=19.1.13
ARG gosu_ver=1.10

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        dirmngr \
        gnupg \
    && mkdir -p /etc/apt/sources.list.d \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv E0C56BD4 \
    && echo $repository > /etc/apt/sources.list.d/clickhouse.list \
    && apt-get update \
    && env DEBIAN_FRONTEND=noninteractive \
        apt-get install --allow-unauthenticated --yes --no-install-recommends \
            clickhouse-common-static=$version \
            clickhouse-client=$version \
            clickhouse-server=$version \
            libgcc-7-dev \
            locales \
            tzdata \
            wget \
    && rm -rf \
        /var/lib/apt/lists/* \
        /var/cache/debconf \
        /tmp/* \
    && apt-get clean

ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /bin/gosu

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN mkdir /docker-entrypoint-initdb.d

COPY docker_related_config.xml /etc/clickhouse-server/config.d/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x \
    /entrypoint.sh \
    /bin/gosu

EXPOSE 9000 8123 9009
VOLUME /var/lib/clickhouse

ENV CLICKHOUSE_CONFIG /etc/clickhouse-server/config.xml

ENTRYPOINT ["/entrypoint.sh"]