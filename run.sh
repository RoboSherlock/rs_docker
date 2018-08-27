#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WS_FOLDER="$DIR/workspace"
IMAGE_NAME=robosherlock/rs_interactive

# options to grant access to the Xserver (from paparazzi script: https://github.com/paparazzi/paparazzi/blob/master/docker/run.sh
# enhanced with QT_X11_NO_MITSHM from http://wiki.ros.org/docker/Tutorials/GUI)
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge - 
X_WINDOW_OPTS_PAP="--volume=$XSOCK:$XSOCK --volume=$XAUTH:$XAUTH --env=XAUTHORITY=${XAUTH} --env=DISPLAY=${DISPLAY} --env=QT_X11_NO_MITSHM=1"

# start docker container in interactive mode with
# X-forwarding, network forwarded from host pc,
# and mounted catkin workspace from host pc

#docker run -it $X_WINDOW_OPTS_PAP --name rs_interactive --rm \
#--network=host \
#${IMAGE_NAME} /bin/bash

docker run -d $X_WINDOW_OPTS_PAP \
  -p 3000:3000 -p 1111:5555 -p 9090:9090 \
  --network="host" \
  --name rs_container-2 \
${IMAGE_NAME}
