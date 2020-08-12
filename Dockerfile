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

# voxblox++ dependencies
RUN apt update
# RUN apt install python-dev python-pip python-wstool protobuf-compiler dh-autoreconf -y
# RUN pip2 install --upgrade pip
RUN pip2 install 'scikit-image==0.13.0' 'scikit-learn==0.19.1' 'h5py==2.7.0' ipython 'keras==2.1.6' 'scipy==0.19.1'
RUN pip2 install 'opencv-python==3.4.2.17'

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

# upgrade cmake to avoid cmake bug
# RUN apt-get install apt-transport-https ca-certificates gnupg software-properties-common wget -y && \
# wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
# apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main' && \
# apt update && apt install cmake -y

ENTRYPOINT [ "/ros_entrypoint.sh" ]
CMD [ "bash" ]
