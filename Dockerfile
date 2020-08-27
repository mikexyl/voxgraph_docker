ARG TF_SET_VERSION=1.5.1
ARG ROS_SET_VERSION=kinetic
ARG UBUNTU_SET_VERSION=xenial

FROM ros-tensorflow:kinetic-tf1.6.0-cpu

ARG TF_SET_VERSION
ARG ROS_SET_VERSION
ARG UBUNTU_SET_VERSION

# maskgraph
# generic tools
ENV UBUNTU_VERSION $UBUNTU_SET_VERSION

ENV ROS_VERSION $ROS_SET_VERSION

RUN apt update && apt install python-catkin-tools wget -y

RUN apt install autoconf -y

RUN apt install curl -y

RUN apt install libtool libtool-bin -y

RUN apt install ros-${ROS_VERSION}-geometry ros-${ROS_VERSION}-rviz -y

# add user
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
# RUN apt install python-dev python-pip python-wstool protobuf-compiler dh-autoreconf -y
# RUN pip2 install --upgrade pip


# RUN pip2 install --ignore-installed enum34
# RUN pip2 install 'tensorflow-gpu==1.4.1'

RUN apt install libblas-dev liblapack-dev -y

# install and config ccache
RUN apt install ccache -y
ENV PATH "/usr/lib/ccache:$PATH"
RUN ccache --max-size=10G

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt update && apt install python-tk -y

RUN apt-get update && apt-get install -y \
    mesa-utils && \
    rm -rf /var/lib/apt/lists/*

# orb_slam2_ros dependencies
RUN apt update
RUN apt-get install software-properties-common apt-utils -y

# Set up Melodic keys
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# Set up realsense keys
RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE

#Add realsense repo
RUN add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u

# Install required realsense and ROS packages
RUN apt-get update && \
    apt-get install librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg python-catkin-tools -y
    
RUN apt update && apt install ros-${ROS_VERSION}-ddynamic-reconfigure ros-${ROS_VERSION}-diagnostics -y

RUN apt update && apt install ros-${ROS_VERSION}-realsense2-camera -y

RUN apt update && apt install ros-${ROS_VERSION}-rgbd-launch -y

COPY ./maskgraph_entrypoint.sh /
COPY ./maskgraph_startup.sh /
COPY ./orbslam_entrypoint.sh /
COPY ./orbslam_startup.sh /
COPY ./voxgraph_orbslam_rs_startup.sh /
COPY ./voxgraph_orbslam_rs.launch /

ENTRYPOINT [ "/ros_entrypoint.sh" ]
CMD [ "bash" ]
