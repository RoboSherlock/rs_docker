#1. Installing Core Libraries

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
    ros-kinetic-rosconsole-bridge \ 
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
    ros-kinetic-catkin \
    libpthread-stubs0-dev\
    librrd-dev \
    libpython-dev \
    python-bs4 \
    python-chardet \
    python-html5lib \
    python-lxml \
    python-pip \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    freeglut3-dev \
    mesa-common-dev \
    gdb \
    vim \ 
    libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev protobuf-compiler libgflags-dev libgoogle-glog-dev liblmdb-dev libatlas-base-dev libatlas-dev libatlas3-base

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nvidia-384

RUN pip install python-rrdtool

RUN pip install flask pymongo pyparsing socketio flask-paginate flask-wtf gevent lxml

RUN useradd -ms /bin/bash rs &&\
    echo 'rs:rs' | chpasswd

ENV LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}

#2. Making directories for robosherlock packages

RUN mkdir -p /home/rs/base_ws/src && \
    mkdir -p /home/rs/rs_ws/src && \ 
    mkdir -p /home/rs/mongo && \
    mkdir -p /home/rs/dump && \ 
    mkdir -p /home/rs/local/src

#3. Downloading core packages of robosherlock

WORKDIR /home/rs/rs_ws/src
RUN git clone https://github.com/RoboSherlock/robosherlock.git --recursive && \
    git clone https://github.com/bbferka/rs_addons.git && \
    git clone https://github.com/RoboSherlock/rs_ease_fs && \
    git clone https://github.com/RoboSherlock/rs_web 


#4. Downloading Caffe package

WORKDIR /home/rs/local/src/
RUN git clone https://github.com/bvlc/caffe

#5. Building Caffe

WORKDIR /home/rs/local/src/caffe/
RUN mkdir build && cd build && cmake ../ -DCPU_ONLY=On -DCMAKE_INSTALL_PREFIX=/usr/local && make && make install
 
#6. Downloading Knowrob

WORKDIR /home/rs/
RUN chown -R rs:rs .
WORKDIR /home/rs/base_ws
USER root
ENV TERM=xterm
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash"
WORKDIR /home/rs/base_ws/src
RUN rosdep update && \
    wstool init && \
    wstool merge https://raw.github.com/knowrob/knowrob/6e1d2701442f4c2d5461325647e3bd6a0e4701d2/rosinstall/knowrob-base.rosinstall && \  
    wstool update
    

#7. Building Knowrob

WORKDIR /home/rs/base_ws/src/knowrob
RUN    git checkout 6e1d2701442f4c2d5461325647e3bd6a0e4701d2 
WORKDIR /home/rs/base_ws
RUN    rosdep install --ignore-src --from-paths -y . && \
       catkin config --extend /opt/ros/kinetic && \
       catkin build --verbose

#7.2. Downloading iai_maps

WORKDIR /home/rs/base_ws/src
RUN git clone https://github.com/code-iai/iai_maps.git

#7.3. Building iai_maps

WORKDIR /home/rs/base_ws
RUN catkin build iai_maps --verbose
RUN chown -R rs:rs .

#8. Building core packages of robosherlock
WORKDIR /home/rs/rs_ws
RUN catkin init && \
    catkin config --extend /home/rs/base_ws/devel && \
    catkin build --verbose --cmake-args -DWITH_JSON_PROLOG=True &&\
    /bin/bash -c "source /home/rs/base_ws/devel/setup.bash"
RUN chown -R rs:rs .  

#9. Declaring and Exposing host devices

ENV USER=rs
EXPOSE 5555

COPY ./dump /home/rs/dump
RUN   mkdir -p /home/rs/data 
COPY ./data /home/rs/data

user rs
WORKDIR /home/rs/base_ws
RUN catkin build


USER root
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - ; \
    apt-get install -y nodejs
USER root
RUN chown -R rs:rs /home/rs/dump
WORKDIR /home/rs
RUN git clone https://github.com/krishnasrinivas/wetty.git
WORKDIR /home/rs/wetty
RUN git checkout a24c55b76d998c1a29c1f753111563f0087385f5
RUN npm install 

RUN echo "source /home/rs/rs_ws/devel/setup.bash" >> /home/rs/.bashrc
RUN echo "export DISPLAY=:0.0" >> /home/rs/.bashrc

EXPOSE 3000
COPY ./start.sh /
ENTRYPOINT ["/start.sh"]
CMD ["roslaunch","/home/rs/rs_ws/src/rs_run_configs/launch/json_prolog_and_rosbridge.launch"]
