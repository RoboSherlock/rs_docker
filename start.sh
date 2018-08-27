#!/bin/bash

/bin/bash -c "mongod --fork --logpath /var/log/mongod.log --dbpath /home/rs/mongo && cd /home/rs && mongorestore"
/bin/bash -c "cd /home/rs/app && ls && node app.js -p 3000&"

source /home/rs/catkin_ws/devel/setup.bash
exec "$@"
