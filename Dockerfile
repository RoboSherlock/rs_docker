FROM ros:kinetic-perception-xenial

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:robosherlock/ppa
RUN apt-get update && apt-get install -y \
    rapidjson byobu tig htop\
    libxerces-c-dev \
    libicu-dev \
    libapr1-dev \
    mongodb \
    openjdk-8-jdk \
    swi-prolog \
    swi-prolog-java \
    libjson-java \
    libjson-glib-dev \ 
    ros-kinetic-libmongocxx-ros \
    ros-kinetic-tf-conversions \
    ros-kinetic-resource-retriever \ 
    ros-kinetic-tf2-web-republisher \ 
    ros-kinetic-web-video-server \
    ros-kinetic-rosbridge-server \
    ros-kinetic-rosjava \
    ros-kinetic-xacro \ 
    ros-kinetic-urdf

# install some tools for building and editing in docker container
RUN apt-get install -y \
    python-catkin-tools \
    python-pip \
    gdb \
    vim

RUN pip install flask pymongo pyparsing socketio flask-paginate flask-wtf gevent

ENV APR_HOME=/usr
ENV ICU_HOME=/usr
ENV XERCES_HOME=/usr

ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}
# install uimacpp_ros dependency from sources
RUN mkdir /root/catkin_ws && cd /root/catkin_ws && \
    mkdir src && mkdir -p /root/mongo && mkdir -p  /root/dump/IJRRScenes
  #  git clone https://github.com/knowrob/knowrob -b kinetic && \
  #  git clone https://github.com/code-iai/iai_maps && \
  #  git clone https://github.com/code-iai/iai_common_msgs && \
  #  git clone https://github.com/RoboSherlock/uimacpp_ros && \
  #  git clone https://github.com/RoboSherlock/robosherlock -b devel && \
  #  git clone https://github.com/RoboSherlock/robosherlock_msgs && \
  #  git clone https://github.com/RoboSherlock/robosherlock_knowrob && \
  #  git clone https://github.com/RoboSherlock/rs_web -b dev_unification && \
  #  cd .. 

COPY workspace /root/catkin_ws/src/ 

WORKDIR /root/catkin_ws
ENV TERM=xterm

RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash" && \
    catkin init && \
    catkin config --extend /opt/ros/kinetic && \
    catkin build --verbose

ENV USER=rs
EXPOSE 5555

COPY ./start.sh /
COPY ./IJRRScenes/ /root/dump/IJRRScenes

WORKDIR /root
RUN /bin/bash -c "mongod --fork --logpath /var/log/mongod.log --dbpath /root/mongo && mongorestore" 

ENTRYPOINT ["/start.sh"]
#CMD ["/bin/bash", "-c", "source /root/catkin_ws/devel/setup.bash"]
CMD ["roslaunch","/root/catkin_ws/src/rs_run_configs/launch/pnp_ease.launch"]
