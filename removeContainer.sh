#!/usr/bin/env bash

docker rm $(docker ps -a -q)
docker rmi $(docker images -q) -f

sleep 5