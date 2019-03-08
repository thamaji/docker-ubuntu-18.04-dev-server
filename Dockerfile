FROM ubuntu:18.04

# aptリポジトリ
RUN set -x \
	&& sed -e 's_http://archive.ubuntu.com/_http://jp.archive.ubuntu.com/_' -i /etc/apt/sources.list

# manを有効化
RUN set -x \
    && sed -i /etc/dpkg/dpkg.cfg.d/excludes -e '/\/usr\/share\/man\/*/d' \
    && apt-get update \
    && dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -y --reinstall \
    && apt-get install -y --no-install-recommends man-db manpages-ja manpages-ja-dev \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# CA証明書更新
RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates \
	&& apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# タイムゾーン
RUN set -x \
	&& apt-get update \
    && apt-get install -y --no-install-recommends tzdata \
	&& apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
    && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
	&& echo Asia/Tokyo > /etc/timezone

# 日本語
RUN set -x \
	&& apt-get update \
    && apt-get install -y --no-install-recommends language-pack-ja-base language-pack-ja \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
ENV LANG=ja_JP.UTF-8

# gosu（entrypoint.shでcode-serverの実行ユーザーにsudoするため）
RUN set -x \
	&& apt-get update \
    && apt-get install -y --no-install-recommends curl \
	&& curl -fSsL -o /usr/bin/gosu https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64 \
	&& chmod +x /usr/bin/gosu \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# code-server
ARG version=1.31.1-100

RUN set -x \
	&& apt-get update \
    && apt-get install -y --no-install-recommends openssl net-tools \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN set -x \
    && curl -fSsL https://github.com/codercom/code-server/releases/download/${version}/code-server-"${version}"-linux-x64.tar.gz | tar xz -C /tmp \
    && mv /tmp/code-server-"${version}"-linux-x64/code-server /usr/local/bin

# 一般的によく使うもの
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        cmake \
        git \
        inetutils-traceroute \
        iputils-ping \
        jo \
        jq \
        less \
        net-tools \
        nmap \
        openssh-client \
        rsync \
        sudo \
        tig \
        tmux \
        unzip \
        vim \
        zip \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Golang
ARG go_version=1.12

RUN set -x \
    && curl -fSsL https://dl.google.com/go/go"${go_version}".linux-amd64.tar.gz | tar xz -C /usr/local \
    && echo 'export GOROOT=/usr/local/go' >> /etc/profile.d/go.sh \
    && echo 'export PATH=$PATH:$GOROOT/bin' >> /etc/profile.d/go.sh \
    && echo 'export GOPATH=$HOME/go' >> /root/.bashrc \
    && echo 'export PATH=$PATH:$GOPATH/bin' >> /root/.bashrc

# Node.js
ARG node_version=stable

RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs npm \
    && npm install n -g \
    && n "${node_version}" \
    && apt-get purge -y nodejs npm \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

VOLUME /home/user

EXPOSE 8443

ENV UID=1000
ENV GID=1000
ENV PASSWORD=password

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/home/user" ]