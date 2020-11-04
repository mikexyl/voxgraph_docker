ARG TF_SET_VERSION=1.5.1
ARG ROS_SET_VERSION=kinetic
ARG UBUNTU_SET_VERSION=xenial
# Build libglvnd
FROM ubuntu:16.04 as glvnd

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
        make \
        automake \
        autoconf \
        libtool \
        pkg-config \
        python \
        libxext-dev \
        libx11-dev \
        x11proto-gl-dev && \
    rm -rf /var/lib/apt/lists/*

ARG LIBGLVND_VERSION=v1.1.0

WORKDIR /opt/libglvnd
RUN git clone --branch="${LIBGLVND_VERSION}" https://github.com/NVIDIA/libglvnd.git . && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/x86_64-linux-gnu && \
    make -j"$(nproc)" install-strip && \
    find /usr/local/lib/x86_64-linux-gnu -type f -name 'lib*.la' -delete

RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
        gcc-multilib \
        libxext-dev:i386 \
        libx11-dev:i386 && \
    rm -rf /var/lib/apt/lists/*

# 32-bit libraries
RUN make distclean && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib/i386-linux-gnu --host=i386-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32" && \
    make -j"$(nproc)" install-strip && \
    find /usr/local/lib/i386-linux-gnu -type f -name 'lib*.la' -delete

ARG TF_SET_VERSION
ARG ROS_SET_VERSION
ARG UBUNTU_SET_VERSION
FROM ros-tensorflow:$ROS_SET_VERSION-tf$TF_SET_VERSION
LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

COPY --from=glvnd /usr/local/lib/x86_64-linux-gnu /usr/local/lib/x86_64-linux-gnu
COPY --from=glvnd /usr/local/lib/i386-linux-gnu /usr/local/lib/i386-linux-gnu

COPY 10_nvidia.json /usr/local/share/glvnd/egl_vendor.d/10_nvidia.json

RUN echo '/usr/local/lib/x86_64-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    echo '/usr/local/lib/i386-linux-gnu' >> /etc/ld.so.conf.d/glvnd.conf && \
    ldconfig

ENV LD_LIBRARY_PATH /usr/local/lib/x86_64-linux-gnu:/usr/local/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
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
RUN pip2 install scikit-image scikit-learn h5py ipython 'keras==2.1.6' scipy

RUN pip2 install 'opencv-python==3.4.2.17'

# RUN pip2 install --ignore-installed enum34
# RUN pip2 install 'tensorflow-gpu==1.4.1'

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

# Set up realsense keys
RUN apt-key adv --keyserver keys.gnupg.net --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key F6E65AC044F831AC80A06380C8B3A55A6F3EFCDE
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C8B3A55A6F3EFCDE

#Add realsense repo
RUN add-apt-repository "deb http://realsense-hw-public.s3.amazonaws.com/Debian/apt-repo xenial main" -u

# Install required realsense and ROS packages
RUN apt-get update && \
    apt-get install librealsense2-dkms librealsense2-utils librealsense2-dev librealsense2-dbg python-catkin-tools -y

RUN apt update && apt install -y ros-${ROS_VERSION}-ddynamic-reconfigure ros-${ROS_VERSION}-diagnostics \
        ros-${ROS_VERSION}-rgbd-launch libtbb-dev ros-${ROS_VERSION}-desktop-full && apt clean

# mrcoord deps
RUN apt update && apt install libv4l-dev libsuitesparse-dev libnlopt-dev \
        python-catkin-tools python-wstool ros-${ROS_VERSION}-joy \
        ros-${ROS_VERSION}-octomap-ros protobuf-compiler libgoogle-glog-dev \ 
        ros-${ROS_VERSION}-mav-msgs ros-${ROS_VERSION}-mav-planning-msgs \ 
        ros-${ROS_VERSION}-sophus ros-${ROS_VERSION}-robot ros-${ROS_VERSION}-hector-gazebo-plugins \
        libatlas-base-dev python-matplotlib python-numpy liblapacke-dev \
        libode4 libopenexr-dev libglm-dev libblas-dev libatlas-base-dev libopenblas-dev liblapacke-dev libbullet-dev -y && apt clean

# ompl 1.2.3
WORKDIR /
RUN export http_proxy=http://10.78.92.79:58088 && export https_proxy=https://10.78.92.79:58088 && git clone https://github.com/ompl/ompl.git && cd ompl && git checkout 1.2.3 && unset http_proxy
RUN apt update && apt install -y castxml doxygen python3-pip && pip3 install pygccxml pyplusplus
RUN cd ompl && mkdir -p build/Release && cd build/Release && cmake ../.. -DCMAKE_INSTALL_PREFIX=/usr && make -j12 && make install

COPY ./maskgraph_entrypoint.sh /
COPY ./maskgraph_startup.sh /
COPY ./orbslam_entrypoint.sh /
COPY ./orbslam_startup.sh /
COPY ./voxgraph_orbslam_rs_startup.sh /
COPY ./voxgraph_orbslam_rs.launch /
COPY ./rs_bagrecord_startup.sh /
COPY ./rs_bagrecord.launch /

ENV HOME "/home/${USERNAME}/"
RUN mkdir -p ${HOME}
RUN touch ${HOME}/.bashrc
RUN echo 'source /opt/ros/kinetic/setup.bash' >> /root/.bashrc
RUN echo 'source /opt/ros/kinetic/setup.bash' >> ${HOME}/.bashrc

# install and config ccache
RUN apt install ccache -y
ENV PATH "/usr/lib/ccache:$PATH"
RUN ccache --max-size=10G && chown -R ${USERNAME} /home/${USERNAME}/.ccache

ENTRYPOINT [ "/ros_entrypoint.sh" ]
CMD [ "bash" ]
