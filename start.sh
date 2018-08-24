#!/bin/bash

/bin/bash -c "mongod --fork --logpath /var/log/mongod.log --dbpath /root/mongo && cd /root && mongorestore"
source /root/catkin_ws/devel/setup.bash
exec "$@"
