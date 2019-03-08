ubuntu-18.04-dev-server
====

powered by [code-server](https://github.com/codercom/code-server)

※ code-server がステキだったので、何かやってみたかっただけ。ハンズオン環境とかに使えるんじゃないんですかね

go や nodejs が使える開発環境を Web ブラウザ経由で提供する

開発環境は Ubuntu 18.04 をベースに、日本語向けのパッケージや開発時によく使うパッケージが含まれている

ユーザーは Web ブラウザから code-server を経由して `user` ユーザーでログインし、ホームディレクトリ以下を自由に使用できる

`user` ユーザーのホームディレクトリは永続化される

## Usage

docker イメージをビルド

```
$ git clone https://github.com/thamaji/docker-ubuntu-18.04-dev-server
$ docker build -t ubuntu-18.04-dev-server docker-ubuntu-18.04-dev-server
```

起動

```
$ docker run \
    -d \
    --name dev-server \
    -p 8443:8443 \
    -v $(pwd)/data:/home/user \
    -e PASSWORD=password \
    ubuntu-18.04-dev-server
```

ブラウザで https://localhost:8443 にアクセスする

パスワードは `PASSWORD` で指定したもの

## Environment

- `UID` ログインユーザーのUID
- `GID` ログインユーザーのGID
- `PASSWORD` ログインユーザーのパスワード兼 code-server のパスワード

## Port

- `8443` code-server のポート

## Volumes

- `/home/user` ユーザーデータ
