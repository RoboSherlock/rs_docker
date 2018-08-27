#!/bin/bash

#start mongo
/bin/bash -c "mongod --fork --logpath /var/log/mongod.log --dbpath /home/rs/mongo && cd /home/rs && mongorestore"

#start wetty (web xterm)
/bin/bash -c "cd /home/rs/wetty && node app.js -p 3000&"

source /home/rs/rs_ws/devel/setup.bash
exec "$@"
