ARG TF_SET_VERSION=1.5.1
ARG ROS_SET_VERSION=kinetic
ARG UBUNTU_SET_VERSION=xenial

FROM ros-tensorflow:$ROS_SET_VERSION-tf$TF_SET_VERSION
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

RUN apt update && apt install ros-${ROS_VERSION}-ddynamic-reconfigure ros-${ROS_VERSION}-diagnostics -y

RUN apt update && apt install ros-${ROS_VERSION}-rgbd-launch -y

WORKDIR "/"

RUN git clone https://github.com/jetsonhacks/installRealSenseSDK.git
RUN cd installRealSenseSDK && ./installLibrealsense.sh

RUN mkdir -p /realsense_ws/src && cd /realsense_ws && catkin init 
RUN git clone https://github.com/jetsonhacks/installRealSenseROS.git
RUN cd installRealSenseROS && unset HOME && ./installRealSenseROS.sh realsense_ws

COPY ./maskgraph_entrypoint.sh /
COPY ./maskgraph_startup.sh /
COPY ./orbslam_entrypoint.sh /
COPY ./orbslam_startup.sh /
COPY ./voxgraph_orbslam_rs_startup.sh /
COPY ./voxgraph_orbslam_rs.launch /
COPY ./rs_bagrecord_startup.sh /
COPY ./rs_bagrecord.launch /

#upgrade cmake to compile voxblox:feature/temporal_window
RUN apt update && apt install apt-transport-https ca-certificates gnupg software-properties-common wget -y && \
        wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
        apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main' && \
        apt-get update && \
        apt upgrade cmake -y

ENTRYPOINT [ "/ros_entrypoint.sh" ]
CMD [ "bash" ]
