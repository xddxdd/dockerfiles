FROM debian:jessie-slim
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install openbsd-inetd nyancat nyancat-server
EXPOSE 23
CMD ["/usr/sbin/inetd", "-i"]
