#!/bin/sh

# perform flutter clean to clean all the current build
flutter clean

# perform the flutter pub get
flutter pub get

# rebuild the flutter web apps
flutter build web --release -t lib/main.prod.dart

# build the docker based on the build
docker build -t adimartha/my_wealth .

# once finished build then get the current tag from the environment file
tag = `cat env/.prod.env | sed '2q;d' | awk -F "=" '{print $2}' | sed "s/['\"]//g" | awk -F "-" '{print $1}'`

# then tag the latest docker image to the current tag
docker image tag adimartha/my_wealth:latest adimartha/my_wealth:$tag

# push both of the image to the docker repo
docker image push adimartha/my_wealth:latest
docker image push adimartha/my_wealth:$tag