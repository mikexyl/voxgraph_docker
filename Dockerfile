FROM ros:kinetic-perception-xenial

ENV UBUNTU_VERSION=xenial

ENV ROS_VERSION=kinetic

RUN apt update && apt install python-catkin-tools wget -y

RUN apt install autoconf -y

RUN apt install curl -y

RUN apt install libtool libtool-bin -y

RUN apt install ros-${ROS_VERSION}-geometry ros-${ROS_VERSION}-rviz -y

ARG myuser
ARG USERNAME=$myuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN usermod -a -G dialout $myuser

# voxblox++ dependencies
RUN apt update
RUN apt install python-dev python-pip python-wstool protobuf-compiler dh-autoreconf -y
# RUN pip2 install 'protobuf>=3.0.0a3' scipy scikit-image ipython 'keras==2.1.6'
RUN pip2 install tensorflow-gpu
RUN pip2 install 'protobuf>=3.0.0a3'  
RUN pip2 install scikit-image ipython 'keras==2.1.6'

#RUN apt install gcc-8 g++-8 -y

#RUN apt install libvtk6-dev libvtk6-qt-dev -y

#RUN apt update && apt install clang -y