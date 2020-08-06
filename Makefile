.PHONY: build run-root run attach

XAUTH:=/tmp/.docker.xauth
DOCKER_NAME:=voxgraph

build:
	docker build --build-arg myuser=${shell whoami} -t $(DOCKER_NAME) .

run-root: build
	docker run -it --name $(DOCKER_NAME)  --rm \
	   --env="DISPLAY=$DISPLAY" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   -e XAUTHORITY=$(XAUTH) \
	   --volume="$(XAUTH):$(XAUTH)" \
	   --runtime=nvidia \
	   -e HOME=${HOME} \
	   -v "${HOME}:${HOME}/" \
	   -v /etc/group:/etc/group:ro \
	   -v /etc/localtime:/etc/localtime \
	   -v /etc/passwd:/etc/passwd:ro \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)

run:
	make build
	#touch $(XAUTH)
	#xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $(XAUTH) nmerge - 
	docker run -it --name $(DOCKER_NAME)  --rm \
	   --env="DISPLAY=$DISPLAY" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   -e XAUTHORITY=$(XAUTH) \
	   --volume="$(XAUTH):$(XAUTH)" \
	   --runtime=nvidia \
	   -e HOME=${HOME} \
	   -v "${HOME}:${HOME}/" \
	   -u $(shell id -u ${USER} ):$(shell id -g ${USER}) \
	   -v /etc/group:/etc/group:ro \
	   -v /etc/localtime:/etc/localtime \
	   -v /etc/passwd:/etc/passwd:ro \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)

attach:
	docker exec -it $(DOCKER_NAME) /bin/bash


