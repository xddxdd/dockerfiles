FROM debian:jessie-slim
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y ca-certificates openssl python3 python3-requests python3-pip \
    && apt-get clean
ENV PYTHONUNBUFFERED=0
ENTRYPOINT python3 /file/__init__.py
