FROM ros:kinetic-perception-xenial

RUN apt-get update && apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:robosherlock/ppa
RUN apt-get update && apt-get install -y \
    sudo \
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
    ros-kinetic-urdf \
    python-catkin-tools \
    python-pip \
    gdb \
    vim

RUN pip install flask pymongo pyparsing socketio flask-paginate flask-wtf gevent

RUN useradd -ms /bin/bash rs &&\
    echo 'rs:rs' | chpasswd

ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}


RUN mkdir /home/rs/catkin_ws && cd /home/rs/catkin_ws && \
    mkdir src && \
    mkdir -p /home/rs/mongo && \
    mkdir -p /home/rs/dump/IJRRScenes
  #  git clone https://github.com/knowrob/knowrob -b kinetic && \
  #  git clone https://github.com/code-iai/iai_maps && \
  #  git clone https://github.com/code-iai/iai_common_msgs && \
  #  git clone https://github.com/RoboSherlock/uimacpp_ros && \
  #  git clone https://github.com/RoboSherlock/robosherlock -b devel && \
  #  git clone https://github.com/RoboSherlock/robosherlock_msgs && \
  #  git clone https://github.com/RoboSherlock/robosherlock_knowrob && \
  #  git clone https://github.com/RoboSherlock/rs_web -b dev_unification && \
  #  cd .. 

COPY workspace /home/rs/catkin_ws/src/ 
WORKDIR /home/rs/catkin_ws
RUN chown -R rs:rs .

USER rs

ENV TERM=xterm
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash" && \
    catkin init && \
    catkin config --extend /opt/ros/kinetic && \
    catkin build --verbose --cmake-args -DWITH_JSON_PROLOG=True

ENV USER=rs
EXPOSE 5555

COPY ./IJRRScenes/ /home/rs/dump/IJRRScenes

USER root
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - ; \
    apt-get install -y nodejs

ADD wetty /home/rs/app
WORKDIR /home/rs/app
USER root
RUN npm install 

RUN echo "source /home/rs/catkin_ws/devel/setup.bash" >> /home/rs/.bashrc

EXPOSE 3000
COPY ./start.sh /
ENTRYPOINT ["/start.sh"]
#CMD ["/bin/bash", "-c", "source /root/catkin_ws/devel/setup.bash"]
CMD ["roslaunch","/home/rs/catkin_ws/src/rs_run_configs/launch/pnp_ease_with_json_prolog.launch"]
