# README

## Abstract
dockerからSSH接続してホストにインストールされたVLCを操作します。
基本的に作ったもの自体は自分用なので操作の細かい説明はないです。

## Install
下記の手順に倣って進めます。

https://docs.docker.com/compose/rails/

0. docker-compose.yml, database.ymlで"***"になっている部分を埋める
    * HOST_MUSIC_ROOTは音楽のファイルがあるフォルダーのパスを書いてください。ここから下のフォルダーをコンテナにマウントして探索します。
0. ```docker-compose run --no-deps web rails new . --skip-bundle --force --database=postgresql```
0. ```sudo chown -R $USER:$USER .```
0. ```docker-compose build```
0. ```cp app_sub/database.yml config/database.yml```
0. ```docker-compose up -d```
0. dockerコンテナに入り、"init.sh"を実行する

うまくいけば ```http://<HOST IP Address>:8895/```で接続できると思います。
もしかしたらfavicon.icoが必要かもしれません。

## System Information

* Ruby version
    + Ruby 2.5.8
    + Rails 5.2.4.4
    + Docker version 20.10.2

* System dependencies
    + DockerのホストにVLCをインストールしてください。
