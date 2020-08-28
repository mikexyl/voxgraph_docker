#!/bin/bash

source /ros_entrypoint.sh
source ${HOME}/Workspace/maskgraph_ws/devel/setup.bash
source ${HOME}/Workspace/orbslam_ws/devel/setup.bash
roscore &
roslaunch realsense2_camera rs_rgbd.launch --wait
sleep 10
roslaunch voxgraph orbslam_d435i_bagrecord.launch --wait
