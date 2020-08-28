#!/bin/bash

source /ros_entrypoint.sh
source ${HOME}/Workspace/maskgraph_ws/devel/setup.bash
source ${HOME}/Workspace/orbslam_ws/devel/setup.bash
roscore &
roslaunch /rs_bagrecord.launch --wait
