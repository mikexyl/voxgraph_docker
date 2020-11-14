ARG TF_SET_VERSION=1.14.0
ARG ROS_SET_VERSION=melodic
ARG UBUNTU_SET_VERSION=bionic

FROM ros-tensorflow-melodic:latest
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN rm /etc/apt/sources.list.d/ros1-latest.list && \
        sudo sh -c '. /etc/lsb-release && \
        echo "deb http://mirrors.ustc.edu.cn/ros/ubuntu/ `lsb_release -cs` main" > /etc/apt/sources.list.d/ros1-latest.list'

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

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt update && apt install python-tk -y

RUN apt-get update && apt-get install -y \
    mesa-utils && \
    rm -rf /var/lib/apt/lists/*

# orb_slasfasros dependencies
RUN apt update
RUN apt-get install software-properties-common apt-utils -y

# Set up ${ROS_VERSION} keys
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

RUN apt update && apt install -y ros-${ROS_VERSION}-ddynamic-reconfigure ros-${ROS_VERSION}-diagnostics \
        ros-${ROS_VERSION}-rgbd-launch libtbb-dev ros-${ROS_VERSION}-desktop-full && apt clean

# mrcoord deps
RUN apt update && apt install ros-melodic-gazebo-plugins git libv4l-dev libsuitesparse-dev libnlopt-dev python-catkin-tools python-wstool ros-melodic-joy ros-melodic-octomap-ros ros-melodic-mav-msgs ros-melodic-mav-planning-msgs ros-melodic-sophus ros-melodic-hector-gazebo-plugins libatlas-base-dev python-matplotlib python-numpy \
  liblapacke-dev libode6 libompl-dev libompl12 libopenexr-dev libglm-dev libunwind-dev -y && apt clean

# rotors joystick deps
RUN pip install pygame -i https://pypi.tuna.tsinghua.edu.cn/simple
WORKDIR /
RUN  git clone https://github.com/devbharat/python-uinput.git && \ 
        cd python-uinput && python setup.py build && python setup.py install && \
        addgroup uinput && adduser $USERNAME uinput

COPY ./maskgraph_entrypoint.sh /
COPY ./maskgraph_startup.sh /
COPY ./orbslam_entrypoint.sh /
COPY ./orbslam_startup.sh /
COPY ./voxgraph_orbslam_rs_startup.sh /
COPY ./voxgraph_orbslam_rs.launch /
COPY ./rs_bagrecord_startup.sh /
COPY ./rs_bagrecord.launch /

ENV HOME "/home/${USERNAME}/"
RUN mkdir -p ${HOME} && touch ${HOME}/.bashrc && echo 'source /opt/ros/melodic/setup.bash' >> /root/.bashrc && \
        echo 'source /opt/ros/melodic/setup.bash' >> ${HOME}/.bashrc && chown -R ${USERNAME} ${HOME}

# install and config ccache
ENV PATH "/usr/lib/ccache:$PATH"
RUN apt install ccache -y && ccache --max-size=10G && chown -R ${USERNAME} /home/${USERNAME}/.ccache

ENTRYPOINT [ "/ros_entrypoint.sh" ]
CMD [ "bash" ]
