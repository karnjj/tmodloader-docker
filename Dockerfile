FROM alpine:3.11.6 as build

ARG TMOD_VERSION=2022.07.58.8
ARG TERRARIA_VERSION=1436

RUN apk update &&\
    apk add --no-cache curl unzip 

WORKDIR /terraria-server

RUN curl -SLO "https://github.com/tModLoader/tModLoader/releases/download/v${TMOD_VERSION}/tModLoader.zip" &&\
    unzip tModLoader.zip &&\
    rm tModLoader.zip &&\
    chmod u+x ./LaunchUtils/ScriptCaller.sh

FROM debian:stable-slim as mod-dowload

WORKDIR /steam

COPY install.txt .
COPY Setup_tModLoaderServer.sh .

RUN chmod +x Setup_tModLoaderServer.sh

RUN apt update &&\
    apt -y install lib32gcc-s1 curl

RUN curl -SLO "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" &&\
    tar -xzf steamcmd_linux.tar.gz &&\
    rm steamcmd_linux.tar.gz &&\
    chmod u+x steamcmd.sh

RUN ./Setup_tModLoaderServer.sh

FROM debian:stable-slim

WORKDIR /terraria-server
COPY --from=build /terraria-server ./
COPY --from=mod-dowload /tmod ./

RUN apt update &&\
    apt -y install procps tmux bash curl cron

RUN apt -y install libicu-dev

RUN ln -s ${HOME}/.local/share/Terraria/ /terraria
COPY inject.sh /usr/local/bin/inject
COPY handle-idle.sh /usr/local/bin/handle-idle

EXPOSE 7777
ENV TMOD_SHUTDOWN_MSG="Shutting down!"
ENV TMOD_AUTOSAVE_INTERVAL="*/10 * * * *"
ENV TMOD_IDLE_CHECK_INTERVAL=""
ENV TMOD_IDLE_CHECK_OFFSET=0

COPY config.txt entrypoint.sh ./
RUN chmod +x entrypoint.sh /usr/local/bin/inject /usr/local/bin/handle-idle

ENTRYPOINT [ "/terraria-server/entrypoint.sh" ]
