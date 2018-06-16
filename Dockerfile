FROM ubuntu:14.04

MAINTAINER admin@jbrette.cloud

RUN echo "Hello world" > /root/hello_world.txt

CMD ["cat", "/root/hello_world.txt"]
