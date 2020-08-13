# Voxgraph docker

run.sh is out dated, don't use it.
use make build/run/run-root/attach insread.

2020-08-13: ok, now you can get a ros-kinetic-xenial-cuda**gl**-tensorflow1.6.0-gpu docker by make build. and you can set ros, ubuntu and tf version by makefile args, cuda version is decided by tf-gpu docker. And it's out of box ok to build and run voxblox++ and voxgraph