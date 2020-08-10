FROM ros_cuda

# maskgraph
ENV UBUNTU_VERSION=bionic

ENV ROS_VERSION=melodic

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
RUN pip2 install --upgrade pip
RUN pip2 install 'protobuf>=3.0.0a3'  
RUN pip2 install scikit-image ipython 'keras==2.1.6'

RUN pip2 install --ignore-installed enum34
RUN pip2 install tensorflow-gpu==1.15.0

RUN apt install libblas3 liblapack3 -y

# RUN apt-get install apt-transport-https ca-certificates gnupg software-properties-common wget -y && \
# wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
# apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main' && \
# apt update && apt install cmake -y

# # setup entrypoint
# COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]