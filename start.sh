#!/bin/bash

/bin/bash -c "mongod --fork --logpath /var/log/mongod.log --dbpath /root/mongo"
source /root/catkin_ws/devel/setup.bash
exec "$@"
