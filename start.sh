#!/usr/bin/bash 

docker build -t keycloak-deploy .

docker compose up -d
