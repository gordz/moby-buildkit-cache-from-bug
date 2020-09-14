#!/bin/bash

docker ps -qa | xargs docker rm -f
docker images -q | xargs docker rmi -f
docker system prune -f
