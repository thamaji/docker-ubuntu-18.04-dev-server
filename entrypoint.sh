#!/bin/bash
set -e -u -x

groupadd \
    --gid ${GID} \
    user

useradd \
    --uid ${UID} \
    --gid ${GID} \
    --groups sudo \
    --home-dir /home/user \
    --shell /bin/bash \
    user

echo "user:${PASSWORD}" | chpasswd

chown user:user /home/user
[ -e /home/user/.bashrc ] || cp /root/.bashrc /home/user/.bashrc && chown user:user /home/user/.bashrc
[ -e /home/user/.profile ] || cp /root/.profile /home/user/.profile && chown user:user /home/user/.profile

source /etc/profile
gosu user code-server --data-dir=/home/user/.code-server --host=0.0.0.0 --port=8443 --password=${PASSWORD} ${@}
