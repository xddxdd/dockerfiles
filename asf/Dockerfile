FROM microsoft/dotnet:runtime
MAINTAINER Lan Tian <lantian@lantian.pub>

ENV ASF_VERSION=3.0.5.5
RUN apt-get update -q \
    && apt-get upgrade -y \
    && apt-get install -y curl libunwind8 gettext unzip wget \
    && apt-get clean \
    && mkdir /asf \
    && cd /asf \
    && wget -O asf.zip https://github.com/JustArchi/ArchiSteamFarm/releases/download/${ASF_VERSION}/ASF-generic.zip \
    && unzip asf.zip \
    && rm asf.zip
WORKDIR /asf
HEALTHCHECK CMD curl 127.0.0.1:1242
ENTRYPOINT dotnet ArchiSteamFarm.dll -- --server
