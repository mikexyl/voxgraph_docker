FROM ros:melodic-perception-bionic

ENV UBUNTU_VERSION=bionic

ENV ROS_VERSION=melodic

RUN apt update && apt install python-catkin-tools wget -y

RUN apt install autoconf -y

RUN apt install curl -y

RUN apt install libtool libtool-bin -y

RUN apt install ros-${ROS_VERSION}-geometry -y