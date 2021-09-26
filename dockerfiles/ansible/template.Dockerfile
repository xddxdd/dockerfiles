#include "common.Dockerfile"
FROM python:alpine

#if !defined(ARCH_AMD64)
#error "Only AMD64 is supported"
#endif

RUN apk add --no-cache build-base libffi-dev openssh git rsync rust cargo openssl-dev \
    && sh -c "ln -sf /usr/local/lib/python3.*/site-packages /usr/local/lib/python-site-packages" \
    && pip install ansible==3.4.0 mitogen==0.3.0rc1 \
    && mkdir -p /root/.ssh /etc/ansible \
    && rm -rf /root/.cache /root/.cargo

COPY config /root/.ssh/config
COPY ansible.cfg /etc/ansible/ansible.cfg
