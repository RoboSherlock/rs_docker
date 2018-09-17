#!/bin/bash

IMAGE_NAME=robosherlock/rs_interactive

docker run -d \
  -p 3000:3000 -p 1111:5555 -p 9090:9090 -p 8080:8080 \
  --name rs_container \
${IMAGE_NAME}
