#!/usr/bin/env bash

source /orbslam_entrypoint.sh
roslaunch orb_slam2_ros orb_slam2_d435_rgbd.launch &
roslaunch realsense2_camera rs_rgbd.launch