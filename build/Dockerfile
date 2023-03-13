FROM alpine:3.17

ENV OPERATOR=/usr/local/bin/kubedge \
    USER_UID=1001 \
    USER_NAME=kubedge

# install operator binary
COPY build/_output/bin/kubedge ${OPERATOR}

COPY build/bin /usr/local/bin

RUN  /usr/local/bin/user_setup

ENTRYPOINT ["/usr/local/bin/entrypoint"]

USER ${USER_UID}
