#!/bin/bash

# start Redis-Server
redis-server /etc/redis/redis.conf

# start PostgreSQL
/etc/init.d/postgresql start

# get latest source
git pull

# install needed gems
sudo -E -u bamzooka bundle install

# start mailcatcher
mailcatcher --http-ip 0.0.0.0

# run the benchmark
sudo -E -u bamzooka ruby script/bench.rb
