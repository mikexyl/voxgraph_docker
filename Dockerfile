ARG TF_SET_VERSION=1.14.0
ARG ROS_SET_VERSION=melodic
ARG UBUNTU_SET_VERSION=bionic

FROM ros-tensorflow-melodic:latest
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

# Install carla, put it in beginning since it needs download 7.8G
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1AF1527DE64CB8D9 &&\
        add-apt-repository "deb [arch=amd64] http://dist.carla.org/carla $(lsb_release -sc) main" &&\
        apt-get update && apt-get install carla-simulator -y

RUN pip install numpy && apt update && apt install libnvidia-gl-450 carla-ros-bridge -y && apt clean

ENV PYTHONPATH $PYTHONPATH:/opt/carla-simulator/PythonAPI/carla/dist/carla-0.9.11-py2.7-linux-x86_64.egg

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

RUN apt update && apt install software-properties-common apt-utils libblas-dev liblapack-dev python-catkin-tools wget autoconf curl libtool libtool-bin ros-${ROS_VERSION}-geometry ros-${ROS_VERSION}-rviz -y

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

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN apt update && apt install python-tk -y

RUN apt-get update && apt-get install -y \
    mesa-utils && \
    rm -rf /var/lib/apt/lists/*

RUN apt update && apt install -y ros-${ROS_VERSION}-ddynamic-reconfigure ros-${ROS_VERSION}-diagnostics \
        ros-${ROS_VERSION}-rgbd-launch libtbb-dev ros-${ROS_VERSION}-desktop-full && apt clean

# mrcoord deps
RUN apt update && apt install ros-melodic-cartographer-ros ros-melodic-ros-numpy ros-melodic-gazebo-plugins git libv4l-dev libsuitesparse-dev libnlopt-dev python-catkin-tools python-wstool ros-melodic-joy ros-melodic-octomap-ros ros-melodic-mav-msgs ros-melodic-mav-planning-msgs ros-melodic-sophus ros-melodic-hector-gazebo-plugins libatlas-base-dev python-matplotlib python-numpy \
  liblapacke-dev libode6 libompl-dev libompl12 libopenexr-dev libglm-dev libunwind-dev libomp-dev -y && apt clean

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
RUN apt install clang ccache -y && ccache --max-size=10G && chown -R ${USERNAME} /home/${USERNAME}/.ccache

RUN python -m pip install glog pcl evo==1.12.0

COPY Open3D /Open3D
RUN cd /Open3D && ./util/scripts/install-deps-ubuntu.sh assume-yes && mkdir build && cd build && cmake .. -DBUILD_PYTHON_MODULE=OFF -DBUILD_SHARED_LIBS=ON -DGLIBCXX_USE_CXX11_ABI=ON -DWITH_OPENMP=OFF && make -j16 && make install

ENTRYPOINT [ "/ros_entrypoint.sh" ]
CMD [ "bash" ]
