#!/bin/bash
set -e
source /ros_entrypoint.sh
export ROS_HOME="/workspaces/maskgraph_ws/.ros"
cd /workspaces/maskgraph_ws/voxgraph_ws
source devel/setup.bash
exec "$@"