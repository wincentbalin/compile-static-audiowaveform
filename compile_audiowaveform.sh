#!/bin/sh -x
#
# Create compile_audiowaveform Docker image, copy results to this directory and remove the image afterwards
IMAGE=compile_audiowaveform
docker build -t $IMAGE .                                         || exit 1
CONTAINER_ID=`docker create $IMAGE`                              || exit 1
docker cp $CONTAINER_ID:/tmp/compile/audiowaveform-mingw32.zip . || exit 1
docker cp $CONTAINER_ID:/tmp/compile/audiowaveform-mingw64.zip . || exit 1
docker rm -v $CONTAINER_ID                                       || exit 1
docker rmi $IMAGE                                                || exit 1

