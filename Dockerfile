FROM node:12-stretch AS screeps

ARG GOSU_VERSION=1.12
RUN dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true 

ENV SCREEPS_VERSION 4.2.12
WORKDIR /screeps
RUN yarn add screeps@"$SCREEPS_VERSION"
RUN yarn add screepsmod-mongo screepsmod-admin-utils screepsmod-auth screeps-bot-tooangel

FROM node:12-stretch
VOLUME /screeps
WORKDIR /screeps

COPY --from=screeps /screeps /screeps.base

ENV DB_PATH=/screeps/db.json \
    ASSET_DIR=/screeps/assets \
    MODFILE=/screeps/custom_mods.json \
    GAME_PORT=21025 \
    GAME_HOST=0.0.0.0 \
    CLI_PORT=21026 \
    CLI_HOST=0.0.0.0 \
    DRIVER_MODULE="@screeps/driver"

COPY --from=screeps /usr/local/bin/gosu /usr/local/bin/gosu
COPY config.yml /screeps.base
COPY custom_mods.json /screeps.base
COPY start.sh /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/start.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
HEALTHCHECK CMD curl -sSLf http://localhost:21025 >/dev/null || exit 1

CMD ["run"]
