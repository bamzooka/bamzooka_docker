#!/bin/bash
NAME="bamzooka/bamzooka"
echo "+=======================+"
echo "| BUILDING DOCKER IMAGE |"
echo "+=======================+"

echo -n "Do you want to push to Docker after the build? (y/n)"
read want_to_push
if [ "$want_to_push" == "y" ]; then
  echo "OK, will push image to docker.com"
  sleep 2
else
  echo "OK, just building then, no pushing anything..."
  sleep 2
fi

# Build the image

set -xe
APP=./image/base/bamzooka
rm -rf $APP # remove previous build if any
git clone --depth=1 git@github.com:metadot/metadot-workspace.git $APP
rm -f $APP/apps/bamzooka-backend/log/*
rm -rf $APP/apps/bamzooka-backend/tmp

VERSION=$(date +%Y%m%d.%H%M%S)
BASE_VERSION="2.0"
FULLNAME=$NAME:$BASE_VERSION.$VERSION
docker build image/base -t $FULLNAME
set +xe
rm -rf $APP

echo "+=======================+"
echo "|   IMAGE BUILD DONE    |"
echo "+=======================+"

if [ "$want_to_push" == "y" ]; then
  echo "Pushing image to docker.com"
  sleep 2
  set -xe
  ./push_docker.sh $FULLNAME
  set +xe
  echo "+"
  echo "|"
  echo "|"
  echo "|"
  echo "| IMAGE pushed to docker.com |"
  echo "| VERSION: $FULLNAME"
  echo "|"
  echo "+----------> ALL DONE!!!"
else
  echo "Not pushing image to docker.com"
  sleep 2
fi

echo "REMEMBER to update the "
exit 0
