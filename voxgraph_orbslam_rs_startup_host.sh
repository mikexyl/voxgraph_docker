#!/usr/bin/env bash
DOCKER_NAME=voxgraph:kinetic-tf1.6.0-perception
make build
docker run -it --name voxgraph --rm \
   --privileged \
   -e HOME=${HOME} \
   -v "${HOME}/Workspace:${HOME}/Workspace/" \
   -v /etc/group:/etc/group:ro \
   -v /etc/localtime:/etc/localtime \
   -v /etc/passwd:/etc/passwd:ro \
   --security-opt seccomp=unconfined \
   --net=host \
   -u ${USER} \
   ${DOCKER_NAME} \
   /./voxgraph_orbslam_rs_startup.sh
