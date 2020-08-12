.PHONY: build run-root run attach run-nvidia

XAUTH:=/tmp/.docker.xauth
DOCKER_NAME:=ros-tensorflow:melodic-tf1.14.0

build:
	nvidia-docker build -t $(DOCKER_NAME) .

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
	   -v /etc/localtime:/etc/localtime \
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
	   -u ${shell whoami} \
	   -v /etc/localtime:/etc/localtime \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)

run-nvidia:
	make build
	#touch $(XAUTH)
	#xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $(XAUTH) nmerge - 
	nvidia-docker run -it --name $(DOCKER_NAME)  --rm \
	   --env="DISPLAY=$DISPLAY" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   -e XAUTHORITY=$(XAUTH) \
	   --volume="$(XAUTH):$(XAUTH)" \
	   --runtime=nvidia \
	   -e HOME=${HOME} \
	   -u ${shell whoami} \
	   -v /etc/localtime:/etc/localtime \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)


attach:
	docker exec -it $(DOCKER_NAME) /bin/bash


