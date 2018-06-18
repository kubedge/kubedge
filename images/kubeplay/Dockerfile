# FROM arm32v7/ubuntu:16.04
ARG distro=stretch
FROM resin/rpi-raspbian:$distro

MAINTAINER admin@jbrette.cloud

RUN echo "Hello world arm32v7 again" > /root/hello_world.txt

CMD ["cat", "/root/hello_world.txt"]
