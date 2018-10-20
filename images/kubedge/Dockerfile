FROM scratch
ADD kubedge/ca-certificates.crt /etc/ssl/certs/
ADD kubedge/goserv /goserv
EXPOSE 8080
CMD ["/goserv"]
