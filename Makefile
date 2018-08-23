# Makefile for building docker image

IMAGE_NAME=robosherlock/rs_interactive

all: build

build:
	docker build -t ${IMAGE_NAME} .

force-build:
	docker build --no-cache -t ${IMAGE_NAME} .
