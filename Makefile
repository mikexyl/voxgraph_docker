.PHONY: build run-root run attach run-nvidia

XAUTH:=/tmp/.docker.xauth
TF_VERSION:=1.15.2
ROS_VERSION:=melodic
UBUNTU_VERSION:=bionic
DOCKER_NAME:=voxgraph:$(ROS_VERSION)-tf$(TF_VERSION)-l4t
ROS_PACKAGE:=perception

build:
	@docker build -t ros-tensorflow:$(ROS_VERSION)-tf$(TF_VERSION) ros_tensorflow_$(ROS_VERSION)_tf$(TF_VERSION)/.
	@docker build --build-arg myuser=${shell whoami} \
		--build-arg TF_SET_VERSION=$(TF_VERSION)\
		--build-arg ROS_SET_VERSION=$(ROS_VERSION)\
		--build-arg UBUNTU_SET_VERSION=$(UBUNTU_VERSION)\
		-t $(DOCKER_NAME)-$(ROS_PACKAGE) .

run-root: build
	nvidia-docker run -it --name $(DOCKER_NAME)  --rm \
	   --env="DISPLAY=$DISPLAY" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   -e XAUTHORITY=$(XAUTH) \
	   --volume="$(XAUTH):$(XAUTH)" \
	   --runtime=nvidia \
	   -e HOME=${HOME} \
	  #  -v "${HOME}:${HOME}/" \
	   -v /etc/localtime:/etc/localtime \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)

run:
	make build
	#touch $(XAUTH)
	#xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $(XAUTH) nmerge - 
	nvidia-docker run -it --name voxgraph  --rm \
	   --runtime nvidia \
	   --env="DISPLAY=${DISPLAY}" \
	   --env="QT_X11_NO_MITSHM=1" \
	   --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	   -e XAUTHORITY=$(XAUTH) \
	   --volume="$(XAUTH):$(XAUTH)" \
	   -e HOME=${HOME} \
	   -u ${shell whoami} \
	   -v /etc/localtime:/etc/localtime \
	   --security-opt seccomp=unconfined \
	   --net=host \
	   --privileged \
	   $(DOCKER_NAME)-perception

run-nvidia:
	make build
	#touch $(XAUTH)
	#xauth nlist ${DISPLAY} | sed -e 's/^..../ffff/' | xauth -f $(XAUTH) nmerge - 
	nvidia-docker run --gpus all -it --name $(DOCKER_NAME)  --rm \
	   --env="DISPLAY=${DISPLAY}" \
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


